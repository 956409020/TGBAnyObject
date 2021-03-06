//
//  TGBPaasClient.h
//  paas
//
//  Created by Zhu Zeng on 2/25/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGBConstants.h"
#import "TGBACL.h"
#import "TGBInstallation.h"
#import "TGBKKit.h"
#import "TGBUserAgent.h"

#if AV_IOS_ONLY
#define USER_AGENT [NSString stringWithFormat:@"AVOS Cloud iOS-%@ SDK", SDK_VERSION]
#else
#define USER_AGENT [NSString stringWithFormat:@"AVOS Cloud OSX-%@ SDK", SDK_VERSION]
#endif

FOUNDATION_EXPORT NSString *const LCHeaderFieldNameId;
FOUNDATION_EXPORT NSString *const LCHeaderFieldNameKey;
FOUNDATION_EXPORT NSString *const LCHeaderFieldNameSign;
FOUNDATION_EXPORT NSString *const LCHeaderFieldNameSession;
FOUNDATION_EXPORT NSString *const LCHeaderFieldNameProduction;

@interface TGBPaasClient : NSObject

+(TGBPaasClient *)sharedInstance;

@property (nonatomic, readwrite, copy) NSString * applicationId;
@property (nonatomic, readwrite, copy) NSString * clientKey;
@property (nonatomic, readonly, copy) NSString * apiVersion;
@property (nonatomic, readwrite, copy) NSString * applicationIdField;
@property (nonatomic, readwrite, copy) NSString * applicationKeyField;
@property (nonatomic, readwrite, copy) NSString * sessionTokenField;
@property (nonatomic, readwrite, strong) TGBUsered * currentUser;
@property (nonatomic, readwrite, strong) TGBACL * defaultACL;
@property (nonatomic, readwrite) BOOL currentUserAccessForDefaultACL;

@property (nonatomic, readwrite, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, readwrite, strong) NSMutableDictionary * subclassTable;

// only for cloud code yet
@property (nonatomic, assign) BOOL productionMode;


@property (nonatomic, assign) BOOL isLastModifyEnabled;
-(void)clearLastModifyCache;

- (TGBACL *)updatedDefaultACL;

+(NSMutableDictionary *)batchMethod:(NSString *)method
                               path:(NSString *)path
                               body:(NSDictionary *)body
                         parameters:(NSDictionary *)parameters;

+(void)updateBatchMethod:(NSString *)method
                    path:(NSString *)path
                    dict:(NSMutableDictionary *)dict;

- (void)getObject:(NSString *)path
   withParameters:(NSDictionary *)parameters
            block:(AVIdResultBlock)block;

- (void)getObject:(NSString *)path
   withParameters:(NSDictionary *)parameters
           policy:(AVCachePolicy)policy
      maxCacheAge:(NSTimeInterval)maxCacheAge
            block:(AVIdResultBlock)block;

-(void)putObject:(NSString *)path
  withParameters:(NSDictionary *)parameters
    sessionToken:(NSString *)sessionToken
           block:(AVIdResultBlock)block;

-(void)postBatchObject:(NSArray *)parameterArray block:(AVArrayResultBlock)block;
-(void)postBatchObject:(NSArray *)parameterArray headerMap:(NSDictionary *)headerMap eventually:(BOOL)isEventually block:(AVArrayResultBlock)block;

-(void)postBatchSaveObject:(NSArray *)parameterArray headerMap:(NSDictionary *)headerMap eventually:(BOOL)isEventually block:(AVIdResultBlock)block;

-(void)postObject:(NSString *)path
  withParameters:(NSDictionary *)parameters
           block:(AVIdResultBlock)block;

-(void)postObject:(NSString *)path
   withParameters:(NSDictionary *)parameters
       eventually:(BOOL)isEventually
            block:(AVIdResultBlock)block ;

-(void)deleteObject:(NSString *)path
     withParameters:(NSDictionary *)parameters
              block:(AVIdResultBlock)block;

- (void)deleteObject:(NSString *)path
      withParameters:(NSDictionary *)parameters
          eventually:(BOOL)isEventually
               block:(AVIdResultBlock)block;

- (NSString *)absoluteStringFromPath:(NSString *)path parameters:(NSDictionary *)parameters;

-(BOOL)addSubclassMapEntry:(NSString *)parseClassName
               classObject:(Class)object;
-(Class)classFor:(NSString *)parseClassName;

// offline
// TODO: never called this yet!
- (void)handleAllArchivedRequests;

#pragma mark - Network Utils

/*!
 * Get signature header field value.
 */
- (NSString *)signatureHeaderFieldValue;

- (NSMutableURLRequest *)requestWithPath:(NSString *)path
                                  method:(NSString *)method
                                 headers:(NSDictionary *)headers
                              parameters:(NSDictionary *)parameters;

- (void)performRequest:(NSURLRequest *)request
               success:(void (^)(NSHTTPURLResponse *response, id responseObject))successBlock
               failure:(void (^)(NSHTTPURLResponse *response, id responseObject, NSError *error))failureBlock;

- (void)performRequest:(NSURLRequest *)request
               success:(void (^)(NSHTTPURLResponse *response, id responseObject))successBlock
               failure:(void (^)(NSHTTPURLResponse *response, id responseObject, NSError *error))failureBlock
                  wait:(BOOL)wait;

@end
