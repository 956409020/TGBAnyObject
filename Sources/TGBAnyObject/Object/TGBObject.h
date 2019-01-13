// TGBObject.h
// Copyright 2013 AVOS Inc. All rights reserved.

#import <Foundation/Foundation.h>
#import "TGBConstants.h"

@class TGBRelation;
@class TGBACL;
@class TGBSaveOption;

NS_ASSUME_NONNULL_BEGIN

/*!
 An object that is a local representation of data persisted to the LeanCloud. This is the
 main class that is used to interact with objects in your app.
*/

@interface TGBObject : NSObject <NSCoding>

#pragma mark Constructors

/*!
 Creates a reference to an existing TGBObject with an object ID.

 Calling isDataAvailable on this object will return NO until fetchIfNeeded or refresh has been called.

 @param objectId The object ID.
 @return An object with the given object ID.
 */
+ (instancetype)objectWithObjectId:(NSString *)objectId;

/*! @name Creating a TGBObject */

/*!
 Creates a new TGBObject with a class name.
 @param className A class name can be any alphanumeric string that begins with a letter. It represents an object in your app, like a User of a Document.
 @return the object that is instantiated with the given class name.
 */
+ (instancetype)objectWithClassName:(NSString *)className;

/*!
 Creates a reference to an existing TGBObject for use in creating associations between TGBObjects.

 Calling isDataAvailable on this object will return NO until fetchIfNeeded or refresh has been called.

 @param className The object's class name.
 @param objectId The object ID for the referenced object.
 @return An object with the given class name and object ID.
 */
+ (instancetype)objectWithClassName:(NSString *)className objectId:(NSString *)objectId;

/*!
 Creates a new TGBObject with a class name, initialized with data constructed from the specified set of objects and keys.
 @param className The object's class.
 @param dictionary An NSDictionary of keys and objects to set on the new TGBObject.
 @return A TGBObject with the given class name and set with the given data.
 */
+ (instancetype)objectWithClassName:(NSString *)className dictionary:(NSDictionary *)dictionary;

/*!
 Initializes a new TGBObject with a class name.
 @param newClassName A class name can be any alphanumeric string that begins with a letter. It represents an object in your app, like a User or a Document.
 @return the object that is instantiated with the given class name.
 */
- (instancetype)initWithClassName:(NSString *)newClassName;

#pragma mark - Bahaviour Control

/**
 *  If YES, Null value will be converted to nil when getting object for key. Because [NSNull null] is truthy value in Objective-C. Default is YES and suggested.
 *  @param yesOrNo default is YES.
 *  @warning It takes effects only when getting object for key. You can still use Null in setObject:forKey.
 */
+ (void)setConvertingNullToNil:(BOOL)yesOrNo;

#pragma mark - Properties

/*! @name Managing Object Properties */

/*!
 The id of the object.
 */
@property (nonatomic, copy, readonly, nullable) NSString *objectId;

/*!
 When the object was last updated.
 */
@property (nonatomic, strong, readonly, nullable) NSDate *updatedAt;

/*!
 When the object was created.
 */
@property (nonatomic, strong, readonly, nullable) NSDate *createdAt;

/*!
 The class name of the object.
 */
@property (nonatomic, copy, readonly) NSString *className;

/*!
 The ACL for this object.
 */
@property (nonatomic, strong, nullable) TGBACL *ACL;

/*!
 Returns an array of the keys contained in this object. This does not include
 createdAt, updatedAt, authData, or objectId. It does include things like username
 and ACL.
 */
- (NSArray *)allKeys;

#pragma mark -
#pragma mark Get and set

/*!
 Returns the object associated with a given key.
 @param key The key that the object is associated with.
 @return The value associated with the given key, or nil if no value is associated with key.
 */
- (nullable id)objectForKey:(NSString *)key;

/*!
 Sets the object associated with a given key.
 @param object The object.
 @param key The key.
 */
- (void)setObject:(nullable id)object forKey:(NSString *)key;

/*!
 Unsets a key on the object.
 @param key The key.
 */
- (void)removeObjectForKey:(NSString *)key;

