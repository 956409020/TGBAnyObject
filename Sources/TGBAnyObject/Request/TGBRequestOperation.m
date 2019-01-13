//
//  TGBRequestOperation.m
//  AVOSCloud
//
//  Created by Zhu Zeng on 7/9/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import "TGBRequestOperation.h"

@implementation TGBRequestOperation

-(id)init
{
    self = [super init];
    _batchRequest = [[NSMutableArray alloc] init];
    return self;
}

+(TGBRequestOperation *)operation:(NSArray *)request
{
    TGBRequestOperation * operation = [[TGBRequestOperation alloc] init];
    [operation.batchRequest addObjectsFromArray:request];
    return operation;
}

@end

@implementation TGBRequestOperationQueue

@synthesize queue = _queue;

-(id)init
{
    self = [super init];
    _queue = [[NSMutableArray alloc] init];
    return self;
}

-(void)increaseSequence
{
    self.currentSequence += 2;
}

-(TGBRequestOperation *)addOperation:(NSArray *)request
                   withBlock:(AVBooleanResultBlock)block
{
    TGBRequestOperation * operation = [TGBRequestOperation operation:[request mutableCopy]];
    operation.sequence = self.currentSequence;
    operation.block = block;
    [self.queue addObject:operation];
    [self increaseSequence];
    return operation;
}

-(TGBRequestOperation *)popHead
{
    if (self.queue.count > 0) {
        TGBRequestOperation * operation = [self.queue objectAtIndex:0];
        [self.queue removeObjectAtIndex:0];
        return operation;
    }
    return nil;
}

-(BOOL)noPendingRequest
{
    return (self.queue.count <= 0);
}

-(void)clearOperationWithSequence:(int)seq
{
    NSMutableArray *discardedItems = [NSMutableArray array];
    for (TGBRequestOperation * operation in self.queue) {
        if (operation.sequence == seq)
            [discardedItems addObject:operation];
    }
    
    [self.queue removeObjectsInArray:discardedItems];
}

@end

