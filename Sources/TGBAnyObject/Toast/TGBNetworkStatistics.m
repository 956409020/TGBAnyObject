//
//  TGBNetworkStatistics.m
//  AVOS
//
//  Created by Tang Tianyong on 6/26/15.
//  Copyright (c) 2015 LeanCloud Inc. All rights reserved.
//

#import "TGBNetworkStatistics.h"
#import "TGBKeyValueStore.h"
#import "TGBAnalyticsUtils.h"
#import "TGBPaasClient.h"
#import "TGBUtils.h"
#import <libkern/OSAtomic.h>
#import "TGBEXTScope.h"

#define LC_INTERVAL_HALF_AN_HOUR 30 * 60

static NSTimeInterval TGBNetworkStatisticsCheckInterval  = 60; // A minute
static NSTimeInterval TGBNetworkStatisticsUploadInterval = 24 * 60 * 60; // A day

//After v3.7.0, SDK use millisecond instead of second as time unit in networking performance.
static NSString *TGBNetworkStatisticsInfoKey       = @"TGBNetworkStatisticsInfoKey" @"-" @"v1.0";
static NSString *TGBNetworkStatisticsLastUpdateKey = @"TGBNetworkStatisticsLastUpdateKey";
static NSInteger TGBNetworkStatisticsMaxCount      = 10;
static NSInteger TGBNetworkStatisticsCacheSize     = 20;

@interface TGBNetworkStatistics ()

@property (nonatomic, assign) BOOL                 enable;
@property (nonatomic, strong) NSMutableDictionary *cachedStatisticDict;
@property (nonatomic, strong) NSRecursiveLock     *cachedStatisticDictLock;
@property (nonatomic, assign) NSTimeInterval       cachedLastUpdatedAt;

@end

#define LOCK_CACHED_STATISTIC_DICT()            \
    [self.cachedStatisticDictLock lock];        \
                                                \
    @onExit {                                   \
        [self.cachedStatisticDictLock unlock];  \
    }

@implementation TGBNetworkStatistics

+ (instancetype)sharedInstance {
    static TGBNetworkStatistics *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        _cachedStatisticDictLock = [[NSRecursiveLock alloc] init];
        _ignoreAlwaysCollectIfCustomedService = false;
    }

    return self;
}

- (NSMutableDictionary *)statisticsInfo {
    LOCK_CACHED_STATISTIC_DICT();

    if (self.cachedStatisticDict) {
        return self.cachedStatisticDict;
    }

    NSMutableDictionary *dict = nil;

    TGBKeyValueStore *store = [TGBKeyValueStore sharedInstance];

    NSData *data = [store dataForKey:TGBNetworkStatisticsInfoKey];

    if (data) {
        dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        dict = [NSMutableDictionary dictionary];
    }

    return dict;
}

- (void)saveStatisticsDict:(NSDictionary *)statisticsDict {
    LOCK_CACHED_STATISTIC_DICT();

    self.cachedStatisticDict = [statisticsDict mutableCopy];
}

- (void)writeCachedStatisticsDict {
    LOCK_CACHED_STATISTIC_DICT();

    if (!self.cachedStatisticDict) return;

    TGBKeyValueStore *store = [TGBKeyValueStore sharedInstance];

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.cachedStatisticDict];

    [store setData:data forKey:TGBNetworkStatisticsInfoKey];
}

- (void)addIncrementalAttribute:(NSInteger)amount forKey:(NSString *)key {
    LOCK_CACHED_STATISTIC_DICT();

    NSMutableDictionary *statisticsInfo = [self statisticsInfo];

    NSNumber *value = statisticsInfo[key];

    if (value) {
        statisticsInfo[key] = @([value integerValue] + amount);
    } else {
        statisticsInfo[key] = @(amount);
    }

    [self saveStatisticsDict:statisticsInfo];
}

- (void)addAverageAttribute:(double)amount forKey:(NSString *)key {
    LOCK_CACHED_STATISTIC_DICT();

    NSMutableDictionary *statisticsInfo = [self statisticsInfo];

    NSNumber *value = statisticsInfo[key];

    if (value) {
        statisticsInfo[key] = @(([value doubleValue] + amount) / 2.0);
    } else {
        statisticsInfo[key] = @(amount);
    }

    [self saveStatisticsDict:statisticsInfo];
}

