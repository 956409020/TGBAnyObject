//
//  TGBFileQuery.m
//  AVOS-DynamicFramework
//
//  Created by lzw on 15/10/8.
//  Copyright © 2015年 tang3w. All rights reserved.
//

#import "TGBFileQuery.h"
#import "TGBFile.h"
#import "TGBQuery_Internal.h"
#import "TGBUtils.h"

@implementation TGBFileQuery

+ (instancetype)query {
    return [self queryWithClassName:@"_File"];
}
- (NSArray *)filesWithObjects:(NSArray *)objects {
    if (objects == nil) {
        return nil;
    }
    NSMutableArray *files = [NSMutableArray arrayWithCapacity:objects.count];
    for (TGBObject *object in [objects copy]) {
        TGBFile *file = [TGBFile fileWithTGBObject:object];
        [files addObject:file];
    }
    return files;
}

- (void)getFileInBackgroundWithId:(NSString *)objectId
                            block:(TGBFileResultBlock)block {
    [self getObjectInBackgroundWithId:objectId block:^(TGBObject *object, NSError *error) {
        TGBFile *file = nil;
        if (!error) {
            file = [TGBFile fileWithTGBObject:object];
        }
        [TGBUtils callFileResultBlock:block TGBFile:file error:error];
    }];
}

- (TGBFile *)getFileWithId:(NSString *)objectId error:(NSError **)error {
    TGBObject *object = [self getObjectWithId:objectId error:error];
    TGBFile *file = nil;
    if (object != nil) {
        file = [TGBFile fileWithTGBObject:object];
    }
    return file;
}

- (NSArray *)findFiles:(NSError **)error {
    NSArray *objects = [super findObjects:error];
    return [self filesWithObjects:objects];
}

- (void)findFilesInBackgroundWithBlock:(AVArrayResultBlock)resultBlock {
    [self findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSArray *files = [self filesWithObjects:objects];
        [TGBUtils callArrayResultBlock:resultBlock array:files error:error];
    }];
}

@end
