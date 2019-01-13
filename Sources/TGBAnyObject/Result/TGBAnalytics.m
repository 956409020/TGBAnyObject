//
//  TGBAnalytics.m
//  LeanCloud
//
//  Created by Zhu Zeng on 6/20/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import "TGBAnalytics.h"
#import "TGBAnalyticsImpl.h"
#import "TGBPaasClient.h"
#import "TGBAnalyticsUtils.h"
#import "TGBUtils.h"

#import "TGBCloud_Internal.h"
#import <CoreLocation/CoreLocation.h>

static NSString * endPoint = @"statistics";

static NSString * appOpen = @"!AV!AppOpen";
static NSString * appOpenWithPush = @"!AV!PushOpen";

static NSString * viewOpen = @"_viewOpen";
static NSString * viewClose = @"_viewClose";
static NSString * currentSessionId;


@implementation TGBAnalytics

+ (void)setChannel:(NSString *)channel
{
    [TGBAnalyticsImpl sharedInstance].appChannel = channel;
}

+ (void)setCustomInfo:(NSDictionary*)info{
    [TGBAnalyticsImpl sharedInstance].customInfo=info;
}

+ (void)trackAppOpenedWithLaunchOptions:(NSDictionary *)launchOptions
{
    [TGBAnalytics event:appOpen];
}

+ (void)trackAppOpenedWithRemoteNotificationPayload:(NSDictionary *)userInfo
{
    [TGBAnalytics event:appOpenWithPush];
}

+ (void)startInternallyWithChannel:(NSString *)cid
{
    if (cid.length > 0) {
        [TGBAnalyticsImpl sharedInstance].appChannel = cid;
    }
    
    BOOL enable = [TGBAnalyticsImpl sharedInstance].enableReport;
    
    if (enable) {
        //the session is started at after app launch, so we just make it still
        if ([[TGBAnalyticsImpl sharedInstance] currentSession]==nil) {
            [[TGBAnalyticsImpl sharedInstance] beginSession];
        }
        
    } else {
        [self stop];
        
    }
    
}

+ (void)stop{
    [[TGBAnalyticsImpl sharedInstance] stopRun];
}

+(void)setLogEnabled:(BOOL)value
{
    [TGBAnalyticsImpl sharedInstance].enableDebugLog = value;
}

+ (void)setLogSendInterval:(double)second {
    if (second < 10 || second >= 60 * 60 * 24) {
        second = 10;
    }
    [TGBAnalyticsImpl sharedInstance].sendInterval = second;
}

+(void)setAnalyticsEnabled:(BOOL)value
{
    [TGBAnalyticsImpl sharedInstance].enableAnalytics = value;
}

+(void)setCrashReportEnabled:(BOOL)value
{
    [TGBAnalyticsImpl sharedInstance].enableCrashReport = value;
}

+(void)setCrashReportEnabled:(BOOL)value completion:(void (^)(void))completion {
    [[TGBAnalyticsImpl sharedInstance] setEnableCrashReport:value completion:completion];
}

+ (void)setCrashReportEnabled:(BOOL)value andIgnore:(BOOL)ignore {
    [[self class] setCrashReportEnabled:value];
    [TGBAnalyticsImpl sharedInstance].enableIgnoreCrash = ignore;
}

+ (void)setCrashReportEnabled:(BOOL)value withIgnoreAlertTitle:(NSString*)alertTitle andMessage:(NSString*)alertMsg andQuitTitle:(NSString*)alertQuit andContinueTitle:(NSString*)alertContinue {
    [[self class] setCrashReportEnabled:value];
    if (value) {
        [TGBAnalyticsImpl sharedInstance].enableIgnoreCrash = YES;
        
        NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithCapacity:5];
        if (alertTitle) [dict setObject:alertTitle forKey:@"title"];
        if (alertMsg)   [dict setObject:alertMsg forKey:@"msg"];
        if (alertQuit)  [dict setObject:alertQuit forKey:@"quit"];
        if (alertContinue) [dict setObject:alertContinue forKey:@"continue"];
        
        if (dict.count>0) {
            [TGBAnalyticsImpl sharedInstance].ignoreCrashAlertStrings = dict;
        }
    }
}

+ (void)logPageView:(NSString *)pageName seconds:(int)seconds
{
    [[TGBAnalyticsImpl sharedInstance] addActivity:pageName seconds:seconds];
}

+ (void)beginLogPageView:(NSString *)pageName
{
    [[TGBAnalyticsImpl sharedInstance] beginActivity:pageName];
}

+ (void)endLogPageView:(NSString *)pageName
{
    [[TGBAnalyticsImpl sharedInstance] endActivity:pageName];
}

