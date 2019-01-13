//
//  TGBPush.h
//  AVOS Inc
//

#import <Foundation/Foundation.h>
#import "TGBPush.h"
#import "TGBPush_Internal.h"
#import "TGBPaasClient.h"
#import "TGBUtils.h"
#import "TGBQuery_Internal.h"
#import "TGBInstallation_Internal.h"
#import "TGBObjectUtils.h"
#import "TGBRouter_Internal.h"

/*!
 A class which defines a push notification that can be sent from
 a client device.

 The preferred way of modifying or retrieving channel subscriptions is to use
 the TGBInstallation class, instead of the class methods in TGBPush.

 This class is currently for iOS only. LeanCloud does not handle Push Notifications
 to LeanCloud applications running on OS X. Push Notifications can be sent from OS X
 applications via Cloud Code or the REST API to push-enabled devices (e.g. iOS
 or Android).
 */

static BOOL _isProduction = YES;

NSString *const kTGBPushTargetPlatformIOS = @"ios";
NSString *const kTGBPushTargetPlatformAndroid = @"android";
NSString *const kTGBPushTargetPlatformWindowsPhone = @"wp";

@implementation TGBPush

@synthesize pushQuery = _pushQuery;
@synthesize pushChannels = _pushChannels;
@synthesize pushData = _pushData;
@synthesize expirationDate = _expirationDate;
@synthesize expireTimeInterval = _expireTimeInterval;
@synthesize pushTarget = _pushTarget;

+(NSString *)myObjectPath
{
    return [[TGBRouter sharedInstance] appURLForPath:@"push" appID:[TGBKKit getApplicationId]];
}

-(id)init
{
    self = [super init];
    _pushChannels = [[NSMutableArray alloc] init];
    _pushData = [[NSMutableDictionary alloc] init];
    
    _pushTarget = [[NSMutableArray alloc] init];
    return self;
}

+ (instancetype)push
{
    TGBPush * push = [[TGBPush alloc] init];
    return push;
}

/*! @name Configuring a Push Notification */

/*!
 Sets the channel on which this push notification will be sent.
 @param channel The channel to set for this push. The channel name must start
 with a letter and contain only letters, numbers, dashes, and underscores.
 */
- (void)setChannel:(NSString *)channel
{
    [self.pushChannels removeAllObjects];
    [self.pushChannels addObject:channel];
}

- (void)setChannels:(NSArray *)channels
{
    [self.pushChannels removeAllObjects];
    [self.pushChannels addObjectsFromArray:channels];
}

- (void)setQuery:(TGBQuery *)query
{
    self.pushQuery = query;
}

- (void)setMessage:(NSString *)message
{
    [self.pushData removeAllObjects];
    [self.pushData setObject:message forKey:@"alert"];
}

- (void)setData:(NSDictionary *)data
{
    [self.pushData removeAllObjects];
    [self.pushData addEntriesFromDictionary:data];
}

- (void)setPushToTargetPlatforms:(NSArray *)platforms {
    if (platforms) {
        self.pushTarget = [platforms mutableCopy];
    } else {
        self.pushTarget = [[NSMutableArray alloc] init];
    }
}

- (void)setPushToAndroid:(BOOL)pushToAndroid {
    if (pushToAndroid) {
        [self.pushTarget addObject:kTGBPushTargetPlatformAndroid];
    } else {
        [self.pushTarget removeObject:kTGBPushTargetPlatformAndroid];
    }
}

- (void)setPushToIOS:(BOOL)pushToIOS {
    if (pushToIOS) {
        [self.pushTarget addObject:kTGBPushTargetPlatformIOS];
    } else {
        [self.pushTarget removeObject:kTGBPushTargetPlatformIOS];
    }
}

- (void)setPushToWP:(BOOL)pushToWP {
    if (pushToWP) {
        [self.pushTarget addObject:kTGBPushTargetPlatformWindowsPhone];
    } else {
        [self.pushTarget removeObject:kTGBPushTargetPlatformWindowsPhone];
    }
}

- (void)setPushDate:(NSDate *)dateToPush{
    self.pushTime=dateToPush;
}

- (void)expireAtDate:(NSDate *)date
{
    self.expirationDate = date;
}

- (void)expireAfterTimeInterval:(NSTimeInterval)timeInterval
{
    self.expireTimeInterval = timeInterval;
}

- (void)clearExpiration
{
    self.expirationDate = nil;
    self.expireTimeInterval = 0.0;
}

