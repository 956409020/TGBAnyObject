//
//  TGBSubclassing.h
//  paas
//
//  Created by Summer on 13-4-2.
//  Copyright (c) 2013年 AVOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TGBQuery;

NS_ASSUME_NONNULL_BEGIN

/*!
 If a subclass of TGBObject conforms to TGBSubclassing and calls registerSubclass, LeanCloud will be able to use that class as the native class for a LeanCloud object.

 Classes conforming to this protocol should subclass TGBObject and include TGBObject+Subclass.h in their implementation file. This ensures the methods in the Subclass category of TGBObject are exposed in its subclasses only.
 */
@protocol TGBSubclassing

@optional

/*! The name of the class as seen in the REST API. */
+ (NSString *)parseClassName;

/*!
 Creates a reference to an existing TGBObject for use in creating associations between TGBObjects.  Calling isDataAvailable on this
 object will return NO until fetchIfNeeded or refresh has been called.  No network request will be made.
 A default implementation is provided by TGBObject which should always be sufficient.
 @param objectId The object id for the referenced object.
 @return A TGBObject without data.
 */
+ (instancetype)objectWithoutDataWithObjectId:(NSString *)objectId;

/*!
 Create a query which returns objects of this type.
 A default implementation is provided by TGBObject which should always be sufficient.
 */
+ (TGBQuery *)query;

/*!
 Lets LeanCloud know this class should be used to instantiate all objects with class type parseClassName.
 This method must be called before [AVOSCloud setApplicationId:clientKey:]
 */
+ (void)registerSubclass;

@end

NS_ASSUME_NONNULL_END
