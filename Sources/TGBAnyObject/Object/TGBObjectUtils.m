//
//  TGBObjectUtils.m
//  AVOSCloud
//
//  Created by Zhu Zeng on 7/4/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import <objc/runtime.h>
#import "TGBObjectUtils.h"
#import "TGBObject_Internal.h"
#import "TGBFile.h"
#import "TGBFile_Internal.h"
#import "TGBObjectUtils.h"
#import "TGBUsered_Internal.h"
#import "TGBACL_Internal.h"
#import "TGBRelation.h"
#import "TGBRole_Internal.h"
#import "TGBInstallation_Internal.h"
#import "TGBPaasClient.h"
#import "TGBGeoPoint_Internal.h"
#import "TGBRelation_Internal.h"
#import "TGBUtils.h"

@implementation TGBObjectUtils

#pragma mark - Check type

+(BOOL)isRelation:(NSString *)type
{
    return [type isEqualToString:@"Relation"];
}

/// The remote TGBObject can be a pointer object or a normal object without pointer property
/// When adding TGBObject, we have to check if it's a pointer or not.
+(BOOL)isRelationDictionary:(NSDictionary *)dict
{
    NSString * type = [dict objectForKey:@"__type"];
    if ([type isEqualToString:@"Relation"]) {
        return YES;
    }
    return NO;
}

+(BOOL)isPointerDictionary:(NSDictionary *)dict
{
    NSString * type = [dict objectForKey:@"__type"];
    if ([type isEqualToString:@"Pointer"]) {
        return YES;
    }
    return NO;
}

+(BOOL)isPointer:(NSString *)type
{
    return [type isEqualToString:@"Pointer"];
}

+(BOOL)isGeoPoint:(NSString *)type
{
    return [type isEqualToString:@"GeoPoint"];
}

+(BOOL)isACL:(NSString *)type
{
    return [type isEqualToString:ACLTag];
}

+(BOOL)isDate:(NSString *)type
{
    return [type isEqualToString:@"Date"];
}

+(BOOL)isData:(NSString *)type
{
    return [type isEqualToString:@"Bytes"];
}

+(BOOL)isFile:(NSString *)type
{
    return [type isEqualToString:@"File"];
}

+(BOOL)isFilePointer:(NSDictionary *)dict {
    return ([[dict objectForKey:classNameTag] isEqualToString:@"_File"]);
}

+(BOOL)isTGBObject:(NSDictionary *)dict
{
    // Should check for __type is Object ?
    return ([dict objectForKey:classNameTag] != nil);
}

#pragma mark - Simple objecitive-c object from server side dictionary

+(NSDateFormatter *)dateFormatter{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:AV_DATE_FORMAT];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    });
    
    return dateFormatter;
}

+(NSString *)stringFromDate:(NSDate *)date
{
    NSString *strDate = [[self.class dateFormatter] stringFromDate:date];
    return strDate;
}

+(NSDate *)dateFromString:(NSString *)string
{
    if (string == nil || [string isKindOfClass:[NSNull class]]) {
        return [NSDate date];
    }
    
    NSDate *date = [[self.class dateFormatter] dateFromString:string];

    return date;
}

+(NSDate *)dateFromDictionary:(NSDictionary *)dict
{
    return [TGBObjectUtils dateFromString:[dict valueForKey:@"iso"]];
}

+(NSData *)dataFromDictionary:(NSDictionary *)dict
{
    NSString * string = [dict valueForKey:@"base64"];
    NSData * data = [NSData AVdataFromBase64String:string];
    return data;
}

+(TGBGeoPoint *)geoPointFromDictionary:(NSDictionary *)dict
{
    TGBGeoPoint * point = [[TGBGeoPoint alloc]init];
    point.latitude = [[dict objectForKey:@"latitude"] doubleValue];
    point.longitude = [[dict objectForKey:@"longitude"] doubleValue];
    return point;
}

+(TGBACL *)aclFromDictionary:(NSDictionary *)dict
{
    TGBACL * acl = [TGBACL ACL];
    acl.permissionsById = [dict mutableCopy];
    return acl;
}

