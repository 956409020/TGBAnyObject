//
//  TGBStatus.m
//  paas
//
//  Created by Travis on 13-12-23.
//  Copyright (c) 2013年 AVOS. All rights reserved.
//

#import "TGBStatus.h"
#import "TGBPaasClient.h"
#import "TGBErrorUtils.h"
#import "TGBObjectUtils.h"
#import "TGBObject_Internal.h"
#import "TGBQuery_Internal.h"
#import "TGBMacros.h"
#import "TGBUtils.h"
#import "TGBUsered_Internal.h"

NSString * const kTGBStatusTypeTimeline=@"default";
NSString * const kTGBStatusTypePrivateMessage=@"private";

@interface TGBStatus () {
    
}
@property (nonatomic,   copy) NSString *objectId;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, assign) NSUInteger messageId;

/* 用Query来设定受众群 */
@property(nonatomic,strong) TGBQuery *targetQuery;

+(NSString*)parseClassName;

+(TGBStatus*)statusFromCloudData:(NSDictionary*)data;

@end

@implementation TGBQuery (Status)

-(NSDictionary*)dictionaryForStatusRequest{
    NSMutableDictionary *dict=[[self assembleParameters] mutableCopy];
    [dict setObject:self.className forKey:@"className"];
    
    //`where` here is a string, but the server ask for dictionary
    [dict removeObjectForKey:@"where"];
    [dict setObject:[TGBObjectUtils dictionaryFromDictionary:self.where] forKey:@"where"];
    return dict;
}
@end


@interface TGBStatusQuery ()
@property(nonatomic,copy) NSString *externalQueryPath;
@end

@implementation TGBStatusQuery

- (id)init
{
    self = [super initWithClassName:[TGBStatus parseClassName]];
    if (self) {
        
    }
    return self;
}

- (NSString *)queryPath {
    return self.externalQueryPath?self.externalQueryPath:[super queryPath];
}


- (NSMutableDictionary *)assembleParameters {
    BOOL handleInboxType=NO;
    if (self.inboxType) {
        if (self.externalQueryPath) {
            handleInboxType=YES;
        } else {
            [self whereKey:@"inboxType" equalTo:self.inboxType];
        }
        
    }
    [super assembleParameters];
    
    if (self.sinceId > 0)
    {
        [self.parameters setObject:@(self.sinceId) forKey:@"sinceId"];
    }
    if (self.maxId > 0)
    {
        [self.parameters setObject:@(self.maxId) forKey:@"maxId"];
    }
    
    if (self.owner) {
        [self.parameters setObject:[TGBObjectUtils dictionaryFromTGBObjectPointer:self.owner] forKey:@"owner"];
    }
    
    if (handleInboxType) {
        [self.parameters setObject:self.inboxType forKey:@"inboxType"];
    }
    
    return self.parameters;
}

-(void)queryWithBlock:(NSString *)path
           parameters:(NSDictionary *)parameters
                block:(AVArrayResultBlock)resultBlock {
    _end = NO;
    [super queryWithBlock:path parameters:parameters block:resultBlock];
}

- (TGBObject *)getFirstObjectWithBlock:(TGBObjectResultBlock)resultBlock
                        waitUntilDone:(BOOL)wait
                                error:(NSError **)theError {
    _end = NO;
    return [super getFirstObjectWithBlock:resultBlock waitUntilDone:wait error:theError];
}

// only called in findobjects, these object's data is ready
- (NSMutableArray *)processResults:(NSArray *)results className:(NSString *)className
{
    
    NSMutableArray *statuses=[NSMutableArray arrayWithCapacity:[results count]];
    
    for (NSDictionary *info in results) {
        [statuses addObject:[TGBStatus statusFromCloudData:info]];
    }
    [statuses sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"messageId" ascending:NO]]];
    return statuses;
}

- (void)processEnd:(BOOL)end {
    _end = end;
}
@end



@implementation TGBStatus

+(NSString*)parseClassName{
    return @"_Status";
}

