//
//  paas.m
//  paas
//
//  Created by Zhu Zeng on 2/25/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import "TGBKKit.h"
#import "TGBCloud_Internal.h"
#import "TGBPaasClient.h"
#import "TGBScheduler.h"
#import "TGBPersistenceUtils.h"

#if !TARGET_OS_WATCH
#import "TGBAnalytics_Internal.h"
#endif

#import "TGBUtils.h"
#include "TGBOSCloud_Art.inc"
#import "TGBAnalyticsUtils.h"
#import "TGBNetworkStatistics.h"
#import "TGBObjectUtils.h"

#import "TGBRouter_Internal.h"
#import "TGBMacros.h"

static AVVerbosePolicy _verbosePolicy = kAVVerboseShow;

static BOOL LCInitialized = NO;

static BOOL LCSSLPinningEnabled = false;

@implementation TGBKKit {
    
    NSString *_applicationId;
    
    NSString *_applicationKey;
}

+ (instancetype)sharedInstance
{
    static TGBKKit *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[TGBKKit alloc] init];
    });
    
    return sharedInstance;
}

+ (void)setSSLPinningEnabled:(BOOL)enabled
{
    if (LCInitialized) {
        
        [NSException raise:NSInternalInconsistencyException
                    format:@"SSL Pinning Enabled should be set before +[AVOSCloud setApplicationId:clientKey:]."];
    }
    
    LCSSLPinningEnabled = enabled;
}

+ (BOOL)isSSLPinningEnabled
{
    return LCSSLPinningEnabled;
}

+ (void)setAllLogsEnabled:(BOOL)enabled {
//    [AVLogger setAllLogsEnabled:enabled];
}

+ (void)setVerbosePolicy:(AVVerbosePolicy)verbosePolicy {
    _verbosePolicy = verbosePolicy;
}

+ (void)logApplicationInfo {
    const char *s = (const char *)AVOSCloud_Art_inc;
    printf("%s\n", s);
    printf("appid: %s\n", [[self getApplicationId] UTF8String]);
    NSDictionary *dict = [TGBAnalyticsUtils deviceInfo];
    for (NSString *key in dict) {
        id value = [dict objectForKey:key];
        printf("%s: %s\n", [key UTF8String], [[NSString stringWithFormat:@"%@", value] UTF8String]);
    }
    printf("----------------------------------------------------------\n");
}

+ (void)initializePaasClient {
    TGBPaasClient *paasClient = [TGBPaasClient sharedInstance];

    paasClient.applicationId = [self getApplicationId];
    paasClient.clientKey     = [self getClientKey];

    // always handle offline requests, include analytics collection
    [paasClient handleAllArchivedRequests];
}

+ (void)setApplicationId:(NSString *)applicationId clientKey:(NSString *)clientKey
{
    [TGBKKit sharedInstance]->_applicationId = applicationId;
    [TGBKKit sharedInstance]->_applicationKey = clientKey;

//    if (_verbosePolicy == kAVVerboseShow) {
//        [self logApplicationInfo];
//    }

    [self initializePaasClient];
    [[TGBNetworkStatistics sharedInstance] start];
    [TGBRouter sharedInstance];
#if !TARGET_OS_WATCH
    [TGBAnalytics startInternally];
#endif

    LCInitialized = YES;
}

+ (void)setApplicationId:(NSString *)applicationId clientKey:(NSString *)clientKey returnCallBackBlock:(void(^)(void))block{
  
  [TGBKKit sharedInstance]->_applicationId = applicationId;
  [TGBKKit sharedInstance]->_applicationKey = clientKey;
  
  if (_verbosePolicy == kAVVerboseShow) {
//      [self logApplicationInfo];
    NSLog(@"IMC初始化成功");
  }
  
  [self initializePaasClient];
  [[TGBNetworkStatistics sharedInstance] start];
  [TGBRouter sharedInstance];
#if !TARGET_OS_WATCH
  [TGBAnalytics startInternally];
#endif
  
  LCInitialized = YES;
  
}

+ (BOOL)isTwoArrayEqual:(NSArray *)array withAnotherArray:(NSArray *)anotherArray
{
    if (array.count != anotherArray.count) {
        return NO;
    }
    
    NSSet *set = [NSSet setWithArray:array];
    NSMutableSet *set1 = [NSMutableSet setWithSet:set];
    NSSet *set2 = [NSSet setWithArray:anotherArray];
    [set1 unionSet:set2];

    return set1.count == array.count;
}

+ (NSString *)getApplicationId
{
    return [TGBKKit sharedInstance]->_applicationId;
}