+(NSArray *)arrayFromArray:(NSArray *)array
{
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:array.count];
    for (id obj in [array copy]) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [newArray addObject:[TGBObjectUtils objectFromDictionary:obj]];
        } else if ([obj isKindOfClass:[NSArray class]]) {
            NSArray * sub = [TGBObjectUtils arrayFromArray:obj];
            [newArray addObject:sub];
        } else {
            [newArray addObject:obj];
        }
    }
    return newArray;
}

+(NSObject *)objectFromDictionary:(NSDictionary *)dict
{
    NSString * type = [dict valueForKey:@"__type"];
    if ([TGBObjectUtils isRelation:type])
    {
        return [TGBObjectUtils targetObjectFromRelationDictionary:dict];
    }
    else if ([TGBObjectUtils isPointer:type] ||
             [TGBObjectUtils isTGBObject:dict] )
    {
        /*
         the backend stores TGBFile as TGBObject, but in sdk TGBFile is not subclass of TGBObject, have to process the situation here.
         */
        if ([TGBObjectUtils isFilePointer:dict]) {
            return [[TGBFile alloc] initWithRawJSONData:[dict mutableCopy]];
        }
        return [TGBObjectUtils TGBObjectFromDictionary:dict];
    }
    else if ([TGBObjectUtils isFile:type]) {
        return [[TGBFile alloc] initWithRawJSONData:[dict mutableCopy]];
    }
    else if ([TGBObjectUtils isGeoPoint:type])
    {
        TGBGeoPoint * point = [TGBObjectUtils geoPointFromDictionary:dict];
        return point;
    }
    else if ([TGBObjectUtils isDate:type])
    {
        NSDate * date = [TGBObjectUtils dateFromDictionary:dict];
        return date;
    }
    else if ([TGBObjectUtils isData:type])
    {
        NSData * data = [TGBObjectUtils dataFromDictionary:dict];
        return data;
    }
    return dict;
}

+ (NSObject *)objectFromDictionary:(NSDictionary *)dict recursive:(BOOL)recursive {
    if (recursive) {
        NSMutableDictionary *mutableDict = [dict mutableCopy];

        for (NSString *key in [dict allKeys]) {
            id object = dict[key];

            if ([object isKindOfClass:[NSDictionary class]]) {
                object = [self objectFromDictionary:object recursive:YES];
                mutableDict[key] = object;
            }
        }

        return [self objectFromDictionary:mutableDict];
    } else {
        return [self objectFromDictionary:dict];
    }
}

+(void)copyDictionary:(NSDictionary *)dict
             toTarget:(TGBObject *)target
                  key:(NSString *)key
{
    NSString * type = [dict valueForKey:@"__type"];
    if ([TGBObjectUtils isRelation:type])
    {
        // 解析 {"__type":"Relation","className":"_User"}，添加第一个来判断类型
        TGBObject * object = [TGBObjectUtils targetObjectFromRelationDictionary:dict];
        [target addRelation:object forKey:key submit:NO];
    }
    else if ([TGBObjectUtils isPointer:type])
    {
        [target setObject:[TGBObjectUtils objectFromDictionary:dict] forKey:key submit:NO];
    }
    else if ([TGBObjectUtils isTGBObject:dict]) {
        [target setObject:[TGBObjectUtils objectFromDictionary:dict] forKey:key submit:NO];
    }
    else if ([TGBObjectUtils isFile:type]) {
        TGBFile *file = [[TGBFile alloc] initWithRawJSONData:[dict mutableCopy]];
        [target setObject:file forKey:key submit:false];
    }
    else if ([TGBObjectUtils isGeoPoint:type])
    {
        TGBGeoPoint * point = [TGBGeoPoint geoPointFromDictionary:dict];
        [target setObject:point forKey:key submit:NO];
    }
    else if ([TGBObjectUtils isACL:type] ||
             [TGBObjectUtils isACL:key])
    {
        [target setObject:[TGBObjectUtils aclFromDictionary:dict] forKey:ACLTag submit:NO];
    }
    else if ([TGBObjectUtils isDate:type])
    {
        NSDate * date = [TGBObjectUtils dateFromDictionary:dict];
        [target setObject:date forKey:key submit:NO];
    }
    else if ([TGBObjectUtils isData:type])
    {
        NSData * data = [TGBObjectUtils dataFromDictionary:dict];
        [target setObject:data forKey:key submit:NO];
    }
    else
    {
        id object = [self objectFromDictionary:dict recursive:YES];
        [target setObject:object forKey:key submit:NO];
    }
}


