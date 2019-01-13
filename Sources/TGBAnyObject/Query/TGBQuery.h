// TGBQuery.m
// Copyright 2013 AVOS Inc. All rights reserved.

#import <Foundation/Foundation.h>
#import "TGBGeoPoint.h"
#import "TGBObject.h"
#import "TGBCloudQueryResult.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 A class that defines a query that is used to query for TGBObjects.
 */
@interface TGBQuery : NSObject

/*!
 * Distance unit for query.
 */
typedef NS_ENUM(NSInteger, TGBQueryDistanceUnit) {
    TGBQueryDistanceUnitMile = 1,
    TGBQueryDistanceUnitKilometer,
    TGBQueryDistanceUnitRadian
};

#pragma mark Query options

/** @name Creating a Query for a Class */

/*!
 Returns a TGBQuery for a given class.
 @param className The class to query on.
 @return A TGBQuery object.
 */
+ (instancetype)queryWithClassName:(NSString *)className;

/*!
 *  使用 CQL 查询
 *  @param cql CQL 字符串
 *  @return 查询结果
 */
+ (nullable TGBCloudQueryResult *)doCloudQueryWithCQL:(NSString *)cql;

/*!
 *  使用 CQL 查询
 *  @param cql CQL 字符串
 *  @param error 用于返回错误结果
 *  @return 查询结果
 */
+ (nullable TGBCloudQueryResult *)doCloudQueryWithCQL:(NSString *)cql error:(NSError **)error;

/*!
 *  使用 CQL 查询
 *  @param cql CQL 字符串
 *  @param pvalues 参数列表
 *  @param error 用于返回错误结果
 *  @return 查询结果
 */
+ (nullable TGBCloudQueryResult *)doCloudQueryWithCQL:(NSString *)cql pvalues:(nullable NSArray *)pvalues error:(NSError **)error;

/*!
 *  使用 CQL 异步查询
 *  @param cql CQL 字符串
 *  @param callback 查询结果回调
 */
+ (void)doCloudQueryInBackgroundWithCQL:(NSString *)cql callback:(TGBCloudQueryCallback)callback;

/*!
 *  使用 CQL 异步查询
 *  @param cql CQL 字符串
 *  @param pvalues 参数列表
 *  @param callback 查询结果回调
 */
+ (void)doCloudQueryInBackgroundWithCQL:(NSString *)cql pvalues:(nullable NSArray *)pvalues callback:(TGBCloudQueryCallback)callback;

/*!
 Initializes the query with a class name.
 @param newClassName The class name.
 */
- (instancetype)initWithClassName:(NSString *)newClassName;

/*!
  The class name to query for
 */
@property (nonatomic, copy) NSString *className;

/** @name Adding Basic Constraints */

/*!
 Make the query include TGBObjects that have a reference stored at the provided key.
 This has an effect similar to a join.  You can use dot notation to specify which fields in
 the included object are also fetch.
 @param key The key to load child TGBObjects for.
 */
- (void)includeKey:(NSString *)key;

/*!
 Make the query restrict the fields of the returned TGBObjects to include only the provided keys.
 If this is called multiple times, then all of the keys specified in each of the calls will be included.
 @param keys The keys to include in the result.
 */
- (void)selectKeys:(NSArray *)keys;

/*!
 Add a constraint that requires a particular key exists.
 @param key The key that should exist.
 */
- (void)whereKeyExists:(NSString *)key;

/*!
 Add a constraint that requires a key not exist.
 @param key The key that should not exist.
 */
- (void)whereKeyDoesNotExist:(NSString *)key;

/*!
  Add a constraint to the query that requires a particular key's object to be equal to the provided object.
 @param key The key to be constrained.
 @param object The object that must be equalled.
 */
- (void)whereKey:(NSString *)key equalTo:(id)object;

/*!
  Add a constraint to the query that requires a particular key's object to be less than the provided object.
 @param key The key to be constrained.
 @param object The object that provides an upper bound.
 */
- (void)whereKey:(NSString *)key lessThan:(id)object;

/*!
  Add a constraint to the query that requires a particular key's object to be less than or equal to the provided object.
 @param key The key to be constrained.
 @param object The object that must be equalled.
 */
