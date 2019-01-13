//
//  TGBObjectUtils.h
//  AVOSCloud
//
//  Created by Zhu Zeng on 7/4/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGBGlobal.h"
#import "TGBGeoPoint.h"
#import "TGBACL.h"
#import "TGBObject.h"

@interface TGBObjectUtils : NSObject


#pragma mark - Simple objecitive-c object from cloud side dictionary
+(NSString *)stringFromDate:(NSDate *)date;
+(NSDate *)dateFromDictionary:(NSDictionary *)dict;
+(NSDate *)dateFromString:(NSString *)string;
+(NSData *)dataFromDictionary:(NSDictionary *)dict;
+(TGBGeoPoint *)geoPointFromDictionary:(NSDictionary *)dict;
+(TGBACL *)aclFromDictionary:(NSDictionary *)dict;
+(NSObject *)objectFromDictionary:(NSDictionary *)dict;
+ (NSObject *)objectFromDictionary:(NSDictionary *)dict recursive:(BOOL)recursive;
+(NSArray *)arrayFromArray:(NSArray *)array;

#pragma mark - Update Objecitive-c object from server side dictionary
+(void)copyDictionary:(NSDictionary *)src
             toObject:(TGBObject *)target;

#pragma mark - Cloud side dictionary representation of objective-c object.
+(NSMutableDictionary *)dictionaryFromDictionary:(NSDictionary *)dic;
+(NSMutableArray *)dictionaryFromArray:(NSArray *)array;
+(NSDictionary *)dictionaryFromTGBObjectPointer:(TGBObject *)object;
+(NSDictionary *)dictionaryFromGeoPoint:(TGBGeoPoint *)point;
+(NSDictionary *)dictionaryFromDate:(NSDate *)date;
+(NSDictionary *)dictionaryFromData:(NSData *)data;
+(NSDictionary *)dictionaryFromFile:(TGBFile *)file;
+(NSDictionary *)dictionaryFromACL:(TGBACL *)acl;
+ (id)dictionaryFromObject:(id)obj;
+ (id)dictionaryFromObject:(id)obj topObject:(BOOL)topObject;
+(NSDictionary *)childDictionaryFromTGBObject:(TGBObject *)object
                                     withKey:(NSString *)key;

#pragma mark - Object snapshot, usually for local cache.

+ (id)snapshotDictionary:(id)object;
+ (id)snapshotDictionary:(id)object recursive:(BOOL)recursive;

+ (NSMutableDictionary *)objectSnapshot:(TGBObject *)object;
+ (NSMutableDictionary *)objectSnapshot:(TGBObject *)object recursive:(BOOL)recursive;

+(TGBObject *)TGBObjectFromDictionary:(NSDictionary *)dict;
+(TGBObject *)TGBObjectForClass:(NSString *)className;
+(TGBObject *)targetObjectFromRelationDictionary:(NSDictionary *)dict;

+(NSSet *)allTGBObjectProperties:(Class)objectClass;

#pragma mark - Rebuild Relation
+(void)setupRelation:(TGBObject *)parent
      withDictionary:(NSDictionary *)relationMap;


#pragma mark - batch request from operation list
+(BOOL)isUserClass:(NSString *)className;
+(BOOL)isRoleClass:(NSString *)className;
+(BOOL)isFileClass:(NSString *)className;
+(BOOL)isInstallationClass:(NSString *)className;
+(NSString *)objectPath:(NSString *)className
                   objectId:(NSString *)objectId;

#pragma mark - Array utils
+(BOOL)safeAdd:(NSDictionary *)dict
       toArray:(NSMutableArray *)array;

#pragma mark - key utils
+(BOOL)hasAnyKeys:(id)object;

+(NSString *)batchPath;
+(NSString *)batchSavePath;

@end
