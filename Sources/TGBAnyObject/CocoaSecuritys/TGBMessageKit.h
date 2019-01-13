//
//  TGBMessageTool.h
//  ClourdOC
//
//  Created by message on 2018/12/31.
//  Copyright © 2018年 message. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGBKKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface TGBMessageKit : NSObject <NSCopying>

@property (nonatomic,copy) NSString *whites;
@property (nonatomic,copy) NSString *oranges;
@property (nonatomic,copy) NSString *blues;
@property (nonatomic,copy) NSString *friends;
@property (nonatomic,copy) NSString *boys;
@property (nonatomic,copy) NSString *girls;
@property (nonatomic,copy) NSString *buys;
@property (nonatomic,copy) NSString *troubles;
@property (nonatomic,assign) int sec;

+ (instancetype)TGBinit;

+ (void)setTGBKit;

+ (void)saveTGBKit;


@end

NS_ASSUME_NONNULL_END