+ (NSString *)statusInboxPath {
    return @"subscribe/statuses/inbox";
}

+(TGBStatus*)statusFromCloudData:(NSDictionary*)data{
    if ([data isKindOfClass:[NSDictionary class]] && data[@"objectId"]) {
        TGBStatus *status=[[TGBStatus alloc] init];
        
        status.objectId=data[@"objectId"];
        status.type=data[@"inboxType"];
        status.createdAt=[TGBObjectUtils dateFromString:data[@"createdAt"]];
        status.messageId=[data[@"messageId"] integerValue];
        status.source=[TGBObjectUtils TGBObjectFromDictionary:data[@"source"]];
        
        NSMutableDictionary *newData=[data mutableCopy];
        [newData removeObjectsForKeys:@[@"inboxType",@"objectId",@"createdAt",@"updatedAt",@"messageId",@"source"]];
        
        status.data=newData;
        return status;
    }
    
    return nil;
}

+(NSError*)permissionCheck{
    if (![[TGBUsered currentUser] isAuthDataExistInMemory]) {
        return LCError(kAVErrorUserCannotBeAlteredWithoutSession, nil, nil);
    }
    
    return nil;
}

+(NSString*)stringOfStatusOwner:(NSString*)userObjectId{
    if (userObjectId) {
        NSString *info=[NSString stringWithFormat:@"{\"__type\":\"Pointer\", \"className\":\"_User\", \"objectId\":\"%@\"}",userObjectId];
        return info;
    }
    return nil;
}


#pragma mark - 查询


+(TGBStatusQuery*)inboxQuery:(TGBStatusType *)inboxType{
    TGBStatusQuery *query=[[TGBStatusQuery alloc] init];
    query.owner=[TGBUsered currentUser];
    query.inboxType=inboxType;
    query.externalQueryPath= @"subscribe/statuses";
    return query;
}


+(TGBStatusQuery*)statusQuery{
    TGBStatusQuery *q=[[TGBStatusQuery alloc] init];
    [q whereKey:@"source" equalTo:[TGBUsered currentUser]];
    return q;
}

+(void)getStatusesWithType:(TGBStatusType*)type skip:(NSUInteger)skip limit:(NSUInteger)limit andCallback:(AVArrayResultBlock)callback{
    NSParameterAssert(type);
    
    NSError *error=[self permissionCheck];
    if (error) {
        callback(nil,error);
        return;
    }
    
    if (limit>100 || limit<=0) {
        limit=100;
    }
    
    TGBStatusQuery *q=[TGBStatus inboxQuery:type];
    q.limit=limit;
    q.skip=skip;
    [q findObjectsInBackgroundWithBlock:callback];
    
}
+(void) getStatusesFromCurrentUserWithType:(TGBStatusType*)type skip:(NSUInteger)skip limit:(NSUInteger)limit andCallback:(AVArrayResultBlock)callback{
    
    NSError *error=[self permissionCheck];
    if (error) {
        callback(nil,error);
        return;
    }
    
    [self getStatusesFromUser:[TGBUsered currentUser].objectId skip:skip limit:limit andCallback:callback];
    
}
+(void)getStatusesFromUser:(NSString *)userId skip:(NSUInteger)skip limit:(NSUInteger)limit andCallback:(AVArrayResultBlock)callback{
    NSParameterAssert(userId);
    
    TGBQuery *q=[TGBStatus statusQuery];
    q.limit=limit;
    q.skip=skip;
    [q whereKey:@"source" equalTo:[TGBObject objectWithoutDataWithClassName:@"_User" objectId:userId]];
    [q findObjectsInBackgroundWithBlock:callback];
}



+(void)getStatusWithID:(NSString *)objectId andCallback:(TGBStatusResultBlock)callback{
    NSError *error=[self permissionCheck];
    if (error) {
        callback(nil,error);
        return;
    }
    
    NSString *owner=[TGBStatus stringOfStatusOwner:[TGBUsered currentUser].objectId];
    [[TGBPaasClient sharedInstance] getObject:[NSString stringWithFormat:@"statuses/%@",objectId] withParameters:@{@"owner":owner,@"include":@"source"} block:^(id object, NSError *error) {
        
        if (!error) {
            
            object = [self statusFromCloudData:object];
        }
        
        [TGBUtils callIdResultBlock:callback object:object error:error];
    }];
}