/*!
 * In LLVM 4.0 (XCode 4.5) or higher allows myTGBObject[key].
 @param key The key.
 */
- (nullable id)objectForKeyedSubscript:(NSString *)key;

/*!
 * In LLVM 4.0 (XCode 4.5) or higher allows myObject[key] = value
 @param object The object.
 @param key The key.
 */
- (void)setObject:(nullable id)object forKeyedSubscript:(NSString *)key;

/*!
 Returns the relation object associated with the given key
 @param key The key that the relation is associated with.
 */
- (TGBRelation *)relationForKey:(NSString *)key;

#pragma mark -
#pragma mark Array add and remove

/*!
 Adds an object to the end of the array associated with a given key.
 @param object The object to add.
 @param key The key.
 */
- (void)addObject:(id)object forKey:(NSString *)key;

/*!
 Adds the objects contained in another array to the end of the array associated
 with a given key.
 @param objects The array of objects to add.
 @param key The key.
 */
- (void)addObjectsFromArray:(NSArray *)objects forKey:(NSString *)key;

/*!
 Adds an object to the array associated with a given key, only if it is not
 already present in the array. The position of the insert is not guaranteed.
 @param object The object to add.
 @param key The key.
 */
- (void)addUniqueObject:(id)object forKey:(NSString *)key;

/*!
 Adds the objects contained in another array to the array associated with
 a given key, only adding elements which are not already present in the array.
 The position of the insert is not guaranteed.
 @param objects The array of objects to add.
 @param key The key.
 */
- (void)addUniqueObjectsFromArray:(NSArray *)objects forKey:(NSString *)key;

/*!
 Removes all occurrences of an object from the array associated with a given
 key.
 @param object The object to remove.
 @param key The key.
 */
- (void)removeObject:(id)object forKey:(NSString *)key;

/*!
 Removes all occurrences of the objects contained in another array from the
 array associated with a given key.
 @param objects The array of objects to remove.
 @param key The key.
 */
- (void)removeObjectsInArray:(NSArray *)objects forKey:(NSString *)key;

#pragma mark -
#pragma mark Increment

/*!
 Increments the given key by 1.
 @param key The key.
 */
- (void)incrementKey:(NSString *)key;

/*!
 Increments the given key by a number.
 @param key The key.
 @param amount The amount to increment.
 */
- (void)incrementKey:(NSString *)key byAmount:(NSNumber *)amount;

#pragma mark -
#pragma mark Save

/*! @name Saving an Object to LeanCloud */

/*!
 Saves the TGBObject.
 @return whether the save succeeded.
 */
- (BOOL)save;

/*!
 Saves the TGBObject and sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 @return whether the save succeeded.
 */
- (BOOL)save:(NSError **)error;

/*!
 An alias of `-[TGBObject save:]` methods that supports Swift exception.
 @seealso `-[TGBObject save:]`
 */
- (BOOL)saveAndThrowsWithError:(NSError **)error;

/*!
 * Saves the TGBObject with option and sets an error if it occurs.
 * @param option Option for current save.
 * @param error  A pointer to an NSError that will be set if necessary.
 * @return Whether the save succeeded.
 */
- (BOOL)saveWithOption:(nullable TGBSaveOption *)option error:(NSError **)error;

/*!
 * Saves the TGBObject with option and sets an error if it occurs.
 * @param option     Option for current save.
 * @param eventually Whether save in eventually or not.
 * @param error      A pointer to an NSError that will be set if necessary.
 * @return Whether the save succeeded.
 * @note If eventually is specified to YES, request will be stored locally in an on-disk cache until it can be delivered to server.
 */
- (BOOL)saveWithOption:(nullable TGBSaveOption *)option eventually:(BOOL)eventually error:(NSError **)error;

/*!
 Saves the TGBObject asynchronously.
 */
- (void)saveInBackground;