- (void)whereKey:(NSString *)key lessThanOrEqualTo:(id)object;

/*!
  Add a constraint to the query that requires a particular key's object to be greater than the provided object.
 @param key The key to be constrained.
 @param object The object that must be equalled.
 */
- (void)whereKey:(NSString *)key greaterThan:(id)object;

/*!
  Add a constraint to the query that requires a particular key's object to be greater than or equal to the provided object.
 @param key The key to be constrained.
 @param object The object that must be equalled.
 */
- (void)whereKey:(NSString *)key greaterThanOrEqualTo:(id)object;

/*!
  Add a constraint to the query that requires a particular key's object to be not equal to the provided object.
 @param key The key to be constrained.
 @param object The object that must not be equalled.
 */
- (void)whereKey:(NSString *)key notEqualTo:(id)object;

/*!
  Add a constraint to the query that requires a particular key's object to be contained in the provided array.
 @param key The key to be constrained.
 @param array The possible values for the key's object.
 */
- (void)whereKey:(NSString *)key containedIn:(NSArray *)array;

/*!
 Add a constraint to the query that requires a particular key's object not be contained in the provided array.
 @param key The key to be constrained.
 @param array The list of values the key's object should not be.
 */
- (void)whereKey:(NSString *)key notContainedIn:(NSArray *)array;

/*!
 Add a constraint to the query that requires a particular key's array contains every element of the provided array.
 @param key The key to be constrained.
 @param array The array of values to search for.
 */
- (void)whereKey:(NSString *)key containsAllObjectsInArray:(NSArray *)array;

/** @name Adding Location Constraints */

/*!
 Add a constraint to the query that requires a particular key's coordinates (specified via TGBGeoPoint) be near
 a reference point.  Distance is calculated based on angular distance on a sphere.  Results will be sorted by distance
 from reference point.
 @param key The key to be constrained.
 @param geoPoint The reference point.  A TGBGeoPoint.
 */
- (void)whereKey:(NSString *)key nearGeoPoint:(TGBGeoPoint *)geoPoint;

/*!
 Add a constraint to the query that requires a particular key's coordinates (specified via TGBGeoPoint) be near
 a reference point and within the maximum distance specified (in miles).  Distance is calculated based on
 a spherical coordinate system.  Results will be sorted by distance (nearest to farthest) from the reference point.
 @param key The key to be constrained.
 @param geoPoint The reference point.  A TGBGeoPoint.
 @param maxDistance Maximum distance in miles.
 */
- (void)whereKey:(NSString *)key nearGeoPoint:(TGBGeoPoint *)geoPoint withinMiles:(double)maxDistance;

/*!
 Add a constraint to the query that requires a particular key's coordinates (specified via TGBGeoPoint) be near
 a reference point and within the maximum distance specified (in kilometers).  Distance is calculated based on
 a spherical coordinate system.  Results will be sorted by distance (nearest to farthest) from the reference point.
 @param key The key to be constrained.
 @param geoPoint The reference point.  A TGBGeoPoint.
 @param maxDistance Maximum distance in kilometers.
 */
- (void)whereKey:(NSString *)key nearGeoPoint:(TGBGeoPoint *)geoPoint withinKilometers:(double)maxDistance;

/*!
 Add a constraint to the query that requires a particular key's coordinates (specified via TGBGeoPoint) be near
 a reference point and within the maximum distance specified (in radians).  Distance is calculated based on
 angular distance on a sphere.  Results will be sorted by distance (nearest to farthest) from the reference point.
 @param key The key to be constrained.
 @param geoPoint The reference point.  A TGBGeoPoint.
 @param maxDistance Maximum distance in radians.
 */
- (void)whereKey:(NSString *)key nearGeoPoint:(TGBGeoPoint *)geoPoint withinRadians:(double)maxDistance;