+ (void)setProductionMode:(BOOL)isProduction {
    _isProduction = isProduction;
}

+ (BOOL)sendPushMessage:(TGBPush *)push
                   wait:(BOOL)wait
                  block:(AVBooleanResultBlock)block
                  error:(NSError **)theError
{
    BOOL __block theResult = NO;
    BOOL __block hasCalledBack = NO;
    NSError __block *blockError = nil;
    
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [TGBUtils callBooleanResultBlock:block error:error];
        blockError = error;
        
        if (wait) {
            theResult = (error == nil);
            hasCalledBack = YES;
        }
    }];
    
    // wait until called back if necessary
    if (wait) {
        [TGBUtils warnMainThreadIfNecessary];
        AV_WAIT_TIL_TRUE(hasCalledBack, 0.1);
    };
    
    if (theError != NULL) *theError = blockError;
    return theResult;
}


+ (BOOL)sendPushMessageToChannel:(NSString *)channel
                     withMessage:(NSString *)message
                           error:(NSError **)error
{
    TGBPush * push = [TGBPush push];
    [push setChannel:channel];
    [push setMessage:message];
    return [TGBPush sendPushMessage:push wait:YES block:^(BOOL succeeded, NSError *error) {} error:error];
}

+ (void)sendPushMessageToChannelInBackground:(NSString *)channel
                                 withMessage:(NSString *)message
{
    TGBPush * push = [TGBPush push];
    [push setChannel:channel];
    [push setMessage:message];
    [TGBPush sendPushMessage:push wait:YES block:^(BOOL succeeded, NSError *error) {} error:nil];
}

+ (void)sendPushMessageToChannelInBackground:(NSString *)channel
                                 withMessage:(NSString *)message
                                       block:(AVBooleanResultBlock)block
{
    TGBPush * push = [TGBPush push];
    [push setChannel:channel];
    [push setMessage:message];
    [TGBPush sendPushMessage:push wait:YES block:block error:nil];
}

+ (void)sendPushMessageToChannelInBackground:(NSString *)channel
                                 withMessage:(NSString *)message
                                      target:(id)target
                                    selector:(SEL)selector
{
    TGBPush * push = [TGBPush push];
    [push setChannel:channel];
    [push setMessage:message];
    [TGBPush sendPushMessage:push wait:YES block:^(BOOL succeeded, NSError *error) {
        [TGBUtils performSelectorIfCould:target selector:selector object:@(succeeded) object:error];
    } error:nil];
}

+ (BOOL)sendPushMessageToQuery:(TGBQuery *)query
                   withMessage:(NSString *)message
                         error:(NSError **)theError
{
    TGBPush * push = [TGBPush push];
    [push setQuery:query];
    [push setMessage:message];
    return [TGBPush sendPushMessage:push wait:YES block:^(BOOL succeeded, NSError *error) {} error:theError];
}

+ (void)sendPushMessageToQueryInBackground:(TGBQuery *)query
                               withMessage:(NSString *)message
{
    TGBPush * push = [TGBPush push];
    [push setQuery:query];
    [push setMessage:message];
    [TGBPush sendPushMessage:push wait:NO block:^(BOOL succeeded, NSError *error) {} error:nil];
}

+ (void)sendPushMessageToQueryInBackground:(TGBQuery *)query
                               withMessage:(NSString *)message
                                     block:(AVBooleanResultBlock)block
{
    TGBPush * push = [TGBPush push];
    [push setQuery:query];
    [push setMessage:message];
    [TGBPush sendPushMessage:push wait:NO block:block error:nil];
}

- (BOOL)sendPush:(NSError **)error
{
    return [TGBPush sendPushMessage:self wait:YES block:^(BOOL succeeded, NSError *error) {} error:error];
}

- (BOOL)sendPushAndThrowsWithError:(NSError * _Nullable __autoreleasing *)error {
    return [self sendPush:error];
}

- (void)sendPushInBackground
{
    [TGBPush sendPushMessage:self wait:NO block:^(BOOL succeeded, NSError *error) {} error:nil];
}

-(NSDictionary *)queryData
{
    return [self.pushQuery assembleParameters];
}

-(NSDictionary *) pushChannelsData
{
    return @{channelsTag:self.pushChannels};
}

-(NSDictionary *)pushDataMessage
{
    return @{@"data": self.pushData};
}