/*!
 Saves the TGBObject asynchronously and executes the given callback block.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)saveInBackgroundWithBlock:(AVBooleanResultBlock)block;

/*!
 * Saves the TGBObject with option asynchronously and executes the given callback block.
 * @param option Option for current save.
 * @param block  The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)saveInBackgroundWithOption:(nullable TGBSaveOption *)option block:(AVBooleanResultBlock)block;

/*!
 * Saves the TGBObject with option asynchronously and executes the given callback block.
 * @param option Option for current save.
 * @param eventually Whether save in eventually or not.
 * @param block  The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)saveInBackgroundWithOption:(nullable TGBSaveOption *)option eventually:(BOOL)eventually block:(AVBooleanResultBlock)block;

/*!
 Saves the TGBObject asynchronously and calls the given callback.
 @param target The object to call selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSNumber *)result error:(NSError *)error. error will be nil on success and set if there was an error. [result boolValue] will tell you whether the call succeeded or not.
 */
- (void)saveInBackgroundWithTarget:(id)target selector:(SEL)selector;

/*!
 * Saves the TGBObject with option asynchronously and calls the given callback.
 * @param option   Option for current save.
 * @param target   The object to call selector on.
 * @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSNumber *)result error:(NSError *)error. error will be nil on success and set if there was an error. [result boolValue] will tell you whether the call succeeded or not.
 */
- (void)saveInBackgroundWithOption:(nullable TGBSaveOption *)option target:(id)target selector:(SEL)selector;

/*!
  @see saveEventually:
 */
- (void)saveEventually;

/*!
 Saves this object to the server at some unspecified time in the future, even if LeanCloud is currently inaccessible.
 Use this when you may not have a solid network connection, and don't need to know when the save completes.
 If there is some problem with the object such that it can't be saved, it will be silently discarded.  If the save
 completes successfully while the object is still in memory, then callback will be called.

 Objects saved with this method will be stored locally in an on-disk cache until they can be delivered to LeanCloud.
 They will be sent immediately if possible.  Otherwise, they will be sent the next time a network connection is
 available.  Objects saved this way will persist even after the app is closed, in which case they will be sent the
 next time the app is opened.  If more than 10MB of data is waiting to be sent, subsequent calls to saveEventually
 will cause old saves to be silently discarded until the connection can be re-established, and the queued objects
 can be saved.
 
 
 @param callback The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)saveEventually:(AVBooleanResultBlock)callback;

#pragma mark -
#pragma mark Save All

/*! @name Saving Many Objects to LeanCloud */

/*!
 Saves a collection of objects all at once.
 @param objects The array of objects to save.
 @return whether the save succeeded.
 */
+ (BOOL)saveAll:(NSArray *)objects;

/*!
 Saves a collection of objects all at once and sets an error if necessary.
 @param objects The array of objects to save.
 @param error Pointer to an NSError that will be set if necessary.
 @return whether the save succeeded.
 */
+ (BOOL)saveAll:(NSArray *)objects error:(NSError **)error;

/*!
 Saves a collection of objects all at once asynchronously.
 @param objects The array of objects to save.
 */
+ (void)saveAllInBackground:(NSArray *)objects;

/*!
 Saves a collection of objects all at once asynchronously and the block when done.
 @param objects The array of objects to save.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
+ (void)saveAllInBackground:(NSArray *)objects
                      block:(AVBooleanResultBlock)block;

/*!
 Saves a collection of objects all at once asynchronously and calls a callback when done.
 @param objects The array of objects to save.
 @param target The object to call selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithError:(NSError *)error. error will be nil on success and set if there was an error.
 */
+ (void)saveAllInBackground:(NSArray *)objects
                     target:(id)target
                   selector:(SEL)selector;

#pragma mark - Refresh

/*! @name Getting an Object from LeanCloud */

/*!
 Gets whether the TGBObject has been fetched.
 @return YES if the TGBObject is new or has been fetched or refreshed.  NO otherwise.
 */
- (BOOL)isDataAvailable;

#if AV_IOS_ONLY
// Deprecated and intentionally not available on the new OS X SDK

/*!
 Refreshes the TGBObject with the current data from the server.
 */
- (void)refresh;

/*!
 Refreshes the TGBObject with the current data from the server.
 @param keys Pointer to an NSArray that contains objects specified by the keys want to fetch.
 */
- (void)refreshWithKeys:(NSArray *)keys;

/*!
 Refreshes the TGBObject with the current data from the server and sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 @return success or not
 */
