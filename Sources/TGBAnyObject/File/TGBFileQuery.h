//
//  TGBFileQuery.h
//  AVOS-DynamicFramework
//
//  Created by lzw on 15/10/8.
//  Copyright © 2015年 tang3w. All rights reserved.
//

#import "TGBQuery.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  TGBFile 查询类
 */
@interface TGBFileQuery : TGBQuery

+ (instancetype)query;

/**
 *  查找一组文件，同步方法
 *  @param error 通常是网络错误或者查找权限未开启
 *  @return 返回一组 TGBFile 对象
 */
- (nullable NSArray *)findFiles:(NSError **)error;

/**
 *  查找一组文件，异步方法
 *  @see findFiles:
 *  @param resultBlock 回调 block
 */
- (void)findFilesInBackgroundWithBlock:(AVArrayResultBlock)resultBlock;


/**
 *  根据 objectId 来查找文件，同步方法
 *  @param objectId 目标文件的 objectId
 *  @param error    通过是网络错误或查找权限未开启
 *  @return 返回 TGBFile 对象
 */
- (nullable TGBFile *)getFileWithId:(NSString *)objectId error:(NSError **)error;

/**
 *  根据 objectId 来查找文件，异步方法
 *  @see getFileWithId:error
 *  @param objectId 目标文件的 objectId
 *  @param block    回调 block
 */
- (void)getFileInBackgroundWithId:(NSString *)objectId
                            block:(TGBFileResultBlock)block;


@end

NS_ASSUME_NONNULL_END