-(NSMutableDictionary *)postData
{
    NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
    NSString *prod = @"prod";
    if (!_isProduction) {
        prod = @"dev";
    }
    [data setObject:prod forKey:@"prod"];
    if (self.pushQuery)
    {
        [data addEntriesFromDictionary:[self queryData]];
    }
    else if (self.pushChannels.count > 0)
    {
        [data addEntriesFromDictionary:[self pushChannelsData]];
    }
    
    if (self.expirationDate)
    {
        [data setObject:[TGBObjectUtils stringFromDate:self.expirationDate] forKey:@"expiration_time"];
    }
    if (self.expireTimeInterval > 0)
    {
        NSDate * currentDate = [NSDate date];
        [data setObject:[TGBObjectUtils stringFromDate:currentDate] forKey:@"push_time"];
        [data setObject:@(self.expireTimeInterval) forKey:@"expiration_interval"];
    }
    
    if (self.pushTime) {
        [data setObject:[TGBObjectUtils stringFromDate:self.pushTime] forKey:@"push_time"];
    }
    
    if (self.pushTarget.count > 0)
    {
        NSMutableDictionary *where = [[NSMutableDictionary alloc] init];
        NSDictionary *condition = @{@"$in": self.pushTarget};
        [where setObject:condition forKey:deviceTypeTag];
        [data setObject:where forKey:@"where"];
    }
    
    [data addEntriesFromDictionary:[self pushDataMessage]];
    return data;
}

- (void)sendPushInBackgroundWithBlock:(AVBooleanResultBlock)block
{
    NSString *path = [TGBPush myObjectPath];
    [[TGBPaasClient sharedInstance] postObject:path
                               withParameters:[self postData]
                                   eventually:YES
                                        block:^(id object, NSError *error) {
                                                [TGBUtils callBooleanResultBlock:block error:error];
    }];
}

- (void)sendPushInBackgroundWithTarget:(id)target selector:(SEL)selector
{
    [self sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [TGBUtils performSelectorIfCould:target selector:selector object:@(succeeded) object:error];
    }];
}

+ (BOOL)sendPushDataToChannel:(NSString *)channel
                     withData:(NSDictionary *)data
                        error:(NSError **)error
{
    TGBPush * push = [TGBPush push];
    [push setChannel:channel];
    [push setData:data];
    return [TGBPush sendPushMessage:push wait:YES block:nil error:error];
}

+ (void)sendPushDataToChannelInBackground:(NSString *)channel
                                 withData:(NSDictionary *)data
{
    TGBPush * push = [TGBPush push];
    [push setChannel:channel];
    [push setData:data];
    [TGBPush sendPushMessage:push wait:YES block:nil error:nil];
}

+ (void)sendPushDataToChannelInBackground:(NSString *)channel
                                 withData:(NSDictionary *)data
                                    block:(AVBooleanResultBlock)block
{
    TGBPush * push = [TGBPush push];
    [push setChannel:channel];
    [push setData:data];
    [TGBPush sendPushMessage:push wait:NO block:block error:nil];
}

+ (void)sendPushDataToChannelInBackground:(NSString *)channel
                                 withData:(NSDictionary *)data
                                   target:(id)target
                                 selector:(SEL)selector
{
    TGBPush * push = [TGBPush push];
    [push setChannel:channel];
    [push setData:data];
    [TGBPush sendPushMessage:push wait:NO block:^(BOOL succeeded, NSError *error) {
        [TGBUtils performSelectorIfCould:target selector:selector object:@(succeeded) object:error];
    } error:nil];
}

+ (BOOL)sendPushDataToQuery:(TGBQuery *)query
                   withData:(NSDictionary *)data
                      error:(NSError **)error
{
    TGBPush * push = [TGBPush push];
    [push setQuery:query];
    [push setData:data];
    return [TGBPush sendPushMessage:push wait:YES block:nil error:error];
}

+ (void)sendPushDataToQueryInBackground:(TGBQuery *)query
                               withData:(NSDictionary *)data
{
    TGBPush * push = [TGBPush push];
    [push setQuery:query];
    [push setData:data];
    [TGBPush sendPushMessage:push wait:NO block:nil error:nil];
}

+ (void)sendPushDataToQueryInBackground:(TGBQuery *)query
                               withData:(NSDictionary *)data
                                  block:(AVBooleanResultBlock)block
{
    TGBPush * push = [TGBPush push];
    [push setQuery:query];
    [push setData:data];
    [TGBPush sendPushMessage:push wait:NO block:block error:nil];
}