/// Add object to TGBObject container.
+(void)addObject:(NSObject *)object
              to:(NSObject *)parent
             key:(NSString *)key
      isRelation:(BOOL)isRelation
{
    if ([key hasPrefix:@"_"]) {
        // NSLog(@"Ingore key %@", key);
        return;
    }        
    
    if (![parent isKindOfClass:[TGBObject class]]) {
        return;
    }
    TGBObject * avParent = (TGBObject *)parent;
    if ([object isKindOfClass:[TGBObject class]]) {
        if (isRelation) {
            [avParent addRelation:(TGBObject *)object forKey:key submit:NO];
        } else {
            [avParent setObject:object forKey:key submit:NO];
        }
    } else if ([object isKindOfClass:[NSArray class]]) {
        for(TGBObject * item in [object copy]) {
            [avParent addObject:item forKey:key];
        }
    } else {
        [avParent setObject:object forKey:key submit:NO];
    }
}

+(NSDate *)dateFromValue:(id)value {
    NSDate * date = nil;
    if ([value isKindOfClass:[NSDictionary class]]) {
        date = [TGBObjectUtils dateFromDictionary:value];
    } else if ([value isKindOfClass:[NSString class]]) {
        date = [TGBObjectUtils dateFromString:value];
    }
    return date;
}

+(void)updateObjectProperty:(TGBObject *)target
                        key:(NSString *)key
                      value:(NSObject *)value
{
    if ([key isEqualToString:@"createdAt"] ) {
        target.createdAt = [TGBObjectUtils dateFromValue:value];
    } else if ([key isEqualToString:@"updatedAt"]) {
        target.updatedAt = [TGBObjectUtils dateFromValue:value];
    } else if ([key isEqualToString:ACLTag]) {
        TGBACL * acl = [TGBObjectUtils aclFromDictionary:(NSDictionary *)value];
        [target setObject:acl forKey:key submit:NO];
    } else {
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary * valueDict = (NSDictionary *)value;
            [TGBObjectUtils copyDictionary:valueDict toTarget:target key:key];
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSArray * array = [TGBObjectUtils arrayFromArray:(NSArray *)value];
            [target setObject:array forKey:key submit:NO];
        } else if ([value isEqual:[NSNull null]]) {
            [target removeObjectForKey:key];
        } else {
            [target setObject:value forKey:key submit:NO];
        }
    }
}

+(void)updateSubObjects:(TGBObject *)target
                    key:(NSString *)key
                  value:(NSObject *)obj
{
    // additional properties, use setObject
    if ([obj isKindOfClass:[NSDictionary class]])
    {
        [TGBObjectUtils copyDictionary:(NSDictionary *)obj toTarget:target key:key];
    }
    else if ([obj isKindOfClass:[NSArray class]])
    {
        NSArray * array = [TGBObjectUtils arrayFromArray:(NSArray *)obj];
        [target setObject:array forKey:key submit:NO];
    }
    else
    {
        [target setObject:obj forKey:key submit:NO];
    }
}


#pragma mark - Update Objecitive-c object from server side dictionary
+(void)copyDictionary:(NSDictionary *)src
             toObject:(TGBObject *)target
{
    [src enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([target respondsToSelector:NSSelectorFromString(key)]) {
            [TGBObjectUtils updateObjectProperty:target key:key value:obj];
        } else {
            [TGBObjectUtils updateSubObjects:target key:key value:obj];
        }
    }];
}

#pragma mark - Server side dictionary representation of objective-c object.
+ (NSMutableDictionary *)dictionaryFromDictionary:(NSDictionary *)dic {
    return [self dictionaryFromDictionary:dic topObject:NO];
}

/// topObject is for cloud rpc
+ (NSMutableDictionary *)dictionaryFromDictionary:(NSDictionary *)dic topObject:(BOOL)topObject{
    NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithCapacity:dic.count];
    for (NSString *key in [dic allKeys]) {
        id obj = [dic objectForKey:key];
        [newDic setObject:[TGBObjectUtils dictionaryFromObject:obj topObject:topObject] forKey:key];
    }
    return newDic;
}

+ (NSMutableArray *)dictionaryFromArray:(NSArray *)array {
    return [self dictionaryFromArray:array topObject:NO];
}