/*!
 * Add a constraint to the query that requires a particular key's coordinates (specified via TGBGeoPoint) be near
 * a reference point and within the maximum and miTGBum distance. Distance is calculated based on
 * angular distance on a sphere. Results will be sorted by distance (nearest to farthest) from the reference point.
 *
 * @param key              The key to be constrained.
 * @param geoPoint         The reference point, a TGBGeoPoint.
 * @param maxDistance      Maximum distance value. If negative (like -1), the maximum constraint will be ignored.
 * @param maxDistanceUnit  Maximum distance unit.
 * @param minDistance      MiTGBum distance value. If negative (like -1), the miTGBum constraint will be ignored.
 * @param minDistanceUnit  MiTGBum distance unit.
 */
- (void)whereKey:(NSString *)key
    nearGeoPoint:(TGBGeoPoint *)geoPoint
     maxDistance:(double)maxDistance
 maxDistanceUnit:(TGBQueryDistanceUnit)maxDistanceUnit
     minDistance:(double)minDistance
 minDistanceUnit:(TGBQueryDistanceUnit)minDistanceUnit;

/*!
 * Add a constraint to the query that requires a particular key's coordinates (specified via TGBGeoPoint) be near
 * a reference point and within the miTGBum distance. Distance is calculated based on
 * angular distance on a sphere. Results will be sorted by distance (nearest to farthest) from the reference point.
 *
 * @param key              The key to be constrained.
 * @param geoPoint         The reference point, a TGBGeoPoint.
 * @param minDistance      MiTGBum distance value. If negative (like -1), the miTGBum constraint will be ignored.
 * @param minDistanceUnit  MiTGBum distance unit.
 */
- (void)whereKey:(NSString *)key
    nearGeoPoint:(TGBGeoPoint *)geoPoint
     minDistance:(double)minDistance
 minDistanceUnit:(TGBQueryDistanceUnit)minDistanceUnit;

/*!
 Add a constraint to the query that requires a particular key's coordinates (specified via TGBGeoPoint) be
 contained within a given rectangular geographic bounding box.
 @param key The key to be constrained.
 @param southwest The lower-left inclusive corner of the box.
 @param northeast The upper-right inclusive corner of the box.
 */
- (void)whereKey:(NSString *)key withinGeoBoxFromSouthwest:(TGBGeoPoint *)southwest toNortheast:(TGBGeoPoint *)northeast;

/** @name Adding String Constraints */

/*!
 Add a regular expression constraint for finding string values that match the provided regular expression.
 This may be slow for large datasets.
 @param key The key that the string to match is stored in.
 @param regex The regular expression pattern to match.
 */
- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex;

/*!
 Add a regular expression constraint for finding string values that match the provided regular expression.
 This may be slow for large datasets.
 @param key The key that the string to match is stored in.
 @param regex The regular expression pattern to match.
 @param modifiers Any of the following supported PCRE modifiers:<br><code>i</code> - Case insensitive search<br><code>m</code> - Search across multiple lines of input
 */
- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex modifiers:(nullable NSString *)modifiers;

/*!
 Add a constraint for finding string values that contain a provided substring.
 This will be slow for large datasets.
 @param key The key that the string to match is stored in.
 @param substring The substring that the value must contain.
 */
- (void)whereKey:(NSString *)key containsString:(NSString *)substring;

/*!
 Add a constraint for finding string values that start with a provided prefix.
 This will use smart indexing, so it will be fast for large datasets.
 @param key The key that the string to match is stored in.
 @param prefix The substring that the value must start with.
 */
- (void)whereKey:(NSString *)key hasPrefix:(NSString *)prefix;

/*!
 Add a constraint for finding string values that end with a provided suffix.
 This will be slow for large datasets.
 @param key The key that the string to match is stored in.
 @param suffix The substring that the value must end with.
 */
- (void)whereKey:(NSString *)key hasSuffix:(NSString *)suffix;

/** @name Adding Subqueries */

/*!
 Returns a TGBQuery that is the or of the passed in TGBQuerys.
 @param queries The list of queries to or together.
 @return a TGBQuery that is the or of the passed in TGBQuerys.
 */
+ (TGBQuery *)orQueryWithSubqueries:(NSArray *)queries;

/*!
 Returns a TGBQuery that is the AND of the passed in TGBQuerys.
 @param queries The list of queries to AND together.
 @return a TGBQuery that is the AND of the passed in TGBQuerys.
 */
