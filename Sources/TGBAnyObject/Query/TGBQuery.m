// TGBQuery.m
// Copyright 2013 AVOS, Inc. All rights reserved.

#import <Foundation/Foundation.h>
#import "TGBGeoPoint.h"
#import "TGBObject_Internal.h"
#import "TGBQuery.h"
#import "TGBUtils.h"
#import "TGBPaasClient.h"
#import "TGBPaasClient_internal.h"
#import "TGBUsered_Internal.h"
#import "TGBGeoPoint_Internal.h"
#import "TGBCacheManager.h"
#import "TGBInstallation_Internal.h"
#import "TGBErrorUtils.h"
#import "TGBObjectUtils.h"
#import "TGBQuery_Internal.h"
#import "TGBCloudQueryResult_Internal.h"

NS_INLINE
NSString *LCStringFromDistanceUnit(TGBQueryDistanceUnit unit) {
    NSString *unitString = nil;

    switch (unit) {
    case TGBQueryDistanceUnitMile:
        unitString = @"miles";
        break;
    case TGBQueryDistanceUnitKilometer:
        unitString = @"kilometers";
        break;
    case TGBQueryDistanceUnitRadian:
        unitString = @"radians";
        break;
    default:
        break;
    }

    return unitString;
}

@interface   TGBQuery()

@property (nonatomic, readwrite, strong) NSMutableSet *include;
@property (nonatomic, readwrite, strong) NSString *order;

@end

@implementation  TGBQuery

@synthesize className = _className;
@synthesize where = _where;
@synthesize include = _include;
@synthesize order = _order;


- (NSMutableDictionary *)parameters {
    if (!_parameters) {
        _parameters = [NSMutableDictionary dictionary];
    }
    return _parameters;
}

+ (instancetype)queryWithClassName:(NSString *)className
{
    TGBQuery * query = [[[self class] alloc] initWithClassName:className];
    return query;
}

+ (TGBCloudQueryResult *)doCloudQueryWithCQL:(NSString *)cql {
    return [self doCloudQueryWithCQL:cql error:NULL];
}

+ (TGBCloudQueryResult *)doCloudQueryWithCQL:(NSString *)cql error:(NSError **)error {
    return [self doCloudQueryWithCQL:cql pvalues:nil error:error];
}
+ (TGBCloudQueryResult *)doCloudQueryWithCQL:(NSString *)cql pvalues:(NSArray *)pvalues error:(NSError **)error {
    return [self cloudQueryWithCQL:cql pvalues:pvalues callback:nil waitUntilDone:YES error:error];
}

+ (void)doCloudQueryInBackgroundWithCQL:(NSString *)cql callback:(TGBCloudQueryCallback)callback {
    [self doCloudQueryInBackgroundWithCQL:cql pvalues:nil callback:callback];
}

+ (void)doCloudQueryInBackgroundWithCQL:(NSString *)cql pvalues:(NSArray *)pvalues callback:(TGBCloudQueryCallback)callback {
    [self cloudQueryWithCQL:cql pvalues:pvalues callback:callback waitUntilDone:NO error:NULL];
}

+ (TGBCloudQueryResult *)cloudQueryWithCQL:(NSString *)cql pvalues:(NSArray *)pvalues callback:(TGBCloudQueryCallback)callback waitUntilDone:(BOOL)wait error:(NSError **)error{
    if (!cql) {
        NSError *err = LCError(kAVErrorInvalidQuery, @"cql can not be nil", nil);
        if (error) {
            *error = err;
        }
        if (callback) {
            [TGBUtils callCloudQueryResultBlock:callback result:nil error:err];
        }
        return nil;
    }
    TGBCloudQueryResult __block *theResultObject = [[TGBCloudQueryResult alloc] init];
    BOOL __block hasCalledBack = NO;
    NSError __block *blockError = nil;
    
    NSString *path = @"cloudQuery";
    NSDictionary *parameters = nil;
    if (pvalues.count > 0) {
        NSArray *parsedPvalues = [TGBObjectUtils dictionaryFromObject:pvalues];
        NSString *jsonString = [TGBUtils jsonStringFromArray:parsedPvalues];
        parameters = @{@"cql":cql, @"pvalues":jsonString};
    } else {
        parameters = @{@"cql":cql};
    }
    
    [[TGBPaasClient sharedInstance] getObject:path withParameters:parameters block:^(id dict, NSError *error) {
        if (error == nil && [TGBObjectUtils hasAnyKeys:dict]) {
            NSString *className = [dict objectForKey:@"className"];
            NSArray *resultArray = [dict objectForKey:@"results"];
            NSNumber *count = [dict objectForKey:@"count"];
            NSMutableArray *results = [[NSMutableArray alloc] init];
            if (resultArray.count > 0 && className) {
                for (NSDictionary *objectDict in resultArray) {
                    TGBObject *object = [TGBObjectUtils TGBObjectForClass:className];
                    [TGBObjectUtils copyDictionary:objectDict toObject:object];
                    [results addObject:object];
                }
            }
            [theResultObject setResults:[results copy]];
            [theResultObject setCount:[count intValue]];
            [theResultObject setClassName:className];
        }
        [TGBUtils callCloudQueryResultBlock:callback result:theResultObject error:error];
        if (wait) {
            blockError = error;
            hasCalledBack = YES;
        }
        
    }];
    if (wait) {
        [TGBUtils warnMainThreadIfNecessary];
        AV_WAIT_TIL_TRUE(hasCalledBack, 0.1);
    };
    
    if (error != NULL) *error = blockError;
    return theResultObject;
    
}