+ (NSMutableArray *)dictionaryFromArray:(NSArray *)array topObject:(BOOL)topObject
{
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:array.count];
    for (id obj in [array copy]) {
        [newArray addObject:[TGBObjectUtils dictionaryFromObject:obj topObject:topObject]];
    }
    return newArray;
}

+(NSDictionary *)dictionaryFromTGBObjectPointer:(TGBObject *)object
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"Pointer" forKey:@"__type"];
    [dict setObject:[object internalClassName] forKey:classNameTag];
    if ([object hasValidObjectId])
    {
        [dict setObject:object.objectId forKey:@"objectId"];
    }
    return dict;
}

/*
{
    "cid" : "67c35bc8-4183-4db0-8f5a-0ee2b0baa4d4",
    "className" : "ddd",
    "key" : "myddd"
}
*/
+(NSDictionary *)childDictionaryFromTGBObject:(TGBObject *)object
                                     withKey:(NSString *)key
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[object internalClassName] forKey:classNameTag];
    NSString *cid = [object objectId] != nil ? [object objectId] : [object uuid];
    [dict setObject:cid forKey:@"cid"];
    [dict setObject:key forKey:@"key"];
    return dict;
}

+ (NSSet *)allTGBObjectProperties:(Class)objectClass {
    NSMutableSet *properties = [NSMutableSet set];

    [self allTGBObjectProperties:objectClass properties:properties];

    return [properties copy];
}

+(void)allTGBObjectProperties:(Class)objectClass
                  properties:(NSMutableSet *)properties {
    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList(objectClass, &numberOfProperties);
    for (NSUInteger i = 0; i < numberOfProperties; i++)
    {
        objc_property_t property = propertyArray[i];

        char *readonly = property_copyAttributeValue(property, "R");

        if (readonly) {
            free(readonly);
            continue;
        }

        NSString *key = [[NSString alloc] initWithUTF8String:property_getName(property)];
        [properties addObject:key];
    }

    if ([objectClass isSubclassOfClass:[TGBObject class]] && objectClass != [TGBObject class])
    {
        [TGBObjectUtils allTGBObjectProperties:[objectClass superclass] properties:properties];
    }
    free(propertyArray);
}

// generate object json dictionary. For TGBObject, we generate the full
// json dictionary instead of pointer only. This function is different
// from dictionaryFromObject which generates pointer json only for TGBObject.
+ (id)snapshotDictionary:(id)object {
    return [self snapshotDictionary:object recursive:YES];
}

+ (id)snapshotDictionary:(id)object recursive:(BOOL)recursive {
    if (recursive && [object isKindOfClass:[TGBObject class]]) {
        return [TGBObjectUtils objectSnapshot:object recursive:recursive];
    } else {
        return [TGBObjectUtils dictionaryFromObject:object];
    }
}

+ (NSMutableDictionary *)objectSnapshot:(TGBObject *)object {
    return [self objectSnapshot:object recursive:YES];
}

+ (NSMutableDictionary *)objectSnapshot:(TGBObject *)object recursive:(BOOL)recursive {
    __block NSDictionary *localDataCopy = nil;
    [object internalSyncLock:^{
        localDataCopy = object.localData.copy;
    }];
    NSArray * objects = @[localDataCopy, object.estimatedData];
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    [result setObject:@"Object" forKey:kAVTypeTag];

    for (NSDictionary *object in objects) {
        NSDictionary *dictionary = [object copy];
        NSArray *keys = [dictionary allKeys];

        for(NSString * key in keys) {
            id valueObject = [self snapshotDictionary:dictionary[key] recursive:recursive];
            if (valueObject != nil) {
                [result setObject:valueObject forKey:key];
            }
        }
    }

    NSArray * keys = [object.relationData allKeys];

    for(NSString * key in keys) {
        NSString * childClassName = [object childClassNameForRelation:key];
        id valueObject = [self dictionaryForRelation:childClassName];
        if (valueObject != nil) {
            [result setObject:valueObject forKey:key];
        }
    }
    
    NSSet *ignoreKeys = [NSSet setWithObjects:
                         @"localData",
                         @"relationData",
                         @"estimatedData",
                         @"isPointer",
                         @"running",
                         @"operationQueue",
                         @"requestManager",
                         @"inSetter",
                         @"uuid",
                         @"submit",
                         @"hasDataForInitial",
                         @"hasDataForCloud",
                         @"fetchWhenSave",
                         @"isNew", // from TGBUsered
                         nil];

    NSMutableSet * properties = [NSMutableSet set];
    [self allTGBObjectProperties:[object class] properties:properties];

    for (NSString * key in properties) {
        if ([ignoreKeys containsObject:key]) {
            continue;
        }
        id valueObjet = [self snapshotDictionary:[object valueForKey:key] recursive:recursive];
        if (valueObjet != nil) {
            [result setObject:valueObjet forKey:key];
        }
    }

    return result;
}