+ (NSString *)getClientKey
{
    return [TGBKKit sharedInstance]->_applicationKey;
}

+ (void)setLastModifyEnabled:(BOOL)enabled{
    [TGBPaasClient sharedInstance].isLastModifyEnabled=enabled;
}

/**
 *  获取是否开启LastModify支持
 */
+ (BOOL)getLastModifyEnabled{
    return [TGBPaasClient sharedInstance].isLastModifyEnabled;
}

+(void)clearLastModifyCache {
    [[TGBPaasClient sharedInstance] clearLastModifyCache];
}

+ (void)setServerURLString:(NSString * _Nullable)URLString forServiceModule:(AVServiceModule)serviceModule
{
    NSString *key = nil;
    switch (serviceModule) {
        case AVServiceModuleAPI: key = RouterKeyAppAPIServer; break;
        case AVServiceModuleRTM: key = RouterKeyAppRTMRouterServer; break;
        case AVServiceModulePush: key = RouterKeyAppPushServer; break;
        case AVServiceModuleEngine: key = RouterKeyAppEngineServer; break;
        case AVServiceModuleStatistics: key = RouterKeyAppStatsServer; break;
        default: return;
    }
    [[TGBRouter sharedInstance] customAppServerURL:URLString key:key];
}

#pragma mark - Network

+ (NSTimeInterval)networkTimeoutInterval
{
    return [[TGBPaasClient sharedInstance] timeoutInterval];
}

+ (void)setNetworkTimeoutInterval:(NSTimeInterval)time
{
    [[TGBPaasClient sharedInstance] setTimeoutInterval:time];
}

#pragma mark - Log

static AVLogLevel avlogLevel = AVLogLevelDefault;

+ (void)setLogLevel:(AVLogLevel)level {
    // if log level is too high and is not secret mode
    if ((int)level >= (1 << 4) && !getenv("SHOWMETHEMONEY")) {
//        NSLog(@"unsupport log level");
        level = AVLogLevelDefault;
    }
    avlogLevel = level;
}

+ (AVLogLevel)logLevel {
    return avlogLevel;
}

#pragma mark Schedule work

+ (NSInteger)queryCacheExpiredDays {
    return [TGBScheduler sharedInstance].queryCacheExpiredDays;
}

+ (void)setQueryCacheExpiredDays:(NSInteger)days {
    [TGBScheduler sharedInstance].queryCacheExpiredDays = days;
}

+ (NSInteger)fileCacheExpiredDays {
    return [TGBScheduler sharedInstance].fileCacheExpiredDays;
}

+ (void)setFileCacheExpiredDays:(NSInteger)days {
    [TGBScheduler sharedInstance].fileCacheExpiredDays = days;
}

+(void)verifySmsCode:(NSString *)code mobilePhoneNumber:(NSString *)phoneNumber callback:(AVBooleanResultBlock)callback {
    NSParameterAssert(code);
    NSParameterAssert(phoneNumber);
    
    NSString *path=[NSString stringWithFormat:@"verifySmsCode/%@",code];
    NSDictionary *params = @{ @"mobilePhoneNumber": phoneNumber };
    [[TGBPaasClient sharedInstance] postObject:path withParameters:params block:^(id object, NSError *error) {
        [TGBUtils callBooleanResultBlock:callback error:error];
    }];
}

+ (NSDate *)getServerDate:(NSError *__autoreleasing *)error {
    __block NSDate *date = nil;
    __block NSError *errorStrong;
    __block BOOL finished = NO;

    [[TGBPaasClient sharedInstance] getObject:@"date" withParameters:nil block:^(id object, NSError *error_) {
        if (error) errorStrong = error_;
        if (!error_) date = [TGBObjectUtils dateFromDictionary:object];
        finished = YES;
    }];

    AV_WAIT_TIL_TRUE(finished, 0.1);

    if (error) {
        *error = errorStrong;
    }

    return date;
}

+ (NSDate *)getServerDateAndThrowsWithError:(NSError * _Nullable __autoreleasing *)error {
    return [self getServerDate:error];
}

+ (void)getServerDateWithBlock:(void (^)(NSDate *, NSError *))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSDate  *date  = [self getServerDate:&error];

        [TGBUtils callIdResultBlock:block object:date error:error];
    });
}

+ (void)setTimeZoneForSecondsFromGMT:(NSInteger)seconds
{
    LCTimeZoneForSecondsFromGMT = seconds;
}

#pragma mark - Push Notification

+ (void)handleRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self handleRemoteNotificationsWithDeviceToken:deviceToken
                                            teamId:nil
                 constructingInstallationWithBlock:nil];
}

