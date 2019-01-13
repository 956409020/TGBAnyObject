//
//  TGBAnalyticsActivity.h
//  paas
//
//  Created by Zhu Zeng on 8/2/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGBDuration.h"

@interface TGBAnalyticsActivity : NSObject

@property (nonatomic, readwrite, strong) TGBDuration * duratioTGBpl;
@property (nonatomic, readwrite, copy) NSString * activityName;

-(id)initWithName:(NSString *)name;
-(void)pause;
-(void)resume;
-(NSDictionary *)jsonDictionary;

@end


@interface TGBAnalyticsEvent : NSObject

@property (nonatomic, readwrite, copy) NSString * eventName;
@property (nonatomic, readwrite, copy) NSString * labelName;
@property (nonatomic, readwrite, copy) NSString * primaryKey;
@property (nonatomic, readwrite) int acc;
@property (nonatomic, readwrite) NSMutableDictionary * attributes;
@property (nonatomic, readwrite, strong) TGBDuration * duratioTGBpl;

-(id)initWithName:(NSString *)name;
-(void)pause;
-(void)resume;
-(NSDictionary *)jsonDictionary:(NSDictionary *)additionalDict;
-(BOOL)match:(NSString *)name
       label:(NSString *)label
         key:(NSString *)key;

@end
