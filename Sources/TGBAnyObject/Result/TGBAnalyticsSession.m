
//
//  TGBAnalyticsSession.m
//  paas
//
//  Created by Zhu Zeng on 8/15/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import "TGBAnalyticsImpl.h"
#import "TGBAnalyticsSession.h"
#import "TGBAnalyticsUtils.h"



@implementation TGBAnalyticsSession

-(instancetype)init
{
    self = [super init];
    _sessionId = [TGBAnalyticsUtils randomString:AV_SESSIONID_LENGTH];
    _activities = [[NSMutableArray alloc] init];
    _events = [[NSMutableArray alloc] init];
    _duratioTGBpl = [[TGBDuration alloc] init];
    return self;
}

-(void)beginSession
{
    [self.duratioTGBpl resume];
}

-(void)endSession
{
    [self.duratioTGBpl stop];
}

-(BOOL)isStoppped {
    return [self.duratioTGBpl isStopped];
}

-(void)pauseSession
{
    [self.duratioTGBpl pause];
    for(TGBAnalyticsActivity * a in [self.activities copy]) {
        [a pause];
    }
    for(TGBAnalyticsEvent * e in [self.events copy]) {
        [e pause];
    }
}

-(void)resumeSession
{
    [self.duratioTGBpl resume];
    for(TGBAnalyticsActivity * a in [self.activities copy]) {
        [a resume];
    }
    for(TGBAnalyticsEvent * event in [self.events copy]) {
        [event resume];
    }
}

-(void)sync {
    [self.duratioTGBpl sync];
    for(TGBAnalyticsActivity * a in [self.activities copy]) {
        [a.duratioTGBpl sync];
    }
    for(TGBAnalyticsEvent * event in [self.events copy]) {
        [event.duratioTGBpl sync];
    }
}

-(TGBAnalyticsActivity *)activityByName:(NSString *)name
                                create:(BOOL)create
{
    for(TGBAnalyticsActivity * activity in [self.activities copy]) {
        if ([activity.activityName isEqualToString:name] &&
            ![activity.duratioTGBpl isStopped]) {
            return activity;
        }
    }
    TGBAnalyticsActivity * activity = nil;
    if (create) {
        activity = [[TGBAnalyticsActivity alloc] initWithName:name];
        [self.activities addObject:activity];
    }
    return activity;
}

-(TGBAnalyticsEvent *)eventByName:(NSString *)name
                           label:(NSString *)label
                             key:(NSString *)key
                          create:(BOOL)create
{
    for(TGBAnalyticsEvent * event in [self.events copy]) {
        if ([event match:name label:label key:key]) {
            return event;
        }
    }
    TGBAnalyticsEvent * event = nil;
    if (create) {
        event = [[TGBAnalyticsEvent alloc] initWithName:name];
        [self.events addObject:event];
    }
    return event;
}

- (void)addActivity:(NSString *)name seconds:(int)seconds
{
    TGBAnalyticsActivity * activity = [self activityByName:name create:YES];
    [activity.duratioTGBpl setDurationWithMilliSeconds:seconds * 1000];
}

-(void)beginActivity:(NSString *)name
{
    TGBAnalyticsActivity * activity = [self activityByName:name create:YES];
    [activity.duratioTGBpl start];
    self.currentActivityName = name;
}

-(void)endActivity:(NSString *)name
{
    TGBAnalyticsActivity * activity = [self activityByName:name create:NO];
    if (activity == nil) {
        // wrong.
//        NSLog(@"The beginning of analytics session \"%@\" not found.", name);
        return;
    }
    [activity.duratioTGBpl stop];
    self.currentActivityName = @"";
}

-(void)addEvent:(NSString *)name
          label:(NSString *)label
            key:(NSString *)key
            acc:(NSInteger)acc
             du:(int)du
     attributes:(NSDictionary *)attributes
{
    TGBAnalyticsEvent * event = [self eventByName:name label:label key:key create:YES];
    event.labelName = label;
    event.primaryKey = key;
    if (acc <= 0) {
        event.acc = 1;
    } else {
        event.acc = (int)acc;
    }
    
    @try {
        [event.attributes addEntriesFromDictionary:attributes];
    }
    @catch (NSException *exception) {
        
    }
    [event.duratioTGBpl start];
    [event.duratioTGBpl setDurationWithMilliSeconds:du];
    [event.duratioTGBpl stop];
}

-(void)beginEvent:(NSString *)name
            label:(NSString *)label
              key:(NSString *)key
       attributes:(NSDictionary *)attributes {
    TGBAnalyticsEvent * event = [self eventByName:name label:label key:key create:YES];
    event.labelName = label;
    event.primaryKey = key;
    [event.attributes addEntriesFromDictionary:attributes];
    [event.duratioTGBpl start];
}


-(void)endEvent:(NSString *)name
          label:(NSString *)label
     primaryKey:(NSString *)key
     attributes:(NSDictionary *)attributes {
    
    TGBAnalyticsEvent * event = [self eventByName:name label:label key:key create:NO];
    if (event == nil) {
        // wrong.
//        NSLog(@"Please call beginEvent at first.");
        return;
    }
    if (label)   {
        event.labelName = label;
    }
    
    if (key) {
        event.primaryKey = key;
    }
    [event.attributes addEntriesFromDictionary:attributes];
    [event.duratioTGBpl stop];
}

-(NSDictionary *)launchDictionary
{
    return @{kAVSessionIdTag:[TGBAnalyticsUtils safeString:self.sessionId],
             kAVDateTag: @([self.duratioTGBpl createTimeStampInMilliSeconds])};
}

-(long)duration
{
    return [self.duratioTGBpl duration];
}

-(NSDictionary *)activitiesDictionary
{
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:self.activities.count];
    for(TGBAnalyticsActivity * a in [self.activities copy]) {
        [array addObject:[a jsonDictionary]];
    }
    return @{kAVActivitiesTag: array,
             kAVSessionIdTag: [TGBAnalyticsUtils safeString:self.sessionId],
             kTGBDurationTag: @([self duration])};
}

-(NSArray *)eventsDictionary
{
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:self.events.count];
    NSDictionary * dict = @{kAVSessionIdTag: [TGBAnalyticsUtils safeString:self.sessionId]};
    for(TGBAnalyticsEvent * event in [self.events copy]) {
        [array addObject:[event jsonDictionary:dict]];
    }
    return array;
}

-(NSDictionary *)jsonDictionary:(NSDictionary *)additionalDeviceInfo
{
    NSMutableDictionary * deviceInfo = [TGBAnalyticsUtils deviceInfo];
    [deviceInfo addEntriesFromDictionary:additionalDeviceInfo];
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:@{@"events": @{@"launch": [self launchDictionary],
                                                                                              @"terminate": [self activitiesDictionary],
                                                                                              @"event": [self eventsDictionary]},
                                                                                 @"device": deviceInfo}];
    
    if ([TGBAnalyticsImpl sharedInstance].customInfo!=nil) {
        [dict setObject:[TGBAnalyticsImpl sharedInstance].customInfo forKey:@"customInfo"];
    }
    return dict;
}


@end
