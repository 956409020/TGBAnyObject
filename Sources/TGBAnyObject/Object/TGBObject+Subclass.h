//
//  TGBObject+Subclass.h
//  paas
//
//  Created by Summer on 13-4-2.
//  Copyright (c) 2013年 AVOS. All rights reserved.
//

#import "TGBObject.h"

@class TGBQuery;

NS_ASSUME_NONNULL_BEGIN

/*!
 <h3>Subclassing Notes</h3>
 
 Developers can subclass TGBObject for a more native object-oriented class structure. Strongly-typed subclasses of TGBObject must conform to the TGBSubclassing protocol and must call registerSubclass to be returned by TGBQuery and other TGBObject factories. All methods in TGBSubclassing except for [TGBSubclassing parseClassName] are already implemented in the TGBObject(Subclass) category. Inculding TGBObject+Subclass.h in your implementation file provides these implementations automatically.
 
 Subclasses support simpler initializers, query syntax, and dynamic synthesizers.
 
 */

@interface TGBObject(Subclass)

///*! @name Methods for Subclasses */
//
///*!
// Designated initializer for subclasses.
// This method can only be called on subclasses which conform to TGBSubclassing.
// This method should not be overridden.
// */
//- (id)init;

/*!
 Creates an instance of the registered subclass with this class's parseClassName.
 This helps a subclass ensure that it can be subclassed itself. For example, [TGBUsered object] will
 return a MyUser object if MyUser is a registered subclass of TGBUsered. For this reason, [MyClass object] is
 preferred to [[MyClass alloc] init].
 This method can only be called on subclasses which conform to TGBSubclassing.
 A default implementation is provided by TGBObject which should always be sufficient.
 */
+ (instancetype)object;

/*!
 Registers an Objective-C class for LeanCloud to use for representing a given LeanCloud class.
 Once this is called on a TGBObject subclass, any TGBObject LeanCloud creates with a class
 name matching [self parseClassName] will be an instance of subclass.
 This method can only be called on subclasses which conform to TGBSubclassing.
 A default implementation is provided by TGBObject which should always be sufficient.
 */
+ (void)registerSubclass;

/*!
 Returns a query for objects of type +parseClassName.
 This method can only be called on subclasses which conform to TGBSubclassing.
 A default implementation is provided by TGBObject which should always be sufficient.
 */
+ (TGBQuery *)query;

@end

NS_ASSUME_NONNULL_END
