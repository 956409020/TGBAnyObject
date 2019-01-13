//
//  TGBNetworkStatistics.h
//  AVOS
//
//  Created by Tang Tianyong on 6/26/15.
//  Copyright (c) 2015 LeanCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGBNetworkStatistics : NSObject

@property (nonatomic, assign) BOOL ignoreAlwaysCollectIfCustomedService;

+ (instancetype)sharedInstance;

- (void)addIncrementalAttribute:(NSInteger)amount forKey:(NSString *)key;
- (void)addAverageAttribute:(double)amount forKey:(NSString *)key;

- (void)start;
- (void)stop;

@end