+ (NSSet *)getSubscribedChannels:(NSError **)error
{
    return [TGBPush getSubscribedChannelsWithBlock:^(NSSet *channels, NSError *error) {
    } wait:YES error:error];
}

+ (NSSet *)getSubscribedChannelsAndThrowsWithError:(NSError * _Nullable __autoreleasing *)error {
    return [self getSubscribedChannels:error];
}

+ (void)getSubscribedChannelsInBackgroundWithBlock:(AVSetResultBlock)block
{
    [TGBPush getSubscribedChannelsWithBlock:^(NSSet *channels, NSError *error) {
        [TGBUtils callSetResultBlock:block set:channels error:error];
    } wait:NO error:nil];
}

+ (void)getSubscribedChannelsInBackgroundWithTarget:(id)target
                                           selector:(SEL)selector
{
    [TGBPush getSubscribedChannelsWithBlock:^(NSSet *channels, NSError *error) {
        [TGBUtils performSelectorIfCould:target selector:selector object:channels object:error];
    } wait:NO error:nil];
}

+ (NSSet *)getSubscribedChannelsWithBlock:(AVSetResultBlock)block
                                     wait:(BOOL)wait
                                    error:(NSError **)theError
{
    BOOL __block theResult = NO;
    BOOL __block hasCalledBack = NO;
    NSError __block *blockError = nil;
    __block  NSSet * resultSet = nil;

    TGBQuery * query = [TGBInstallation installationQuery];
    [query whereKey:deviceTokenTag equalTo:[TGBInstallation defaultInstallation].deviceToken];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0)
        {
            TGBInstallation * installation = [objects objectAtIndex:0];
            resultSet = [NSSet setWithArray:installation.channels];
        }
        [TGBUtils callSetResultBlock:block set:resultSet error:error];
        
        blockError = error;
        
        if (wait) {
            theResult = (error == nil);
            hasCalledBack = YES;
        }
    }];
    
    // wait until called back if necessary
    if (wait) {
        [TGBUtils warnMainThreadIfNecessary];
        AV_WAIT_TIL_TRUE(hasCalledBack, 0.1);
    };
    
    if (theError != NULL) *theError = blockError;
    return resultSet;
}


+ (BOOL)subscribeToChannel:(NSString *)channel error:(NSError **)error
{
    TGBInstallation * installation = [TGBInstallation defaultInstallation];
    [installation addUniqueObject:channel forKey:channelsTag];
    return [installation save:error];
}

+ (void)subscribeToChannelInBackground:(NSString *)channel
{
    TGBInstallation * installation = [TGBInstallation defaultInstallation];
    [installation addUniqueObject:channel forKey:channelsTag];
    [installation saveInBackground];
}

+ (void)subscribeToChannelInBackground:(NSString *)channel
                                 block:(AVBooleanResultBlock)block
{
    TGBInstallation * installation = [TGBInstallation defaultInstallation];
    [installation addUniqueObject:channel forKey:channelsTag];
    [installation saveInBackgroundWithBlock:block];
}

+ (void)subscribeToChannelInBackground:(NSString *)channel
                                target:(id)target
                              selector:(SEL)selector
{
    TGBInstallation * installation = [TGBInstallation defaultInstallation];
    [installation addUniqueObject:channel forKey:channelsTag];
    [installation saveInBackgroundWithTarget:target selector:selector];
}

+ (BOOL)unsubscribeFromChannel:(NSString *)channel error:(NSError **)error
{
    TGBInstallation * installation = [TGBInstallation defaultInstallation];
    [installation removeObject:channel forKey:channelsTag];
    return [installation save:error];
}

+ (void)unsubscribeFromChannelInBackground:(NSString *)channel
{
    TGBInstallation * installation = [TGBInstallation defaultInstallation];
    [installation removeObject:channel forKey:channelsTag];
    [installation saveInBackground];
}


+ (void)unsubscribeFromChannelInBackground:(NSString *)channel
                                     block:(AVBooleanResultBlock)block
{
    TGBInstallation * installation = [TGBInstallation defaultInstallation];
    [installation removeObject:channel forKey:channelsTag];
    [installation saveInBackgroundWithBlock:block];
}

+ (void)unsubscribeFromChannelInBackground:(NSString *)channel
                                    target:(id)target
                                  selector:(SEL)selector
{
    TGBInstallation * installation = [TGBInstallation defaultInstallation];
    [installation removeObject:channel forKey:channelsTag];
    [installation saveInBackgroundWithTarget:target selector:selector];
}

@end