+(TGBObject *)TGBObjectForClass:(NSString *)className {
    if (className == nil) {
        return nil;
    }
    TGBObject *object = nil;
    Class classObject = [[TGBPaasClient sharedInstance] classFor:className];
    if (classObject != nil && [classObject isSubclassOfClass:[TGBObject class]]) {
        if ([classObject respondsToSelector:@selector(object)]) {
            object = [classObject performSelector:@selector(object)];
        }
    } else {
        if ([TGBObjectUtils isUserClass:className]) {
            object = [TGBUsered user];
        } else if ([TGBObjectUtils isInstallationClass:className]) {
            object = [TGBInstallation installation];
        } else if ([TGBObjectUtils isRoleClass:className]) {
            // TODO
            object = [TGBRole role];
        } else {
            object = [TGBObject objectWithClassName:className];
        }
    }
    return object;
}

+(TGBObject *)TGBObjectFromDictionary:(NSDictionary *)src
                          className:(NSString *)className {
    if (src == nil || className == nil || src.count == 0) {
        return nil;
    }
    TGBObject *object = [TGBObjectUtils TGBObjectForClass:className];
    [TGBObjectUtils copyDictionary:src toObject:object];
    if ([TGBObjectUtils isPointerDictionary:src]) {
        object.isPointer = YES;
    }
    return object;
}

+(TGBObject *)TGBObjectFromDictionary:(NSDictionary *)dict {
    NSString * className = [dict objectForKey:classNameTag];
    return [TGBObjectUtils TGBObjectFromDictionary:dict className:className];
}

// create relation target object instead of relation object.
+(TGBObject *)targetObjectFromRelationDictionary:(NSDictionary *)dict
{
    TGBObject * object = [TGBObjectUtils TGBObjectForClass:[dict valueForKey:classNameTag]];
    return object;
}

+(NSDictionary *)dictionaryFromGeoPoint:(TGBGeoPoint *)point
{
    return [TGBGeoPoint dictionaryFromGeoPoint:point];
}

+(NSDictionary *)dictionaryFromDate:(NSDate *)date
{
    NSString *strDate = [TGBObjectUtils stringFromDate:date];
    return @{@"__type": @"Date", @"iso":strDate};
}

+(NSDictionary *)dictionaryFromData:(NSData *)data
{
    NSString *base64 = [data AVbase64EncodedString];
    return @{@"__type": @"Bytes", @"base64":base64};
}

+(NSDictionary *)dictionaryFromFile:(TGBFile *)file
{
    return [file rawJSONDataCopy];
}

+(NSDictionary *)dictionaryFromACL:(TGBACL *)acl {
    return [acl.permissionsById copy];
}

+(NSDictionary *)dictionaryFromRelation:(TGBRelation *)relation {
    if (relation.targetClass) {
        return [TGBObjectUtils dictionaryForRelation:relation.targetClass];
    }
    return nil;
}

+(NSDictionary *)dictionaryForRelation:(NSString *)className {
    return  @{@"__type": @"Relation", @"className":className};
}

// Generate server side dictionary representation of input NSObject
+ (id)dictionaryFromObject:(id)obj {
    return [self dictionaryFromObject:obj topObject:NO];
}