+ (void)event:(NSString *)eventId
{
    [[TGBAnalyticsImpl sharedInstance] addEvent:eventId label:nil key:nil acc:1 du:0 attributes:nil];
}

+ (void)event:(NSString *)eventId label:(NSString *)label
{
    [[TGBAnalyticsImpl sharedInstance] addEvent:eventId label:label key:nil acc:1 du:0 attributes:nil];
}

+ (void)event:(NSString *)eventId acc:(NSInteger)accumulation
{
     [[TGBAnalyticsImpl sharedInstance] addEvent:eventId label:nil key:nil acc:accumulation du:0 attributes:nil];
}

+ (void)event:(NSString *)eventId label:(NSString *)label acc:(NSInteger)accumulation
{
    [[TGBAnalyticsImpl sharedInstance] addEvent:eventId label:label key:nil acc:accumulation du:0 attributes:nil];
}

+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes
{
    [[TGBAnalyticsImpl sharedInstance] addEvent:eventId label:nil key:nil acc:1 du:0 attributes:attributes];
}

+ (void)beginEvent:(NSString *)eventId {
    [[TGBAnalyticsImpl sharedInstance] beginEvent:eventId label:nil key:nil attributes:nil];
}

+ (void)endEvent:(NSString *)eventId {
    [[TGBAnalyticsImpl sharedInstance] endEvent:eventId label:nil key:nil attributes:nil];
}

+ (void)beginEvent:(NSString *)eventId label:(NSString *)label {
    [[TGBAnalyticsImpl sharedInstance] beginEvent:eventId label:label key:nil attributes:nil];
}

+ (void)endEvent:(NSString *)eventId label:(NSString *)label {
    [[TGBAnalyticsImpl sharedInstance] endEvent:eventId label:label key:nil attributes:nil];
}

+ (void)beginEvent:(NSString *)eventId primarykey :(NSString *)keyName attributes:(NSDictionary *)attributes {
    [[TGBAnalyticsImpl sharedInstance] beginEvent:eventId label:nil key:keyName attributes:attributes];
}

+ (void)endEvent:(NSString *)eventId primarykey:(NSString *)keyName {
    [[TGBAnalyticsImpl sharedInstance] endEvent:eventId label:nil key:keyName attributes:nil];
}

+ (void)event:(NSString *)eventId durations:(int)millisecond {
    [[TGBAnalyticsImpl sharedInstance] addEvent:eventId label:nil key:nil acc:1 du:millisecond attributes:nil];
}

+ (void)event:(NSString *)eventId label:(NSString *)label durations:(int)millisecond {
    [[TGBAnalyticsImpl sharedInstance] addEvent:eventId label:nil key:nil acc:1 du:millisecond attributes:nil];
}

+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes durations:(int)millisecond {
    [[TGBAnalyticsImpl sharedInstance] addEvent:eventId label:nil key:nil acc:1 du:millisecond attributes:attributes];
}

+ (void)updateOnlineConfig
{
    [TGBAnalytics updateOnlineConfigWithBlock:nil];
}

+ (void)updateOnlineConfigWithBlock:(AVDictionaryResultBlock)block {
    NSString *path = [NSString stringWithFormat:@"statistics/apps/%@/sendPolicy", [TGBKKit getApplicationId]];
    
    [[TGBPaasClient sharedInstance] getObject:path withParameters:nil block:^(id object, NSError *error) {
        if (error == nil) {
            // make sure we call the onlineConfigChanged in main thread
            // otherwise timer may not work correctly.
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TGBAnalyticsImpl sharedInstance] onlineConfigChanged:object];
            });
        } else {
//            AVLoggerE(@"Update online config failed %@", error);
        }

        [TGBUtils callIdResultBlock:block object:object error:error];
    }];
}

+ (id)getConfigParams:(NSString *)key {
    return [[TGBAnalyticsImpl sharedInstance].onlineConfig objectForKey:key];
}

+ (NSDictionary *)getConfigParams {
    return [TGBAnalyticsImpl sharedInstance].onlineConfig;
}

+ (void)setLatitude:(double)latitude longitude:(double)longitude {
    [[TGBAnalyticsImpl sharedInstance] setLatitude:latitude longitude:longitude];
}

+ (void)setLocation:(CLLocation *)location {
    [[TGBAnalyticsImpl sharedInstance] setLatitude:location.coordinate.latitude
                                        longitude:location.coordinate.longitude];
}

+(void)startInternally {
    if ([[TGBAnalyticsImpl sharedInstance] isLocalEnabled]) {
        [TGBAnalytics startInternallyWithChannel:@""];
    }
    
    [TGBAnalytics updateOnlineConfigWithBlock:^(NSDictionary *dict, NSError *error) {
        [TGBAnalytics startInternallyWithChannel:@""];
    }];
}


@end