+ (void)handleRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
                                          teamId:(NSString *)teamId
{
    [self handleRemoteNotificationsWithDeviceToken:deviceToken
                                            teamId:teamId
                 constructingInstallationWithBlock:nil];
}

+ (void)handleRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
               constructingInstallationWithBlock:(void (^)(TGBInstallation *))block
{
    [self handleRemoteNotificationsWithDeviceToken:deviceToken
                                            teamId:nil
                 constructingInstallationWithBlock:block];
}

+ (void)handleRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
                                          teamId:(NSString *)teamId
               constructingInstallationWithBlock:(void (^)(TGBInstallation *))block
{
    TGBInstallation *installation = [TGBInstallation defaultInstallation];

    @weakify(installation, weakInstallation);

    [installation setDeviceTokenFromData:deviceToken
                                  teamId:teamId];

    if (block) {
        block(installation);
    }

    [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
//            AVLoggerError(AVLoggerDomaiTGB, @"Installation saved failed, reason: %@.", error.localizedDescription);
        } else {
//            AVLoggerInfo(AVLoggerDomaiTGB, @"Installation saved OK, object id: %@.", weakInstallation.objectId);
        }
    }];
}

// MARK: - Deprecated

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (void)setStorageType:(AVStorageType)storageType {}
+ (void)setServiceRegion:(AVServiceRegion)serviceRegion {}
#pragma clang diagnostic pop

+(void)requestSmsCodeWithPhoneNumber:(NSString *)phoneNumber
                            callback:(AVBooleanResultBlock)callback {
    [self requestSmsCodeWithPhoneNumber:phoneNumber appName:nil operation:nil timeToLive:0 callback:callback];
}

+(void)requestSmsCodeWithPhoneNumber:(NSString *)phoneNumber
                             appName:(NSString *)appName
                           operation:(NSString *)operation
                          timeToLive:(NSUInteger)ttl
                            callback:(AVBooleanResultBlock)callback {
    NSParameterAssert(phoneNumber);
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    //    [dict setObject:phoneNumber forKey:@"mobilePhoneNumber"];
    if (appName) {
        [dict setObject:appName forKey:@"name"];
    }
    if (operation) {
        [dict setObject:operation forKey:@"op"];
    }
    if (ttl > 0) {
        [dict setObject:[NSNumber numberWithUnsignedInteger:ttl] forKey:@"ttl"];
    }
    [self requestSmsCodeWithPhoneNumber:phoneNumber templateName:nil variables:dict callback:callback];
}

+(void)requestSmsCodeWithPhoneNumber:(NSString *)phoneNumber
                        templateName:(NSString *)templateName
                           variables:(NSDictionary *)variables
                            callback:(AVBooleanResultBlock)callback {
    NSParameterAssert(phoneNumber);
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:phoneNumber forKey:@"mobilePhoneNumber"];
    if (templateName) {
        [dict setObject:templateName forKey:@"template"];
    }
    [dict addEntriesFromDictionary:variables];
    [[TGBPaasClient sharedInstance] postObject:@"requestSmsCode" withParameters:dict block:^(id object, NSError *error) {
        [TGBUtils callBooleanResultBlock:callback error:error];
    }];
}

+ (void)requestVoiceCodeWithPhoneNumber:(NSString *)phoneNumber
                                    IDD:(NSString *)IDD
                               callback:(AVBooleanResultBlock)callback {
    NSParameterAssert(phoneNumber);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"smsType"] = @"voice";
    params[@"mobilePhoneNumber"] = phoneNumber;
    
    if (IDD) {
        params[@"IDD"] = IDD;
    }
    
    [[TGBPaasClient sharedInstance] postObject:@"requestSmsCode" withParameters:params block:^(id object, NSError *error) {
        [TGBUtils callBooleanResultBlock:callback error:error];
    }];
}

+ (void)registerForRemoteNotification {
#if AV_TARGET_OS_IOS
    [self registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound categories:nil];
#elif AV_TARGET_OS_OSX
    [self registerForRemoteNotificationTypes:
     NSRemoteNotificationTypeAlert |
     NSRemoteNotificationTypeBadge |
     NSRemoteNotificationTypeSound categories:nil];
#endif
}

+ (void)registerForRemoteNotificationTypes:(NSUInteger)types categories:(NSSet *)categories {
#if AV_TARGET_OS_IOS
    UIApplication *application = [UIApplication sharedApplication];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        [application registerForRemoteNotificationTypes:types];
    } else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
        
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
#elif AV_TARGET_OS_OSX
    NSApplication *application = [NSApplication sharedApplication];
    [application registerForRemoteNotificationTypes:types];
#endif
}

@end