- (BOOL)refresh:(NSError **)error;

/*!
 An alias of `-[TGBObject refresh:]` methods that supports Swift exception.
 @seealso `-[TGBObject refresh:]`
 */
- (BOOL)refreshAndThrowsWithError:(NSError **)error;

/*!
 Refreshes the TGBObject asynchronously and executes the given callback block.
 @param block The block to execute. The block should have the following argument signature: (TGBObject *object, NSError *error)
 */
- (void)refreshInBackgroundWithBlock:(TGBObjectResultBlock)block;

/*!
 Refreshes the TGBObject with the current data from the server.
 @param keys Pointer to an NSArray that contains objects specified by the keys want to fetch.
 @param block The block to execute. The block should have the following argument signature: (TGBObject *object, NSError *error)
 */
- (void)refreshInBackgroundWithKeys:(NSArray *)keys
                              block:(TGBObjectResultBlock)block;

/*!
 Refreshes the TGBObject asynchronously and calls the given callback.
 @param target The target on which the selector will be called.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(TGBObject *)refreshedObject error:(NSError *)error. error will be nil on success and set if there was an error. refreshedObject will be the TGBObject with the refreshed data.
 */
- (void)refreshInBackgroundWithTarget:(id)target selector:(SEL)selector;
#endif

#pragma mark - Fetch

/*!
 Fetches the TGBObject with the current data from the server.
 */
- (BOOL)fetch;
/*!
 Fetches the TGBObject with the current data from the server and sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 @return success or not
 */
- (BOOL)fetch:(NSError **)error;

/*!
 An alias of `-[TGBObject fetch:]` methods that supports Swift exception.
 @seealso `-[TGBObject fetch:]`
 */
- (BOOL)fetchAndThrowsWithError:(NSError **)error;

/*!
 Fetches the TGBObject with the current data and specified keys from the server and sets an error if it occurs.
 @param keys Pointer to an NSArray that contains objects specified by the keys want to fetch.
 */
- (void)fetchWithKeys:(nullable NSArray *)keys;

/*!
 Fetches the TGBObject with the current data and specified keys from the server and sets an error if it occurs.
 @param keys Pointer to an NSArray that contains objects specified by the keys want to fetch.
 @param error Pointer to an NSError that will be set if necessary.
 @return success or not
 */
- (BOOL)fetchWithKeys:(nullable NSArray *)keys
                error:(NSError **)error;

/*!
 Fetches the TGBObject's data from the server if isDataAvailable is false.
 */
- (TGBObject *)fetchIfNeeded;

/*!
 Fetches the TGBObject's data from the server if isDataAvailable is false.
 @param error Pointer to an NSError that will be set if necessary.
 */
- (TGBObject *)fetchIfNeeded:(NSError **)error;

/*!
 An alias of `-[TGBObject fetchIfNeeded:]` methods that supports Swift exception.
 @seealso `-[TGBObject fetchIfNeeded:]`
 */
- (TGBObject *)fetchIfNeededAndThrowsWithError:(NSError **)error;

/*!
 Fetches the TGBObject's data from the server if isDataAvailable is false.
 @param keys Pointer to an NSArray that contains objects specified by the keys want to fetch.
 */
- (TGBObject *)fetchIfNeededWithKeys:(nullable NSArray *)keys;

/*!
 Fetches the TGBObject's data from the server if isDataAvailable is false.
 @param keys Pointer to an NSArray that contains objects specified by the keys want to fetch.
 @param error Pointer to an NSError that will be set if necessary.
 */
- (TGBObject *)fetchIfNeededWithKeys:(nullable NSArray *)keys
                              error:(NSError **)error;

/*!
 Fetches the TGBObject asynchronously and executes the given callback block.
 @param block The block to execute. The block should have the following argument signature: (TGBObject *object, NSError *error)
 */
- (void)fetchInBackgroundWithBlock:(TGBObjectResultBlock)block;

/*!
 Fetches the TGBObject asynchronously and executes the given callback block.
 @param keys Pointer to an NSArray that contains objects specified by the keys want to fetch.
 @param block The block to execute. The block should have the following argument signature: (TGBObject *object, NSError *error)
 */