- (instancetype)init {
    self = [super init];

    if (self) {
        [self doInitialization];
    }

    return self;
}

- (instancetype)initWithClassName:(NSString *)newClassName
{
    self = [super init];

    if (self) {
        _className = [newClassName copy];
        [self doInitialization];
    }

    return self;
}

- (void)doInitialization {
    _where = [[NSMutableDictionary alloc] init];
    _include = [[NSMutableSet alloc] init];
    _maxCacheAge = 24 * 3600;
}

- (void)includeKey:(NSString *)key
{
    [self.include addObject:key];
}

- (void)selectKeys:(NSArray *)keys
{
    if (self.selectedKeys == nil) {
        _selectedKeys = [[NSMutableSet alloc] initWithCapacity:keys.count];
    }
    [self.selectedKeys addObjectsFromArray:keys];
}

- (void)addWhereItem:(id)dict forKey:(NSString *)key {
    if ([dict objectForKey:@"$eq"]) {
        if ([self.where objectForKey:@"$and"]) {
            NSMutableArray *eqArray = [self.where objectForKey:@"$and"];
            int removeIndex = -1;
            for (NSDictionary *eqDict in eqArray) {
                if ([eqDict objectForKey:key]) {
                    removeIndex = (int)[eqArray indexOfObject:eqDict];
                }
            }
            
            if (removeIndex >= 0) {
                [eqArray removeObjectAtIndex:removeIndex];
            }
            
            [eqArray addObject:@{key:[dict objectForKey:@"$eq"]}];
        } else {
            NSMutableArray *eqArray = [[NSMutableArray alloc] init];
            [eqArray addObject:@{key:[dict objectForKey:@"$eq"]}];
            [self.where setObject:eqArray forKey:@"$and"];
        }
    } else {
        if ([self.where objectForKey:key]) {
            [[self.where objectForKey:key] addEntriesFromDictionary:dict];
        } else {
            NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
            [self.where setObject:mutableDict forKey:key];
        }
    }
}

- (void)whereKeyExists:(NSString *)key
{
    NSDictionary * dict = @{@"$exists": [NSNumber numberWithBool:YES]};
    [self addWhereItem:dict forKey:key];
}

- (void)whereKeyDoesNotExist:(NSString *)key
{
    NSDictionary * dict = @{@"$exists": [NSNumber numberWithBool:NO]};
    [self addWhereItem:dict forKey:key];
}

- (id)valueForEqualityTesting:(id)object {
    if (!object) {
        return [NSNull null];
    } else if ([object isKindOfClass:[TGBObject class]]) {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@"Pointer" forKey:@"__type"];
        [dict setObject:[object internalClassName] forKey:classNameTag];
        if ([object hasValidObjectId])
        {
            [dict setObject:((TGBObject *)object).objectId forKey:@"objectId"];
            return dict;
        } else {
            return NSNull.null;
        }
    } else {
        return object;
    }
}

