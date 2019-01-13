//
//  TGBRelation_Internal.h
//  paas
//
//  Created by Zhu Zeng on 3/8/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import "TGBRelation.h"

@interface TGBRelation ()

@property (nonatomic, readwrite, copy) NSString * key;
@property (nonatomic, readwrite, weak) TGBObject * parent;

+(TGBRelation *)relationFromDictionary:(NSDictionary *)dict;

@end
