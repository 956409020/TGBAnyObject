//
//  TGBRequestOperation.h
//  AVOSCloud
//
//  Created by Zhu Zeng on 7/9/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGBConstants.h"

@interface TGBRequestOperation : NSObject

@property (nonatomic, readwrite, strong) NSMutableArray * batchRequest;
@property (nonatomic, readwrite, copy) AVBooleanResultBlock block;
@property (nonatomic, readwrite) int sequence;

+(TGBRequestOperation *)operation:(NSArray *)request;

@end


@interface TGBRequestOperationQueue : NSObject

@property (nonatomic, readwrite) NSMutableArray * queue;
@property (nonatomic, readwrite) int currentSequence;

-(void)increaseSequence;
-(TGBRequestOperation *)addOperation:(NSArray *)request
                   withBlock:(AVBooleanResultBlock)block;
-(TGBRequestOperation *)popHead;
-(BOOL)noPendingRequest;
-(void)clearOperationWithSequence:(int)seq;

@end