/// topObject means get the top level TGBObject with Pointer child if any TGBObject. Used for cloud rpc.
+ (id)dictionaryFromObject:(id)obj topObject:(BOOL)topObject
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return [TGBObjectUtils dictionaryFromDictionary:obj topObject:topObject];
    } else if ([obj isKindOfClass:[NSArray class]]) {
        return [TGBObjectUtils dictionaryFromArray:obj topObject:topObject];
    } else if ([obj isKindOfClass:[TGBObject class]]) {
        if (topObject) {
            return [TGBObjectUtils objectSnapshot:obj recursive:NO];
        } else {
            return [TGBObjectUtils dictionaryFromTGBObjectPointer:obj];
        }
    } else if ([obj isKindOfClass:[TGBGeoPoint class]]) {
        return [TGBObjectUtils dictionaryFromGeoPoint:obj];
    } else if ([obj isKindOfClass:[NSDate class]]) {
        return [TGBObjectUtils dictionaryFromDate:obj];
    } else if ([obj isKindOfClass:[NSData class]]) {
        return [TGBObjectUtils dictionaryFromData:obj];
    } else if ([obj isKindOfClass:[TGBFile class]]) {
        return [TGBObjectUtils dictionaryFromFile:obj];
    } else if ([obj isKindOfClass:[TGBACL class]]) {
        return [TGBObjectUtils dictionaryFromACL:obj];
    } else if ([obj isKindOfClass:[TGBRelation class]]) {
        return [TGBObjectUtils dictionaryFromRelation:obj];
    }
    // string or other?
    return obj;
}

+(void)setupRelation:(TGBObject *)parent
      withDictionary:(NSDictionary *)relationMap
{
    for(NSString * key in [relationMap allKeys]) {
        NSArray * array = [relationMap objectForKey:key];
        for(NSDictionary * item in [array copy]) {
            NSObject * object = [TGBObjectUtils objectFromDictionary:item];
            if ([object isKindOfClass:[TGBObject class]]) {
                [parent addRelation:(TGBObject *)object forKey:key submit:NO];
            }
        }
    }
}

#pragma mark - batch request from operation list
+(BOOL)isUserClass:(NSString *)className
{
    return [className isEqualToString:[TGBUsered userTag]];
}

+(BOOL)isRoleClass:(NSString *)className
{
    return [className isEqualToString:[TGBRole className]];
}

+(BOOL)isFileClass:(NSString *)className
{
    return [className isEqualToString:[TGBFile className]];
}

+(BOOL)isInstallationClass:(NSString *)className
{
    return [className isEqualToString:[TGBInstallation className]];
}

+(NSString *)classEndPoint:(NSString *)className
                   objectId:(NSString *)objectId
{
    if (objectId == nil)
    {
        return [NSString stringWithFormat:@"classes/%@", className];
    }
    return [NSString stringWithFormat:@"classes/%@/%@", className, objectId];
}

+(NSString *)userObjectPath:(NSString *)objectId
{
    if (objectId == nil)
    {
        return [TGBUsered endPoint];
    }
    return [NSString stringWithFormat:@"%@/%@", [TGBUsered endPoint], objectId];
}


+(NSString *)roleObjectPath:(NSString *)objectId
{
    if (objectId == nil)
    {
        return [TGBRole endPoint];
    }
    return [NSString stringWithFormat:@"%@/%@", [TGBRole endPoint], objectId];
}

+(NSString *)installationObjectPath:(NSString *)objectId
{
    if (objectId == nil)
    {
        return [TGBInstallation endPoint];
    }
    return [NSString stringWithFormat:@"%@/%@", [TGBInstallation endPoint], objectId];
}

+(NSString *)objectPath:(NSString *)className
                   objectId:(NSString *)objectId
{
    //FIXME: 而且等于nil也没问题 只不过不应该再发请求
    //NSAssert(objectClass!=nil, @"className should not be nil!");
    if ([TGBObjectUtils isUserClass:className])
    {
        return [TGBObjectUtils userObjectPath:objectId];
    }
    else if ([TGBObjectUtils isRoleClass:className])
    {
        return [TGBObjectUtils roleObjectPath:objectId];
    }
    else if ([TGBObjectUtils isInstallationClass:className])
    {
        return [TGBObjectUtils installationObjectPath:objectId];
    }
    return [TGBObjectUtils classEndPoint:className objectId:objectId];
}

+(NSString *)batchPath {
    return @"batch";
}

+(NSString *)batchSavePath
{
    return @"batch/save";
}

+(BOOL)safeAdd:(NSDictionary *)dict
       toArray:(NSMutableArray *)array
{
    if (dict != nil) {
        [array addObject:dict];
        return YES;
    }
    return NO;
}

+(BOOL)hasAnyKeys:(id)object {
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary * dict = (NSDictionary *)object;
        return ([dict count] > 0);
    }
    return NO;
}

@end