+ (TGBQuery *)andQueryWithSubqueries:(NSArray *)queries;

/*!
 Adds a constraint that requires that a key's value matches a value in another key
 in objects returned by a sub query.
 @param key The key that the value is stored
 @param otherKey The key in objects in the returned by the sub query whose value should match
 @param query The query to run.
 */
- (void)whereKey:(NSString *)key matchesKey:(NSString *)otherKey inQuery:(TGBQuery *)query;

/*!
 Adds a constraint that requires that a key's value NOT match a value in another key
 in objects returned by a sub query.
 @param key The key that the value is stored
 @param otherKey The key in objects in the returned by the sub query whose value should match
 @param query The query to run.
 */
- (void)whereKey:(NSString *)key doesNotMatchKey:(NSString *)otherKey inQuery:(TGBQuery *)query;

/*!
 Add a constraint that requires that a key's value matches a TGBQuery constraint.
 This only works where the key's values are TGBObjects or arrays of TGBObjects.
 @param key The key that the value is stored in
 @param query The query the value should match
 */
- (void)whereKey:(NSString *)key matchesQuery:(TGBQuery *)query;

/*!
 Add a constraint that requires that a key's value to not match a TGBQuery constraint.
 This only works where the key's values are TGBObjects or arrays of TGBObjects.
 @param key The key that the value is stored in
 @param query The query the value should not match
 */
- (void)whereKey:(NSString *)key doesNotMatchQuery:(TGBQuery *)query;


/*!
 Matches any array with the number of elements specified by count
 @param key The key that the value is stored in, value should be kind of array
 @param count the array size
 */
- (void)whereKey:(NSString *)key sizeEqualTo:(NSUInteger)count;

#pragma mark -
#pragma mark Sorting

/** @name Sorting */

/*!
 Sort the results in ascending order with the given key.
 @param key The key to order by.
 */
- (void)orderByAscending:(NSString *)key;

/*!
 Also sort in ascending order by the given key.  The previous keys provided will
 precedence over this key.
 @param key The key to order bye
 */
- (void)addAscendingOrder:(NSString *)key;

/*!
 Sort the results in descending order with the given key.
 @param key The key to order by.
 */
- (void)orderByDescending:(NSString *)key;
/*!
 Also sort in descending order by the given key.  The previous keys provided will
 precedence over this key.
 @param key The key to order bye
 */
- (void)addDescendingOrder:(NSString *)key;

/*!
 Sort the results in descending order with the given descriptor.
 @param sortDescriptor The NSSortDescriptor to order by.
 */
- (void)orderBySortDescriptor:(NSSortDescriptor *)sortDescriptor;

/*!
 Sort the results in descending order with the given descriptors.
 @param sortDescriptors An NSArray of NSSortDescriptor instances to order by.
 */
- (void)orderBySortDescriptors:(NSArray *)sortDescriptors;

#pragma mark -
#pragma mark Get methods

/** @name Getting Objects by ID */

/*!
 Returns a TGBObject with a given class and id.
 @param objectClass The class name for the object that is being requested.
 @param objectId The id of the object that is being requested.
 @return The TGBObject if found. Returns nil if the object isn't found, or if there was an error.
 */
+ (nullable TGBObject *)getObjectOfClass:(NSString *)objectClass
                               objectId:(NSString *)objectId;

/*!
 Returns a TGBObject with a given class and id and sets an error if necessary.
 @param objectClass The class name for the object that is being requested.
 @param objectId The id of the object that is being requested.
 @param error Pointer to an NSError that will be set if necessary.
 @return The TGBObject if found. Returns nil if the object isn't found, or if there was an error.
 */
+ (nullable TGBObject *)getObjectOfClass:(NSString *)objectClass
                               objectId:(NSString *)objectId
                                  error:(NSError **)error;

/*!
 Returns a TGBObject with the given id.
 
 This mutates the TGBQuery.
 
 @param objectId The id of the object that is being requested.
 @return The TGBObject if found. Returns nil if the object isn't found, or if there was an error.
 */
- (nullable TGBObject *)getObjectWithId:(NSString *)objectId;