- (void)fetchInBackgroundWithKeys:(nullable NSArray *)keys
                            block:(TGBObjectResultBlock)block;

/*!
 Fetches the TGBObject asynchronously and calls the given callback.
 @param target The target on which the selector will be called.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(TGBObject *)refreshedObject error:(NSError *)error. error will be nil on success and set if there was an error. refreshedObject will be the TGBObject with the refreshed data.
 */
- (void)fetchInBackgroundWithTarget:(id)target selector:(SEL)selector;

/*!
 Fetches the TGBObject's data asynchronously if isDataAvailable is false, then calls the callback block.
 @param block The block to execute.  The block should have the following argument signature: (TGBObject *object, NSError *error)
 */
- (void)fetchIfNeededInBackgroundWithBlock:(TGBObjectResultBlock)block;

/*!
 Fetches the TGBObject's data asynchronously if isDataAvailable is false, then calls the callback.
 @param target The target on which the selector will be called.
 @param selector The selector to call.  It should have the following signature: (void)callbackWithResult:(TGBObject *)fetchedObject error:(NSError *)error. error will be nil on success and set if there was an error.
 */
- (void)fetchIfNeededInBackgroundWithTarget:(id)target
                                   selector:(SEL)selector;

/*! @name Getting Many Objects from LeanCloud */

/*!
 Fetches all of the TGBObjects with the current data from the server
 @param objects The list of objects to fetch.
 */
+ (void)fetchAll:(NSArray *)objects;

/*!
 Fetches all of the TGBObjects with the current data from the server and sets an error if it occurs.
 @param objects The list of objects to fetch.
 @param error Pointer to an NSError that will be set  if necessary
 @return success or not
 */
+ (BOOL)fetchAll:(NSArray *)objects error:(NSError **)error;

/*!
 Fetches all of the TGBObjects with the current data from the server
 @param objects The list of objects to fetch.
 */
+ (void)fetchAllIfNeeded:(NSArray *)objects;

/*!
 Fetches all of the TGBObjects with the current data from the server and sets an error if it occurs.
 @param objects The list of objects to fetch.
 @param error Pointer to an NSError that will be set  if necessary
  @return success or not
 */
+ (BOOL)fetchAllIfNeeded:(NSArray *)objects error:(NSError **)error;

/*!
 Fetches all of the TGBObjects with the current data from the server asynchronously and calls the given block.
 @param objects The list of objects to fetch.
 @param block The block to execute. The block should have the following argument signature: (NSArray *objects, NSError *error)
 */
+ (void)fetchAllInBackground:(NSArray *)objects
                       block:(AVArrayResultBlock)block;

/*!
 Fetches all of the TGBObjects with the current data from the server asynchronously and calls the given callback.
 @param objects The list of objects to fetch.
 @param target The target on which the selector will be called.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSArray *)fetchedObjects error:(NSError *)error. error will be nil on success and set if there was an error. fetchedObjects will the array of TGBObjects that were fetched.
 */
+ (void)fetchAllInBackground:(NSArray *)objects
                      target:(id)target
                    selector:(SEL)selector;

/*!
 Fetches all of the TGBObjects with the current data from the server asynchronously and calls the given block.
 @param objects The list of objects to fetch.
 @param block The block to execute. The block should have the following argument signature: (NSArray *objects, NSError *error)
 */
+ (void)fetchAllIfNeededInBackground:(NSArray *)objects
                               block:(AVArrayResultBlock)block;

/*!
 Fetches all of the TGBObjects with the current data from the server asynchronously and calls the given callback.
 @param objects The list of objects to fetch.
 @param target The target on which the selector will be called.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSArray *)fetchedObjects error:(NSError *)error. error will be nil on success and set if there was an error. fetchedObjects will the array of TGBObjects
 that were fetched.
 */
+ (void)fetchAllIfNeededInBackground:(NSArray *)objects
                              target:(id)target
                            selector:(SEL)selector;

#pragma mark - Delete

/*! @name Removing an Object from LeanCloud */

/*!
 Deletes the TGBObject.
 @return whether the delete succeeded.
 */
- (BOOL)delete;

