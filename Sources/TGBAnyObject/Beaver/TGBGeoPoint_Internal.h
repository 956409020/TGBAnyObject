//
//  TGBGeoPoint_Internal.h
//  paas
//
//  Created by Zhu Zeng on 3/12/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import "TGBGeoPoint.h"

@interface TGBGeoPoint ()

+(NSDictionary *)dictionaryFromGeoPoint:(TGBGeoPoint *)point;
+(TGBGeoPoint *)geoPointFromDictionary:(NSDictionary *)dict;

@end
