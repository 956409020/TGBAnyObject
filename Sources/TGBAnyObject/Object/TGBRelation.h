//
//  TGBRelation.h
//  LeanCloud
//
//

#import <Foundation/Foundation.h>
#import "TGBObject.h"
#import "TGBQuery.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 A class that is used to access all of the children of a many-to-many relationship.  Each instance
 of TGBRelation is associated with a particular parent object and key.
 */
@interface TGBRelation : NSObject {
    
}

@property (nonatomic, copy, nullable) NSString *targetClass;


#pragma mark Accessing objects
/*!
 @return A TGBQuery that can be used to get objects in this relation.
 */
- (TGBQuery *)query;


#pragma mark Modifying relations

/*!
 Adds a relation to the passed in object.
 @param object TGBObject to add relation to.
 */
- (void)addObject:(TGBObject *)object;

/*!
 Removes a relation to the passed in object.
 @param object TGBObject to add relation to.
 */
- (void)removeObject:(TGBObject *)object;

/*!
 @return A TGBQuery that can be used to get parent objects in this relation.
 */

/**
 *  A TGBQuery that can be used to get parent objects in this relation.
 *
 *  @param parentClassName parent Class Name
 *  @param relationKey     relation Key
 *  @param child           child object
 *
 *  @return the Query
 */
+(TGBQuery *)reverseQuery:(NSString *)parentClassName
             relationKey:(NSString *)relationKey
             childObject:(TGBObject *)child;

@end

NS_ASSUME_NONNULL_END
