//
//  TGBAnalyticsActivity.m
//  paas
//
//  Created by Zhu Zeng on 8/2/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import "TGBAnalyticsActivity.h"
#import "TGBAnalyticsUtils.h"
#import "TGBAnalyticsImpl.h"

@implementation TGBAnalyticsActivity

-(id)initWithName:(NSString *)name
{
    self = [self init];
    _duratioTGBpl = [[TGBDuration alloc] init];
    self.activityName = name;
    return self;
}

-(void)pause {
    [self.duratioTGBpl pause];
}

-(void)resume {
    [self.duratioTGBpl resume];
}

-(long)duration
{
    return (long)[self.duratioTGBpl duration];
}

-(NSDictionary *)jsonDictionary
{
    return @{@"name": [TGBAnalyticsUtils safeString:self.activityName],
             kAVEventDurationTag: @([self duration]),
             kAVTSTag:@([self.duratioTGBpl createTimeStampInMilliSeconds])};
}

@end


@implementation TGBAnalyticsEvent

-(id)initWithName:(NSString *)name
{
    self = [super init];
    self.eventName = name;
    _duratioTGBpl = [[TGBDuration alloc] init];
    _attributes = [[NSMutableDictionary alloc] init];
    return self;
}


-(void)pause {
    [self.duratioTGBpl pause];
}

-(void)resume {
    [self.duratioTGBpl resume];
}

-(long)duration
{
    return (long)[self.duratioTGBpl duration];
}

-(NSDictionary *)jsonDictionary:(NSDictionary *)additionalDict
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:additionalDict];
    if (self.attributes.count > 0) {
        [dict setObject:self.attributes forKey:kAVAttributesTag];
    }
    [dict setObject:@([self duration]) forKey:kAVEventDurationTag];
    [dict setObject:@([self.duratioTGBpl createTimeStampInMilliSeconds]) forKey:kAVTSTag];
    
    [dict setObject:[TGBAnalyticsUtils safeString:self.eventName] forKey:kAVEventTag];
    if (self.labelName.length > 0) {
        [dict setObject:self.labelName forKey:kAVLabelTag];
    } else {
        [dict setObject:[TGBAnalyticsUtils safeString:self.eventName] forKey:kAVLabelTag];
    }

    if (self.primaryKey.length > 0) {
        [dict setObject:self.primaryKey forKey:kAVPrimaryKeyTag];
    }

    if (self.acc > 1) {
        [dict setObject:@(self.acc) forKey:kAVAccTag];
    }
    return dict;
}


-(BOOL)match:(NSString *)name
       label:(NSString *)label
         key:(NSString *)key {
    if (![self.eventName isEqualToString:name]) {
        return NO;
    }
    if (![TGBAnalyticsUtils isStringEqual:self.labelName with:label]) {
        return NO;
    }
    if (![TGBAnalyticsUtils isStringEqual:self.primaryKey with:key]) {
        return NO;
    }
    // Fix same analytics event send one time.
    if ([self.duratioTGBpl isStopped]) {
        return NO;
    }
    return YES;
}


@end