- (void)uploadStatisticsInfo:(NSDictionary *)statisticsInfo
{
    NSMutableDictionary *payloadDic = [NSMutableDictionary dictionaryWithCapacity:2];
    
    if (statisticsInfo) { payloadDic[@"attributes"] = statisticsInfo; }
    
    NSMutableDictionary *clientDic = [NSMutableDictionary dictionaryWithCapacity:4];
    
    NSDictionary *deviceInfo = [TGBAnalyticsUtils deviceInfo];
    
#if !TARGET_OS_WATCH
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    id deviceId = deviceInfo[@"device_id"];
    if (deviceId) { clientDic[@"id"] = deviceId; }
#endif
#endif
    
    id platform = deviceInfo[@"os"];
    if (platform) { clientDic[@"platform"] = platform; }
    
    id appVersion = deviceInfo[@"app_version"];
    if (appVersion) { clientDic[@"app_version"] = appVersion; }
    
    id sdkVersion = deviceInfo[@"sdk_version"];
    if (sdkVersion) { clientDic[@"sdk_version"] = sdkVersion; }
    
    payloadDic[@"client"] = clientDic;

    TGBPaasClient *client = [TGBPaasClient sharedInstance];
    NSURLRequest *request = [client requestWithPath:@"always_collect" method:@"POST" headers:nil parameters:payloadDic];

    [client
     performRequest:request
     success:^(NSHTTPURLResponse *response, id responseObject) {
         [self statisticsInfoDidUpload];
     }
     failure:nil];
}

- (void)statisticsInfoDidUpload {
    LOCK_CACHED_STATISTIC_DICT();

    // Reset network statistics data
    TGBKeyValueStore *store = [TGBKeyValueStore sharedInstance];
    [store deleteKey:TGBNetworkStatisticsInfoKey];

    // Clean cached statistic dict
    [self.cachedStatisticDict removeAllObjects];

    // Increase check interval to save CPU time
    TGBNetworkStatisticsCheckInterval = LC_INTERVAL_HALF_AN_HOUR;

    [self updateLastUpdateAt];
}

- (void)updateLastUpdateAt {
    TGBKeyValueStore *store = [TGBKeyValueStore sharedInstance];

    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSData *dateData = [NSData dataWithBytes:&now length:sizeof(now)];

    [store setData:dateData forKey:TGBNetworkStatisticsLastUpdateKey];

    self.cachedLastUpdatedAt = now;
}

- (NSTimeInterval)lastUpdateAt {
    if (self.cachedLastUpdatedAt > 0) {
        return self.cachedLastUpdatedAt;
    }

    TGBKeyValueStore *store = [TGBKeyValueStore sharedInstance];
    NSData *dateData = [store dataForKey:TGBNetworkStatisticsLastUpdateKey];

    if (dateData) {
        NSTimeInterval lastUpdateAt = 0;
        [dateData getBytes:&lastUpdateAt length:sizeof(lastUpdateAt)];

        self.cachedLastUpdatedAt = lastUpdateAt;

        return lastUpdateAt;
    }

    return 0;
}

- (BOOL)atTimeToUpload {
    NSTimeInterval lastUpdateAt = [self lastUpdateAt];

    if (lastUpdateAt <= 0) {
        return YES;
    }

    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];

    if (now - lastUpdateAt > TGBNetworkStatisticsUploadInterval) {
        return YES;
    } else {
        return NO;
    }
}

- (void)startInBackground
{
    if (self.ignoreAlwaysCollectIfCustomedService) {
        
        return;
    }
    
    NSAssert(![NSThread isMainThread], @"This method must run in background.");

    AV_WAIT_WITH_ROUTINE_TIL_TRUE(!self.enable, TGBNetworkStatisticsCheckInterval, ({
        NSDictionary *statisticsInfo = [[self statisticsInfo] copy];

        NSInteger total = [statisticsInfo[@"total"] integerValue];

        if (total > 0) {
            if ([self atTimeToUpload] || total > TGBNetworkStatisticsMaxCount) {
                [self uploadStatisticsInfo:statisticsInfo];
            }
            if (total % TGBNetworkStatisticsCacheSize == 0) {
                [self writeCachedStatisticsDict];
            }
        }
    }));
}

- (void)start {
    if (!self.enable) {
        self.enable = YES;
        [self performSelectorInBackground:@selector(startInBackground) withObject:nil];
    }
}

- (void)stop {
    self.enable = NO;
}

@end