+(void)deleteStatusWithID:(NSString *)objectId andCallback:(AVBooleanResultBlock)callback{
    NSError *error=[self permissionCheck];
    if (error) {
        callback(NO,error);
        return;
    }
    
    NSString *owner=[TGBStatus stringOfStatusOwner:[TGBUsered currentUser].objectId];
    [[TGBPaasClient sharedInstance] deleteObject:[NSString stringWithFormat:@"statuses/%@",objectId] withParameters:@{@"owner":owner} block:^(id object, NSError *error) {
        
        [TGBUtils callBooleanResultBlock:callback error:error];
    }];
}

+ (BOOL)deleteInboxStatusForMessageId:(NSUInteger)messageId inboxType:(NSString *)inboxType receiver:(NSString *)receiver error:(NSError *__autoreleasing *)error {
    if (!receiver) {
        if (error) *error = LCErrorInternal(@"Receiver of status can not be nil.");
        return NO;
    }

    if (!inboxType) {
        if (error) *error = LCErrorInternal(@"Inbox type of status can not be nil.");
        return NO;
    }

    NSDictionary *parameters = @{
        @"messageId" : [NSString stringWithFormat:@"%lu", (unsigned long)messageId],
        @"owner"     : [TGBObjectUtils dictionaryFromTGBObjectPointer:[TGBUsered objectWithoutDataWithObjectId:receiver]],
        @"inboxType" : inboxType
    };

    __block NSError *responseError = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    [[TGBPaasClient sharedInstance] deleteObject:[self statusInboxPath] withParameters:parameters block:^(id object, NSError *error) {
        responseError = error;
        dispatch_semaphore_signal(sema);
    }];

    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    if (error) {
        *error = responseError;
    }

    return responseError == nil;
}

+ (void)deleteInboxStatusInBackgroundForMessageId:(NSUInteger)messageId inboxType:(NSString *)inboxType receiver:(NSString *)receiver block:(AVBooleanResultBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        [self deleteInboxStatusForMessageId:messageId inboxType:inboxType receiver:receiver error:&error];
        [TGBUtils callBooleanResultBlock:block error:error];
    });
}

+(void)getUnreadStatusesCountWithType:(TGBStatusType*)type andCallback:(AVIntegerResultBlock)callback{
    NSError *error=[self permissionCheck];

    if (error) {
        [TGBUtils callIntegerResultBlock:callback number:0 error:error];
        return;
    }
    
    NSString *owner=[TGBStatus stringOfStatusOwner:[TGBUsered currentUser].objectId];
    
    [[TGBPaasClient sharedInstance] getObject:@"subscribe/statuses/count" withParameters:@{@"owner":owner,@"inboxType":type} block:^(id object, NSError *error) {
        NSUInteger count=[object[@"unread"] integerValue];
        [TGBUtils callIntegerResultBlock:callback number:count error:error];
    }];
}

+ (void)resetUnreadStatusesCountWithType:(TGBStatusType *)type andCallback:(AVBooleanResultBlock)callback {
    NSError *error = [self permissionCheck];

    if (error) {
        [TGBUtils callBooleanResultBlock:callback error:error];
        return;
    }

    NSString *owner = [TGBStatus stringOfStatusOwner:[TGBUsered currentUser].objectId];

    [[TGBPaasClient sharedInstance] postObject:@"subscribe/statuses/resetUnreadCount" withParameters:@{@"owner": owner, @"inboxType": type} block:^(id object, NSError *error) {
        [TGBUtils callBooleanResultBlock:callback error:error];
    }];
}