/*!
 Deletes the TGBObject and sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 @return whether the delete succeeded.
 */
- (BOOL)delete:(NSError **)error;

/*!
 An alias of `-[TGBObject delete:]` methods that supports Swift exception.
 @seealso `-[TGBObject delete:]`
 */
- (BOOL)deleteAndThrowsWithError:(NSError **)error;

/*!
 Deletes the TGBObject asynchronously.
 */
- (void)deleteInBackground;

/*!
 Deletes the TGBObject asynchronously and executes the given callback block.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)deleteInBackgroundWithBlock:(AVBooleanResultBlock)block;

/*!
 Deletes the TGBObject asynchronously and calls the given callback.
 @param target The object to call selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSNumber *)result error:(NSError *)error. error will be nil on success and set if there was an error. [result boolValue] will tell you whether the call succeeded or not.
 */
- (void)deleteInBackgroundWithTarget:(id)target
                            selector:(SEL)selector;

/*!
 Deletes this object from the server at some unspecified time in the future, even if LeanCloud is currently inaccessible.
 Use this when you may not have a solid network connection, and don't need to know when the delete completes.
 If there is some problem with the object such that it can't be deleted, the request will be silently discarded.

 Delete instructions made with this method will be stored locally in an on-disk cache until they can be transmitted
 to LeanCloud. They will be sent immediately if possible.  Otherwise, they will be sent the next time a network connection
 is available. Delete requests will persist even after the app is closed, in which case they will be sent the
 next time the app is opened.  If more than 10MB of saveEventually or deleteEventually commands are waiting to be sent,
 subsequent calls to saveEventually or deleteEventually will cause old requests to be silently discarded until the
 connection can be re-established, and the queued requests can go through.
 */
- (void)deleteEventually;

/*!
 deleteEventually with callback block.
 
 @param block The block to execute.
 */
- (void)deleteEventuallyWithBlock:(AVIdResultBlock)block;


/*!
 *  Deletes all objects specified in object array.
 *  @param objects object array
 *  @return whether the delete succeeded
 */
+ (BOOL)deleteAll:(NSArray *)objects;

/*!
 *  Deletes all objects specified in object array.
 *  @param objects object array
 *  @param error Pointer to an NSError that will be set if necessary.
 *  @return whether the delete succeeded.
 */
+ (BOOL)deleteAll:(NSArray *)objects error:(NSError **)error;

/**
 *  Deletes all objects specified in object array. The element of objects array is TGBObject or its subclass.
 *
 *  @param objects object array
 *  @param block   The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
+ (void)deleteAllInBackground:(NSArray *)objects
                        block:(AVBooleanResultBlock)block;

#pragma mark - extension
@property (nonatomic, readwrite) BOOL fetchWhenSave;

/*!
 Generate JSON dictionary from TGBObject or its subclass object.
 */
-(NSMutableDictionary *)dictionaryForObject;

/*!
 * Construct an TGBObject or its subclass object with dictionary.
 * @param dictionary A dictionary to construct an TGBObject. The dictionary should have className key which helps to create proper class.
 */
+ (nullable TGBObject *)objectWithDictionary:(NSDictionary *)dictionary;

/**
 *  Load object properties from JSON dictionary.
 *
 *  @param dict JSON dictionary
 */
-(void)objectFromDictionary:(NSDictionary *)dict;

@end

#pragma mark - Deprecated API

@interface TGBObject (AVDeprecated)

+ (instancetype)objectWithoutDataWithObjectId:(NSString *)objectId AV_DEPRECATED("Deprecated in AVOSCloud SDK 3.2.9. Use +[TGBObject objectWithObjectId:] instead.");

+ (instancetype)objectWithoutDataWithClassName:(NSString *)className objectId:(NSString *)objectId AV_DEPRECATED("Deprecated in AVOSCloud SDK 3.2.9. Use +[TGBObject objectWithClassName:objectId:] instead.");

- (TGBRelation *)relationforKey:(NSString *)key AV_DEPRECATED("Deprecated in AVOSCloud SDK 3.2.3. Use -[TGBObject relationForKey:] instead.");

@end

NS_ASSUME_NONNULL_END