/*!
 Returns a TGBObject with the given id and sets an error if necessary.
 
 This mutates the TGBQuery
 
 @param objectId The id of the object that is being requested.
 @param error Pointer to an NSError that will be set if necessary.
 @return The TGBObject if found. Returns nil if the object isn't found, or if there was an error.
 */
- (nullable TGBObject *)getObjectWithId:(NSString *)objectId error:(NSError **)error;

/*!
 Gets a TGBObject asynchronously and calls the given block with the result. 
 
 This mutates the TGBQuery
 @param objectId The id of the object being requested.
 @param block The block to execute. The block should have the following argument signature: (NSArray *object, NSError *error)
 */
- (void)getObjectInBackgroundWithId:(NSString *)objectId
                              block:(TGBObjectResultBlock)block;

/*!
 Gets a TGBObject asynchronously.
 
 This mutates the TGBQuery
 
 @param objectId The id of the object being requested.
 @param target The target for the callback selector.
 @param selector The selector for the callback. It should have the following signature: (void)callbackWithResult:(TGBObject *)result error:(NSError *)error. result will be nil if error is set and vice versa.
 */
- (void)getObjectInBackgroundWithId:(NSString *)objectId
                             target:(id)target
                           selector:(SEL)selector;

#pragma mark -
#pragma mark Getting Users

/*! @name Getting User Objects */

/*!
 Returns a TGBUsered with a given id.
 @param objectId The id of the object that is being requested.
 @return The TGBUsered if found. Returns nil if the object isn't found, or if there was an error.
 */
+ (nullable TGBUsered *)getUserObjectWithId:(NSString *)objectId;

/*!
 Returns a TGBUsered with a given class and id and sets an error if necessary.
 
 @param objectId The id of the object that is being requested.
 @param error Pointer to an NSError that will be set if necessary.
 @return The TGBUsered if found. Returns nil if the object isn't found, or if there was an error.
 */
+ (nullable TGBUsered *)getUserObjectWithId:(NSString *)objectId
                                   error:(NSError **)error;

/*!
 Deprecated.  Please use [TGBUsered query] instead.
 */
+ (instancetype)queryForUser AV_DEPRECATED("Use +[TGBUsered query] instead.");

#pragma mark -
#pragma mark Find methods

/** @name Getting all Matches for a Query */

/*!
 Finds objects based on the constructed query.
 @return an array of TGBObjects that were found.
 */
- (nullable NSArray *)findObjects;

/*!
 Finds objects based on the constructed query and sets an error if there was one.
 @param error Pointer to an NSError that will be set if necessary.
 @return an array of TGBObjects that were found.
 */
- (nullable NSArray *)findObjects:(NSError **)error;

/*!
 An alias of `-[TGBQuery findObjects:]` methods that supports Swift exception.
 @seealso `-[TGBQuery findObjects:]`
 */
- (nullable NSArray *)findObjectsAndThrowsWithError:(NSError **)error;

/*!
 Finds objects asynchronously and calls the given block with the results.
 @param block The block to execute. The block should have the following argument signature:(NSArray *objects, NSError *error) 
 */
- (void)findObjectsInBackgroundWithBlock:(AVArrayResultBlock)block;

/*!
 Finds objects asynchronously and calls the given callback with the results.
 @param target The object to call the selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSArray *)result error:(NSError *)error. result will be nil if error is set and vice versa.
 */
- (void)findObjectsInBackgroundWithTarget:(id)target selector:(SEL)selector;


/*!
 Remove objects asynchronously and calls the given block with the results.
 @param block The block to execute. The block should have the following argument signature:(NSArray *objects, NSError *error)
 */
- (void)deleteAllInBackgroundWithBlock:(AVBooleanResultBlock)block;


/** @name Getting the First Match in a Query */

/*!
 Gets an object based on the constructed query.
 
 This mutates the TGBQuery.
 
 @return a TGBObject, or nil if none was found.
 */
- (nullable TGBObject *)getFirstObject;

/*!
 Gets an object based on the constructed query and sets an error if any occurred.

 This mutates the TGBQuery.
 
 @param error Pointer to an NSError that will be set if necessary.
 @return a TGBObject, or nil if none was found.
 */