- (void)whereKey:(NSString *)key equalTo:(id)object
{
    NSDictionary * dict = @{@"$eq": [self valueForEqualityTesting:object]};
    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key sizeEqualTo:(NSUInteger)count
{
    [self addWhereItem:@{@"$size": [NSNumber numberWithUnsignedInteger:count]} forKey:key];
}


- (void)whereKey:(NSString *)key lessThan:(id)object
{
    NSDictionary * dict = @{@"$lt":object};
    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key lessThanOrEqualTo:(id)object
{
    NSDictionary * dict = @{@"$lte":object};
    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key greaterThan:(id)object
{
    NSDictionary * dict = @{@"$gt": object};
    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key greaterThanOrEqualTo:(id)object
{
    NSDictionary * dict = @{@"$gte": object};
    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key notEqualTo:(id)object
{
    NSDictionary * dict = @{@"$ne": [self valueForEqualityTesting:object]};
    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key containedIn:(NSArray *)array
{
    NSDictionary * dict = @{@"$in": array };
    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key notContainedIn:(NSArray *)array
{
    NSDictionary * dict = @{@"$nin": array };
    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key containsAllObjectsInArray:(NSArray *)array
{
    NSDictionary * dict = @{@"$all": array };
    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key nearGeoPoint:(TGBGeoPoint *)geoPoint
{
    NSDictionary * dict = @{@"$nearSphere" : [TGBGeoPoint dictionaryFromGeoPoint:geoPoint]};
    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key nearGeoPoint:(TGBGeoPoint *)geoPoint withinMiles:(double)maxDistance
{
    NSDictionary * dict = @{@"$nearSphere" : [TGBGeoPoint dictionaryFromGeoPoint:geoPoint], @"$maxDistanceInMiles":@(maxDistance)};
    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key nearGeoPoint:(TGBGeoPoint *)geoPoint withinKilometers:(double)maxDistance
{
    NSDictionary * dict = @{@"$nearSphere" : [TGBGeoPoint dictionaryFromGeoPoint:geoPoint], @"$maxDistanceInKilometers":@(maxDistance)};
    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key nearGeoPoint:(TGBGeoPoint *)geoPoint withinRadians:(double)maxDistance
{
    NSDictionary * dict = @{@"$nearSphere" : [TGBGeoPoint dictionaryFromGeoPoint:geoPoint], @"$maxDistanceInRadians":@(maxDistance)};
    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key
    nearGeoPoint:(TGBGeoPoint *)geoPoint
     maxDistance:(double)maxDistance
 maxDistanceUnit:(TGBQueryDistanceUnit)maxDistanceUnit
     minDistance:(double)minDistance
 minDistanceUnit:(TGBQueryDistanceUnit)minDistanceUnit
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    dict[@"$nearSphere"] = [TGBGeoPoint dictionaryFromGeoPoint:geoPoint];

    NSString *unitString = nil;

    if (maxDistance >= 0 && (unitString = LCStringFromDistanceUnit(maxDistanceUnit))) {
        NSString *querySelector = [NSString stringWithFormat:@"$maxDistanceIn%@", [unitString capitalizedString]];
        dict[querySelector] = @(maxDistance);
    }

    if (minDistance >= 0 && (unitString = LCStringFromDistanceUnit(minDistanceUnit))) {
        NSString *querySelector = [NSString stringWithFormat:@"$minDistanceIn%@", [unitString capitalizedString]];
        dict[querySelector] = @(minDistance);
    }

    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key
    nearGeoPoint:(TGBGeoPoint *)geoPoint
     minDistance:(double)minDistance
 minDistanceUnit:(TGBQueryDistanceUnit)minDistanceUnit
{
    [self whereKey:key nearGeoPoint:geoPoint maxDistance:-1 maxDistanceUnit:(TGBQueryDistanceUnit)0 minDistance:minDistance minDistanceUnit:minDistanceUnit];
}

- (void)whereKey:(NSString *)key withinGeoBoxFromSouthwest:(TGBGeoPoint *)southwest toNortheast:(TGBGeoPoint *)northeast
{
    NSDictionary * dict = @{@"$within": @{@"$box" : @[[TGBGeoPoint dictionaryFromGeoPoint:southwest], [TGBGeoPoint dictionaryFromGeoPoint:northeast]]}};
    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex
{
    NSDictionary * dict = @{@"$regex": regex};
    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex modifiers:(NSString *)modifiers
{
    NSDictionary * dict = @{@"$regex":regex, @"$options":modifiers};
    [self addWhereItem:dict forKey:key];
}

- (void)whereKey:(NSString *)key containsString:(NSString *)substring
{
    [self whereKey:key matchesRegex:[NSString stringWithFormat:@".*%@.*",substring]];
}

- (void)whereKey:(NSString *)key hasPrefix:(NSString *)prefix
{
    [self whereKey:key matchesRegex:[NSString stringWithFormat:@"^%@.*",prefix]];
}

- (void)whereKey:(NSString *)key hasSuffix:(NSString *)suffix
{
    [self whereKey:key matchesRegex:[NSString stringWithFormat:@".*%@$",suffix]];
}

+ (TGBQuery *)orQueryWithSubqueries:(NSArray *)queries
{
    NSString * className = nil;
    NSMutableArray * input = [[NSMutableArray alloc] initWithCapacity:queries.count];
    for(TGBQuery * query in queries)
    {
        [input addObject:query.where];

        //classname must be same, or will get assert
        if (className!=nil) {
            NSAssert([query.className isEqualToString:className], @"the OR query requires same classNames, but here got %@ v.s. %@",className,query.className);
        }

        className = query.className;
    }
    TGBQuery * result = [TGBQuery queryWithClassName:className];
    [result.where setValue:input forKey:@"$or"];
    return result;
}

+ (TGBQuery *)andQueryWithSubqueries:(NSArray *)queries
{
    if (queries.count <= 0) {
        return nil;
    }

    NSString * className = nil;
    NSMutableArray * input = [[NSMutableArray alloc] initWithCapacity:queries.count];
    for(TGBQuery * query in queries)
    {
        [input addObject:query.where];

        //classname must be same, or will get assert
        if (className!=nil) {
            NSAssert([query.className isEqualToString:className], @"the AND query requires same classNames, but here got %@ v.s. %@",className,query.className);
        }

        className = query.className;
    }
    TGBQuery * result = [TGBQuery queryWithClassName:className];
    if (input.count > 1) {
        [result.where setValue:input forKey:@"$and"];
    } else {
        [result.where addEntriesFromDictionary:[input objectAtIndex:0]];
    }
    return result;
}

// 'where={"belongTo":{"$select":{"query":{"className":"Person","where":{"gender":"Male"}},"key":"name"}}}'
- (void)whereKey:(NSString *)key matchesKey:(NSString *)otherKey inQuery:(TGBQuery *)query
{
    NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] initWithDictionary:@{@"className":query.className,
                                                                                       @"where":query.where}];
    if (query.limit > 0) {
        [queryDict addEntriesFromDictionary:@{@"limit":@(query.limit)}];
    }
    
    if (query.skip > 0) {
        [queryDict addEntriesFromDictionary:@{@"skip":@(query.skip)}];
    }
    
    if (query.order.length > 0) {
        [queryDict addEntriesFromDictionary:@{@"order":query.order}];
    }
    
    NSDictionary *dict = @{@"$select":
                               @{@"query":queryDict,
                                 @"key":otherKey
                                 }
                           };
    [self.where setValue:dict forKey:key];
}

- (void)whereKey:(NSString *)key doesNotMatchKey:(NSString *)otherKey inQuery:(TGBQuery *)query
{
    NSDictionary *dict = @{@"$dontSelect":
                               @{@"query":
                                     @{@"className":query.className,
                                       @"where":query.where
                                       },
                                 @"key":otherKey
                                 }
                           };
    [self.where setValue:dict forKey:key];
}

// 'where={"post":{"$inQuery":{"where":{"image":{"$exists":true}},"className":"Post"}}}'
- (void)whereKey:(NSString *)key matchesQuery:(TGBQuery *)query
{
    NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] initWithDictionary:@{@"className":query.className,
                                                                                       @"where":query.where}];
    if (query.limit > 0) {
        [queryDict addEntriesFromDictionary:@{@"limit":@(query.limit)}];
    }
    
    if (query.skip > 0) {
        [queryDict addEntriesFromDictionary:@{@"skip":@(query.skip)}];
    }
    
    if (query.order.length > 0) {
        [queryDict addEntriesFromDictionary:@{@"order":query.order}];
    }
    
    NSDictionary *dic = @{@"$inQuery":queryDict};
    [self.where setValue:dic forKey:key];
}

- (void)whereKey:(NSString *)key doesNotMatchQuery:(TGBQuery *)query
{
    NSDictionary *dic = @{@"$notInQuery":
                              @{@"where":query.where,
                                @"className":query.className
                                }
                          };
    [self.where setValue:dic forKey:key];
}

- (void)orderByAscending:(NSString *)key
{
    self.order = [NSString stringWithFormat:@"%@", key];
}

- (void)addAscendingOrder:(NSString *)key
{
    if (self.order.length <= 0)
    {
        [self orderByAscending:key];
        return;
    }
    self.order = [NSString stringWithFormat:@"%@,%@", self.order, key];
}

- (void)orderByDescending:(NSString *)key
{
    self.order = [NSString stringWithFormat:@"-%@", key];
}

- (void)addDescendingOrder:(NSString *)key
{
    if (self.order.length <= 0)
    {
        [self orderByDescending:key];
        return;
    }
    self.order = [NSString stringWithFormat:@"%@,-%@", self.order, key];
}

- (void)orderBySortDescriptor:(NSSortDescriptor *)sortDescriptor
{
    NSString *symbol = sortDescriptor.ascending ? @"" : @"-";
    self.order = [symbol stringByAppendingString:sortDescriptor.key];
}

- (void)orderBySortDescriptors:(NSArray *)sortDescriptors
{
    if (sortDescriptors.count == 0) return;

    self.order = @"";
    for (NSSortDescriptor *sortDescriptor in sortDescriptors) {
        NSString *symbol = sortDescriptor.ascending ? @"" : @"-";
        if (self.order.length) {
            self.order = [NSString stringWithFormat:@"%@,%@%@", self.order, symbol, sortDescriptor.key];
        } else {
            self.order=[NSString stringWithFormat:@"%@%@", symbol, sortDescriptor.key];
        }

    }
}

+ (TGBObject *)getObjectOfClass:(NSString *)objectClass
                      objectId:(NSString *)objectId
{
    return [[self class] getObjectOfClass:objectClass objectId:objectId error:NULL];
}

+ (TGBObject *)getObjectOfClass:(NSString *)objectClass
                      objectId:(NSString *)objectId
                         error:(NSError **)error
{
    return [[TGBQuery queryWithClassName:objectClass] getObjectWithId:objectId error:error];
}

- (TGBObject *)getObjectWithId:(NSString *)objectId
{
    return [self getObjectWithId:objectId error:NULL];
}

- (TGBObject *)getObjectWithId:(NSString *)objectId error:(NSError **)error
{
    [self raiseSyncExceptionIfNeed];
    
    TGBObject __block *theResultObject = nil;
    BOOL __block hasCalledBack = NO;
    NSError __block *blockError = nil;
    [self internalGetObjectInBackgroundWithId:objectId block:^(TGBObject *object, NSError *error) {
        theResultObject = object;
        blockError = error;
        hasCalledBack = YES;
    }];
    
    [TGBUtils warnMainThreadIfNecessary];
    AV_WAIT_TIL_TRUE(hasCalledBack, 0.1);
    
    if (error != NULL) {
        *error = blockError;
    }
    return theResultObject;
}

- (void)getObjectInBackgroundWithId:(NSString *)objectId
                              block:(TGBObjectResultBlock)block {
    [self internalGetObjectInBackgroundWithId:objectId block:^(TGBObject *object, NSError *error) {
        [TGBUtils callObjectResultBlock:block object:object error:error];
    }];
}

- (void)internalGetObjectInBackgroundWithId:(NSString *)objectId
                              block:(TGBObjectResultBlock)block
{
    NSString *path = [TGBObjectUtils objectPath:self.className objectId:objectId];
    [self assembleParameters];
    [[TGBPaasClient sharedInstance] getObject:path withParameters:self.parameters policy:self.cachePolicy maxCacheAge:self.maxCacheAge block:^(id dict, NSError *error) {
        TGBObject *object = nil;
        if (error == nil && [TGBObjectUtils hasAnyKeys:dict]) {
            object = [TGBObjectUtils TGBObjectForClass:self.className];
            [TGBObjectUtils copyDictionary:dict toObject:object];
        }
        
        if (error == nil && [dict allKeys].count == 0) {
            error = LCError(kAVErrorObjectNotFound, [NSString stringWithFormat:@"No object with that objectId %@ was found.", objectId], nil);
        }
        if (block) {
            block(object, error);
        }
    }];
}

/*!
 Gets a TGBObject asynchronously.

 This mutates the TGBQuery

 @param objectId The id of the object being requested.
 @param target The target for the callback selector.
 @param selector The selector for the callback. It should have the following signature: (void)callbackWithResult:(TGBObject *)result error:(NSError *)error. result will be nil if error is set and vice versa.
 */
- (void)getObjectInBackgroundWithId:(NSString *)objectId
                             target:(id)target
                           selector:(SEL)selector
{
    [self getObjectInBackgroundWithId:objectId block:^(TGBObject *object, NSError *error) {
        [TGBUtils performSelectorIfCould:target selector:selector object:object object:error];
    }];
}

#pragma mark -
#pragma mark Getting Users

/*! @name Getting User Objects */

/*!
 Returns a TGBUsered with a given id.
 @param objectId The id of the object that is being requested.
 @result The TGBUsered if found. Returns nil if the object isn't found, or if there was an error.
 */
+ (TGBUsered *)getUserObjectWithId:(NSString *)objectId
{
    return [[self class] getUserObjectWithId:objectId error:NULL];
}

/*!
 Returns a TGBUsered with a given class and id and sets an error if necessary.
 @param error Pointer to an NSError that will be set if necessary.
 @result The TGBUsered if found. Returns nil if the object isn't found, or if there was an error.
 */
+ (TGBUsered *)getUserObjectWithId:(NSString *)objectId
                          error:(NSError **)error
{
    id user = [[TGBUsered query] getObjectWithId:objectId error:error];
    if ([user isKindOfClass:[TGBUsered class]]) {
        return user;
    }

    return nil;
}

/*!
 Deprecated.  Please use [TGBUsered query] instead.
 */
+ (TGBQuery *)queryForUser __attribute__ ((deprecated))
{
    return [TGBUsered query];
}

#pragma mark -
#pragma mark Find methods

/** @name Getting all Matches for a Query */

/*!
 Finds objects based on the constructed query.
 @result Returns an array of TGBObjects that were found.
 */
- (NSArray *)findObjects
{
    return [self findObjects:NULL];
}

/*!
 Finds objects based on the constructed query and sets an error if there was one.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns an array of TGBObjects that were found.
 */
- (NSArray *)findObjects:(NSError **)error
{
    return [self findObjectsWithBlock:NULL waitUntilDone:YES error:error];
}

- (NSArray *)findObjectsAndThrowsWithError:(NSError * _Nullable __autoreleasing *)error {
    return [self findObjects:error];
}

-(void)queryWithBlock:(NSString *)path
           parameters:(NSDictionary *)parameters
                block:(AVArrayResultBlock)resultBlock
{

    [[TGBPaasClient sharedInstance] getObject:path withParameters:parameters policy:self.cachePolicy maxCacheAge:self.maxCacheAge block:^(id object, NSError *error) {
        NSMutableArray * array;
        if (error == nil)
        {
            NSString *className = object[@"className"];
            BOOL end = [[object objectForKey:@"end"] boolValue];
            NSArray * results = [object objectForKey:@"results"];
            array = [self processResults:results className:className];
            [self processEnd:end];
        }
        if (resultBlock) {
            resultBlock(array, error);
        }
    }];
}

/*!
 Finds objects asynchronously and calls the given block with the results.
 @param block The block to execute. The block should have the following argument signature:(NSArray *objects, NSError *error)
 */
- (void)findObjectsInBackgroundWithBlock:(AVArrayResultBlock)resultBlock
{
    [self findObjectsWithBlock:resultBlock waitUntilDone:NO error:NULL];
}

// private method for sync and async using
- (NSArray *)findObjectsWithBlock:(AVArrayResultBlock)resultBlock
                    waitUntilDone:(BOOL)wait
                            error:(NSError **)theError
{
    if (wait) [self raiseSyncExceptionIfNeed];

    NSArray __block *theResultArray = nil;
    BOOL __block hasCalledBack = NO;
    NSError __block *blockError = nil;

    NSString *path = [self queryPath];
    [self assembleParameters];

    [self queryWithBlock:path parameters:self.parameters block:^(NSArray *objects, NSError *error) {
        [TGBUtils callArrayResultBlock:resultBlock array:objects error:error];

        if (wait) {
            blockError = error;
            theResultArray = objects;
            hasCalledBack = YES;
        }
    }];

    if (wait) {
        [TGBUtils warnMainThreadIfNecessary];
        AV_WAIT_TIL_TRUE(hasCalledBack, 0.1);
    };

     if (theError != NULL) *theError = blockError;
    return theResultArray;
}

// Called in findObjects and getFirstObject, isDataReady is set to YES
- (NSMutableArray *)processResults:(NSArray *)results className:(NSString *)className {
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for(NSDictionary * dict in results)
    {
        TGBObject * object = [TGBObjectUtils TGBObjectForClass:className ?: self.className];
        [TGBObjectUtils copyDictionary:dict toObject:object];
        [array addObject:object];
    }
    return array;
}

- (void)processEnd:(BOOL)end {
    
}
/*!
 Finds objects asynchronously and calls the given callback with the results.
 @param target The object to call the selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSArray *)result error:(NSError *)error. result will be nil if error is set and vice versa.
 */
- (void)findObjectsInBackgroundWithTarget:(id)target
                                 selector:(SEL)selector
{
    [self findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [TGBUtils performSelectorIfCould:target selector:selector object:objects object:error];
    }];
}

- (void)deleteAllInBackgroundWithBlock:(AVBooleanResultBlock)block {
    [self findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            block(NO, error);
        } else {
            [TGBObject deleteAllInBackground:objects block:block];
        }
    }];
}

/** @name Getting the First Match in a Query */

/*!
 Gets an object based on the constructed query.

 This mutates the TGBQuery.

 @result Returns a TGBObject, or nil if none was found.
 */
- (TGBObject *)getFirstObject
{
    return [self getFirstObject:NULL];
}

/*!
 Gets an object based on the constructed query and sets an error if any occurred.

 This mutates the TGBQuery.

 @param error Pointer to an NSError that will be set if necessary.
 @result Returns a TGBObject, or nil if none was found.
 */
- (TGBObject *)getFirstObject:(NSError **)error
{
    return [self getFirstObjectWithBlock:NULL waitUntilDone:YES error:error];
}

- (TGBObject *)getFirstObjectAndThrowsWithError:(NSError * _Nullable __autoreleasing *)error {
    return [self getFirstObject:error];
}

/*!
 Gets an object asynchronously and calls the given block with the result.

 This mutates the TGBQuery.

 @param block The block to execute. The block should have the following argument signature:(TGBObject *object, NSError *error) result will be nil if error is set OR no object was found matching the query. error will be nil if result is set OR if the query succeeded, but found no results.
 */
- (void)getFirstObjectInBackgroundWithBlock:(TGBObjectResultBlock)resultBlock
{
    [self getFirstObjectWithBlock:resultBlock waitUntilDone:NO error:NULL];
}

- (TGBObject *)getFirstObjectWithBlock:(TGBObjectResultBlock)resultBlock
                        waitUntilDone:(BOOL)wait
                                error:(NSError **)theError {
    if (wait) [self raiseSyncExceptionIfNeed];

    TGBObject __block *theResultObject = nil;
    BOOL __block hasCalledBack = NO;
    NSError __block *blockError = nil;

    NSString *path = [self queryPath];
    [self assembleParameters];
    [self.parameters setObject:@(1) forKey:@"limit"];

    [[TGBPaasClient sharedInstance] getObject:path withParameters:self.parameters policy:self.cachePolicy maxCacheAge:self.maxCacheAge block:^(id object, NSError *error) {
        NSString *className = object[@"className"];
        NSArray *results = [object objectForKey:@"results"];
        BOOL end = [[object objectForKey:@"end"] boolValue];
        NSError *wrappedError = error;

        if (error) {
            [TGBUtils callObjectResultBlock:resultBlock object:nil error:error];
        } else if (results.count == 0) {
            wrappedError = LCError(kAVErrorObjectNotFound, @"no results matched the query", nil);
            [TGBUtils callObjectResultBlock:resultBlock object:nil error:wrappedError];
        } else {
            NSMutableArray * array = [self processResults:results className:className];
            [self processEnd:end];
            TGBObject *resultObject = [array objectAtIndex:0];
            [TGBUtils callObjectResultBlock:resultBlock object:resultObject error:error];

            theResultObject = resultObject;
        }

        if (wait) {
            blockError = wrappedError;
            hasCalledBack = YES;
        }
    }];

    if (wait) {
        [TGBUtils warnMainThreadIfNecessary];
        AV_WAIT_TIL_TRUE(hasCalledBack, 0.1);
    };

    if (theError != NULL) *theError = blockError;
    return theResultObject;
}

/*!
 Gets an object asynchronously and calls the given callback with the results.

 This mutates the TGBQuery.

 @param target The object to call the selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(TGBObject *)result error:(NSError *)error. result will be nil if error is set OR no object was found matching the query. error will be nil if result is set OR if the query succeeded, but found no results.
 */
- (void)getFirstObjectInBackgroundWithTarget:(id)target selector:(SEL)selector
{
    [self getFirstObjectInBackgroundWithBlock:^(TGBObject *object, NSError *error) {
        [TGBUtils performSelectorIfCould:target selector:selector object:object object:error];
    }];
}

#pragma mark -
#pragma mark Count methods

/** @name Counting the Matches in a Query */

/*!
  Counts objects based on the constructed query.
 @result Returns the number of TGBObjects that match the query, or -1 if there is an error.
 */
- (NSInteger)countObjects
{
    return [self countObjects:NULL];
}

/*!
  Counts objects based on the constructed query and sets an error if there was one.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns the number of TGBObjects that match the query, or -1 if there is an error.
 */
- (NSInteger)countObjects:(NSError **)error
{
    return [self countObjectsWithBlock:NULL waitUntilDone:YES error:error];
}

- (NSInteger)countObjectsAndThrowsWithError:(NSError * _Nullable __autoreleasing *)error {
    return [self countObjects:error];
}

/*!
 Counts objects asynchronously and calls the given block with the counts.
 @param block The block to execute. The block should have the following argument signature:
 (int count, NSError *error)
 */
- (void)countObjectsInBackgroundWithBlock:(AVIntegerResultBlock)block
{
    [self countObjectsWithBlock:block waitUntilDone:NO error:NULL];
}

- (NSInteger)countObjectsWithBlock:(AVIntegerResultBlock)block
                     waitUntilDone:(BOOL)wait
                             error:(NSError **)theError {
    if (wait) [self raiseSyncExceptionIfNeed];

    NSInteger __block theResultCount = -1;
    BOOL __block hasCalledBack = NO;
    NSError __block *blockError = nil;

    NSString *path = [self queryPath];
    [self assembleParameters];
    [self.parameters setObject:@1 forKey:@"count"];
    [self.parameters setObject:@0 forKey:@"limit"];

    [[TGBPaasClient sharedInstance] getObject:path withParameters:self.parameters policy:self.cachePolicy maxCacheAge:self.maxCacheAge block:^(id object, NSError *error) {
        NSInteger count = [[object objectForKey:@"count"] integerValue];
        [TGBUtils callIntegerResultBlock:block number:count error:error];

        if (wait) {
            blockError = error;
            hasCalledBack = YES;
            theResultCount = count;
        }
    }];

    if (wait) {
        [TGBUtils warnMainThreadIfNecessary];
        AV_WAIT_TIL_TRUE(hasCalledBack, 0.1);
    };

    if (theError != NULL) *theError = blockError;
    return theResultCount;
}

/*!
  Counts objects asynchronously and calls the given callback with the count.
 @param target The object to call the selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSNumber *)result error:(NSError *)error. */
- (void)countObjectsInBackgroundWithTarget:(id)target selector:(SEL)selector
{
    [self countObjectsInBackgroundWithBlock:^(NSInteger number, NSError *error) {
        [TGBUtils performSelectorIfCould:target selector:selector object:@(number) object:error];
    }];
}

#pragma mark -
#pragma mark Cancel methods

/** @name Cancelling a Query */

/*!
 Cancels the current network request (if any). Ensures that callbacks won't be called.
 */
- (void)cancel
{
    /* NOTE: absolutely, following code is ugly and fragile.
       However, the compatibility is the chief culprit of this tragedy.
       Detail discussion: https://github.com/leancloud/paas/issues/828
       We should deprecate this method in future.
     */
    NSMapTable *table = [[TGBPaasClient sharedInstance].requestTable copy];
    NSString *URLString = [[TGBPaasClient sharedInstance] absoluteStringFromPath:[self queryPath] parameters:self.parameters];

    for (NSString *key in table) {
        if ([URLString isEqualToString:key]) {
            NSURLSessionDataTask *request = [table objectForKey:key];
            [request cancel];
        }
    }
}

- (BOOL)hasCachedResult
{
    [self assembleParameters];
    NSString *key = [[TGBPaasClient sharedInstance] absoluteStringFromPath:[self queryPath] parameters:self.parameters];
    return [[TGBCacheManager sharedInstance] hasCacheForKey:key];
}

/*!
 Clears the cached result for this query.  If there is no cached result, this is a noop.
 */
- (void)clearCachedResult
{
    [self assembleParameters];
    NSString *key = [[TGBPaasClient sharedInstance] absoluteStringFromPath:[self queryPath] parameters:self.parameters];
    [[TGBCacheManager sharedInstance] clearCacheForKey:key];
}

/*!
 Clears the cached results for all queries.
 */
+ (void)clearAllCachedResults
{
    [TGBCacheManager clearAllCache];
}

#pragma mark - Handle the data for communication with server
- (NSString *)queryPath {
    return [TGBObjectUtils objectPath:self.className objectId:nil];
}

+ (NSDictionary *)dictionaryFromIncludeKeys:(NSArray *)array {
    return @{@"include": [array componentsJoinedByString:@","]};
}

- (NSMutableDictionary *)assembleParameters {
    [self.parameters removeAllObjects];

    if ([self.where allKeys].count > 0)
    {
        [self.parameters setObject:[self whereString] forKey:@"where"];
    }

    if (self.limit > 0)
    {
        [self.parameters setObject:@(self.limit) forKey:@"limit"];
    }
    if (self.skip > 0)
    {
        [self.parameters setObject:@(self.skip) forKey:@"skip"];
    }
    if (self.order.length > 0)
    {
        [self.parameters setObject:self.order forKey:@"order"];
    }
    if (self.include.count > 0)
    {
        NSString * myIncludes = [[self.include allObjects] componentsJoinedByString:@","];
        [self.parameters setObject:myIncludes forKey:@"include"];
    }
    if (self.selectedKeys.count > 0)
    {
        NSString * keys = [[self.selectedKeys allObjects] componentsJoinedByString:@","];
        [self.parameters setObject:keys forKey:@"keys"];
    }
    if (self.includeACL)
    {
        [self.parameters setObject:@"true" forKey:@"returnACL"];
    }
    if ([self.extraParameters allKeys].count > 0) {
        [self.parameters addEntriesFromDictionary:self.extraParameters];
    }
    return self.parameters;
}

- (NSString *)whereString {
    NSDictionary *dic = [TGBObjectUtils dictionaryFromDictionary:self.where];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:NULL];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)whereJSONDictionary {
    NSData *data = [[self whereString] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    return dictionary;
}

#pragma mark - Util methods
- (void)raiseSyncExceptionIfNeed {
    if (self.cachePolicy == kAVCachePolicyCacheThenNetwork) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"kAVCachePolicyCacheThenNetwork can't not use in sync methods"];
    };
}

#pragma mark - Advanced Settings


@end