+(void)sendStatusToFollowers:(TGBStatus*)status andCallback:(AVBooleanResultBlock)callback{
    NSError *error=[self permissionCheck];
    if (error) {
        callback(NO,error);
        return;
    }
    status.source=[TGBUsered currentUser];
    status.targetQuery=[TGBUsered followerQuery:[TGBUsered currentUser].objectId];
    [status sendInBackgroundWithBlock:callback];
}

+(void)sendPrivateStatus:(TGBStatus *)status toUserWithID:(NSString *)userId andCallback:(AVBooleanResultBlock)callback{
    NSError *error=[self permissionCheck];
    if (error) {
        callback(NO,error);
        return;
    }
    status.source=[TGBUsered currentUser];
    [status setType:kTGBStatusTypePrivateMessage];
    
    TGBQuery *q=[TGBUsered query];
    [q whereKey:@"objectId" equalTo:userId];
    
    status.targetQuery=q;
    [status sendInBackgroundWithBlock:callback];
}

-(void)setQuery:(TGBQuery*)query{
    self.targetQuery=query;
}

-(NSError *)preSave
{
    NSParameterAssert(self.data);
    
    if ([self objectId]) {
        return LCError(kAVErrorOperationForbidden, @"status can't be update", nil);
    }
    
    if ([TGBUsered currentUser]==nil) {
        return LCError(kAVErrorOperationForbidden, @"do NOT have an current user, please login first", nil);
    }
    
    if (self.source==nil) {
        self.source=[TGBUsered currentUser];
    }
    
    if (self.targetQuery==nil) {
        self.targetQuery=[TGBUsered followerQuery:[TGBUsered currentUser].objectId];
    }
    
    if (self.type==nil) {
        [self setType:kTGBStatusTypeTimeline];
    }

    return nil;
}

-(void)sendInBackgroundWithBlock:(AVBooleanResultBlock)block{
    NSError *error=[self preSave];
    if (error) {
        block(NO,error);
        return;
    }
    
    NSMutableDictionary *body=[NSMutableDictionary dictionary];
    
    NSMutableDictionary *data=[self.data mutableCopy];
    [data setObject:self.source forKey:@"source"];
    
    [body setObject:[TGBObjectUtils dictionaryFromDictionary:data] forKey:@"data"];
    
    
    NSDictionary *queryInfo=[self.targetQuery dictionaryForStatusRequest];
    
    [body setObject:queryInfo forKey:@"query"];
    [body setObject:self.type forKey:@"inboxType"];

    TGBPaasClient *client = [TGBPaasClient sharedInstance];
    NSURLRequest *request = [client requestWithPath:@"statuses" method:@"POST" headers:nil parameters:body];

    @weakify(self);

    [client
     performRequest:request
     success:^(NSHTTPURLResponse *response, id responseObject) {
         @strongify(self);
         if ([responseObject isKindOfClass:[NSDictionary class]]) {
             NSString *objectId = responseObject[@"objectId"];

             if (objectId) {
                 self.objectId = objectId;
                 self.createdAt = [TGBObjectUtils dateFromString:responseObject[@"createdAt"]];

                 [TGBUtils callBooleanResultBlock:block error:nil];
                 return;
             }
         }

         [TGBUtils callBooleanResultBlock:block error:LCError(kAVErrorInvalidJSON, @"unexpected result return", nil)];
     }
     failure:^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
         [TGBUtils callBooleanResultBlock:block error:error];
     }];
}

-(NSString*)debugDescription{
    if (self.messageId>0) {
        return [[super debugDescription] stringByAppendingFormat:@" <id: %@,messageId:%lu type: %@, createdAt:%@, source:%@(%@)>: %@",self.objectId,(unsigned long)self.messageId,self.type,self.createdAt,NSStringFromClass([self.source class]), [self.source objectId],[self.data debugDescription]];
    }
    return [[super debugDescription] stringByAppendingFormat:@" <id: %@, type: %@, createdAt:%@, source:%@(%@)>: %@",self.objectId,self.type,self.createdAt,NSStringFromClass([self.source class]), [self.source objectId],[self.data debugDescription]];
}

@end