- (nullable TGBObject *)getFirstObject:(NSError **)error;

/*!
 An alias of `-[TGBQuery getFirstObject:]` methods that supports Swift exception.
 @seealso `-[TGBQuery getFirstObject:]`
 */
- (nullable TGBObject *)getFirstObjectAndThrowsWithError:(NSError **)error;

/*!
 Gets an object asynchronously and calls the given block with the result.
 
 This mutates the TGBQuery.
 
 @param block The block to execute. The block should have the following argument signature:(TGBObject *object, NSError *error) result will be nil if error is set OR no object was found matching the query. error will be nil if result is set OR if the query succeeded, but found no results.
 */
- (void)getFirstObjectInBackgroundWithBlock:(TGBObjectResultBlock)block;

/*!
 Gets an object asynchronously and calls the given callback with the results.
 
 This mutates the TGBQuery.
 
 @param target The object to call the selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(TGBObject *)result error:(NSError *)error. result will be nil if error is set OR no object was found matching the query. error will be nil if result is set OR if the query succeeded, but found no results.
 */
- (void)getFirstObjectInBackgroundWithTarget:(id)target selector:(SEL)selector;

#pragma mark -
#pragma mark Count methods

/** @name Counting the Matches in a Query */

/*!
  Counts objects based on the constructed query.
 @return the number of TGBObjects that match the query, or -1 if there is an error.
 */
- (NSInteger)countObjects;

/*!
  Counts objects based on the constructed query and sets an error if there was one.
 @param error Pointer to an NSError that will be set if necessary.
 @return the number of TGBObjects that match the query, or -1 if there is an error.
 */
- (NSInteger)countObjects:(NSError **)error;

/*!
 An alias of `-[TGBQuery countObjects:]` methods that supports Swift exception.
 @seealso `-[TGBQuery countObjects:]`
 */
- (NSInteger)countObjectsAndThrowsWithError:(NSError **)error;

/*!
 Counts objects asynchronously and calls the given block with the counts.
 @param block The block to execute. The block should have the following argument signature:
 (int count, NSError *error) 
 */
- (void)countObjectsInBackgroundWithBlock:(AVIntegerResultBlock)block;

/*!
  Counts objects asynchronously and calls the given callback with the count.
 @param target The object to call the selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSNumber *)result error:(NSError *)error. */
- (void)countObjectsInBackgroundWithTarget:(id)target selector:(SEL)selector;

#pragma mark -
#pragma mark Cancel methods

/** @name Cancelling a Query */

/*!
 Cancels the current network request (if any). Ensures that callbacks won't be called.
 */
- (void)cancel;

#pragma mark -
#pragma mark Pagination properties


/** @name Paginating Results */
/*!
 A limit on the number of objects to return.  Note: If you are calling findObject with limit=1, you may find it easier to use getFirst instead.
 */
@property (nonatomic, assign) NSInteger limit;

/*!
 The number of objects to skip before returning any.
 */
@property (nonatomic, assign) NSInteger skip;

/**
 Include ACL for object.
 */
@property (nonatomic, assign) BOOL includeACL;

#pragma mark -
#pragma mark Cache methods

/** @name Controlling Caching Behavior */

/*!
 The cache policy to use for requests.
 */
@property (readwrite, assign) AVCachePolicy cachePolicy;

/* !
 The age(seconds) after which a cached value will be ignored.
 */
@property (readwrite, assign) NSTimeInterval maxCacheAge;

/*!
 Returns whether there is a cached result for this query.
 @return YES if there is a cached result for this query, and NO otherwise.
 */
- (BOOL)hasCachedResult;

/*!
 Clears the cached result for this query.  If there is no cached result, this is a noop.
 */
- (void)clearCachedResult;

/*!
 Clears the cached results for all queries.
 */
+ (void)clearAllCachedResults; 

#pragma mark - Advanced Settings

/** @name Advanced Settings */

/*!
 Whether or not performance tracing should be done on the query.
 This should not be set in most cases.
 */
@property (nonatomic, assign) BOOL trace;


@end

NS_ASSUME_NONNULL_END
