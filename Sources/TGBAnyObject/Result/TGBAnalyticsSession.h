//
//  TGBAnalyticsSession.h
//  paas
//
//  Created by Zhu Zeng on 8/15/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGBDuration.h"

@interface TGBAnalyticsSession : NSObject

@property (nonatomic, readwrite, strong) NSMutableArray * activities;
@property (nonatomic, readwrite, strong) NSMutableArray * events;
@property (nonatomic, readwrite, copy) NSString * sessionId;
@property (nonatomic, readwrite, copy) NSString * currentActivityName;
@property (nonatomic, readwrite, strong) TGBDuration * duratioTGBpl;

-(void)beginSession;
-(void)endSession;
-(void)pauseSession;
-(void)resumeSession;
-(void)sync;
-(BOOL)isStoppped;

-(void)addActivity:(NSString *)name seconds:(int)seconds;
-(void)beginActivity:(NSString *)name;
-(void)endActivity:(NSString *)name;

-(void)addEvent:(NSString *)eventId
          label:(NSString *)label
            key:(NSString *)key
            acc:(NSInteger)acc
             du:(int)du
     attributes:(NSDictionary *)attributes;

-(void)beginEvent:(NSString *)name
            label:(NSString *)label
              key:(NSString *)key
       attributes:(NSDictionary *)attributes;

-(void)endEvent:(NSString *)name
          label:(NSString *)label
     primaryKey:(NSString *)key
     attributes:(NSDictionary *)attributes;

-(TGBAnalyticsEvent *)eventByName:(NSString *)name
                           label:(NSString *)label
                             key:(NSString *)key
                          create:(BOOL)create;

-(NSDictionary *)jsonDictionary:(NSDictionary *)additionalInfo;

@end
