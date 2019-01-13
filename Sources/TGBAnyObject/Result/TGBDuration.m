//
//  TGBDuration.m
//  paas
//
//  Created by Zhu Zeng on 10/10/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import "TGBDuration.h"

@interface TGBDuration()

@property (nonatomic, readwrite) BOOL stopped;
@property (nonatomic, readwrite) NSTimeInterval createTimeStamp; // Millis Seconds

@end

@implementation TGBDuration

@synthesize userDuration = _userDuration;

-(id)init {
    self = [super init];
    [self start];
    _duration  = 0;
    _userDuration = -1.0;
    return self;
}

-(void)start {
    self.stopped = NO;
    self.createTimeStamp = [TGBDuration currentTS];
    self.resumeTimeStamp = self.createTimeStamp;
}

-(void)resume {
    if (self.stopped) {
        return;
    }
    self.resumeTimeStamp = [TGBDuration currentTS];
}

-(void)pause {
    [self sync];
}

-(void)sync {
    if (self.stopped) {
        return;
    }
    NSTimeInterval d = [TGBDuration currentTS] - self.resumeTimeStamp;
    _duration  += d;
    self.resumeTimeStamp = [TGBDuration currentTS];
}

-(void)stop {
    [self sync];
    self.stopped = YES;
}

-(BOOL)isStopped {
    return self.stopped;
}

-(void)setDurationWithMilliSeconds:(long)ms {
    _userDuration = ms;
}

-(void)addDurationWithMilliSeconds:(long)ms {
    _userDuration += ms;
}

+(NSTimeInterval)currentTS {
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    return seconds * 1000;
}

-(NSTimeInterval)createTimeStampInMilliSeconds {
    return self.createTimeStamp;
}

/// more than 3 hours
+(NSTimeInterval)durationThreshold {
    return 3600 * 1000 * 3;
}

/// 2 minutes
+(NSTimeInterval)defaultDuration {
    return 60 * 2 * 1000;
}

-(NSTimeInterval)duration {
    // could be zero.
    if (_userDuration >= 0) {
        return _userDuration;
    }
    
    [self sync];
    
    if (_duration <= 0) {
        return ([TGBDuration currentTS] - self.resumeTimeStamp);
    }
    
    if (_duration > [TGBDuration durationThreshold]) {
        _duration = [TGBDuration defaultDuration];
    }
    return _duration;
}


@end
