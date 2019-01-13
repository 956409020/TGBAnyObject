//
//  TGBLocationManager.h
//  paas
//
//  Created by Summer on 13-3-16.
//  Copyright (c) 2013年 AVOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TGBGeoPoint,CLLocation,CLLocationManager;


/**
 *  管理地理位置
 */
@interface TGBLocationManager : NSObject

/**
 *  系统的 CLLocationManager
 */
@property (nonatomic, strong, readonly) CLLocationManager *locationManager;

/**
 *  最后一次获取到的地理位置
 */
@property (nonatomic, strong, readonly) CLLocation *lastLocation;

+ (TGBLocationManager *)sharedInstance;

/**
 *  刷新当前地理位置
 *
 *  @param block 回调结果
 */
- (void)updateWithBlock:(void(^)(TGBGeoPoint *geoPoint, NSError *error))block;

@end
