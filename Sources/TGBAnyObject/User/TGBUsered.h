// TGBUsered.h
// Copyright 2013 AVOS, Inc. All rights reserved.

#import <Foundation/Foundation.h>
#import "TGBConstants.h"
#import "TGBObject.h"
#import "TGBSubclassing.h"
#import "TGBDynamicObject.h"

@class TGBRole;
@class TGBQuery;
@class TGBUseredShortMessageRequestOptions;

NS_ASSUME_NONNULL_BEGIN

typedef NSString * const LeanCloudSocialPlatform NS_TYPED_EXTENSIBLE_ENUM;
extern LeanCloudSocialPlatform LeanCloudSocialPlatformWeiBo;
extern LeanCloudSocialPlatform LeanCloudSocialPlatformQQ;
extern LeanCloudSocialPlatform LeanCloudSocialPlatformWeiXin;

@interface TGBUseredAuthDataLoginOption : NSObject

/**
 Third platform.
 */
@property (nonatomic, strong, nullable) LeanCloudSocialPlatform platform;

/**
 UnionId from the third platform.
 */
@property (nonatomic, strong, nullable) NSString *unionId;

/**
 Set true to generate a platform-unionId signature.
 if a TGBUsered instance has a platform-unionId signature, then the platform and the unionId will be the highest priority in auth data matching.
 @Note must cooperate with platform & unionId.
 */
@property (nonatomic, assign) BOOL isMainAccount;

/**
 Set true to check whether already exists a TGBUsered instance with the auth data.
 if not exists, return an error.
 */
@property (nonatomic, assign) BOOL failOnNotExist;

@end

/*!
A LeanCloud Framework User Object that is a local representation of a user persisted to the LeanCloud. This class
 is a subclass of a TGBObject, and retains the same functionality of a TGBObject, but also extends it with various
 user specific methods, like authentication, signing up, and validation uniqueness.
 
 Many APIs responsible for linking a TGBUsered with Facebook or Twitter have been deprecated in favor of dedicated
 utilities for each social network. See AVFacebookUtils and AVTwitterUtils for more information.
 */


@interface TGBUsered : TGBObject<TGBSubclassing>

/** @name Accessing the Current User */

/*!
 Gets the currently logged in user from disk and returns an instance of it.
 @return a TGBUsered that is the currently logged in user. If there is none, returns nil.
 */
+ (instancetype _Nullable)currentUser;

/*!
 * change the current login user manually.
 *  @param newUser 新的 TGBUsered 实例
 *  @param save 是否需要把 newUser 保存到本地缓存。如果 newUser==nil && save==YES，则会清除本地缓存
 * Note: 请注意不要随意调用这个函数！
 */
+ (void)changeCurrentUser:(TGBUsered * _Nullable)newUser save:(BOOL)save;

/// The session token for the TGBUsered. This is set by the server upon successful authentication.
@property (nonatomic, copy, nullable) NSString *sessionToken;

/// Whether the TGBUsered was just created from a request. This is only set after a Facebook or Twitter login.
@property (nonatomic, assign, readonly) BOOL isNew;

/*!
 Whether the user is an authenticated object with the given sessionToken.
 */
- (void)isAuthenticatedWithSessionToken:(NSString *)sessionToken callback:(AVBooleanResultBlock)callback;

/** @name Creating a New User */

/*!
 Creates a new TGBUsered object.
 @return a new TGBUsered object.
 */
+ (instancetype)user;

/*!
 Enables automatic creation of anonymous users.  After calling this method, [TGBUsered currentUser] will always have a value.
 The user will only be created on the server once the user has been saved, or once an object with a relation to that user or
 an ACL that refers to the user has been saved.
 
 Note: saveEventually will not work if an item being saved has a relation to an automatic user that has never been saved.
 */
+ (void)enableAutomaticUser;

/// The username for the TGBUsered.
@property (nonatomic, copy, nullable) NSString *username;

/** 
 The password for the TGBUsered. This will not be filled in from the server with
 the password. It is only meant to be set.
 */
@property (nonatomic, copy, nullable) NSString *password;

/**
 *  Email of the user. If enable "Enable Email Verification" option in the console, when register a user, will send a verification email to the user. Otherwise, only save the email to the server.
 */
@property (nonatomic, copy, nullable) NSString *email;

/**
 *  Mobile phone number of the user. Can be set when registering. If enable the "Enable Mobile Phone Number Verification" option in the console, when register a user, will send an sms message to the phone. Otherwise, only save the mobile phone number to the server.
 */
@property (nonatomic, copy, nullable) NSString *mobilePhoneNumber;

/**
 *  Mobile phone number verification flag. Read-only. if calling verifyMobilePhone:withBlock: succeeds, the server will set this value YES.
 */
@property (nonatomic, assign, readonly) BOOL mobilePhoneVerified;

/**
 *  请求重发验证邮件
 *  如果用户邮箱没有得到验证或者用户修改了邮箱, 通过本方法重新发送验证邮件.
 *  
 *  @warning 为防止滥用,同一个邮件地址，1分钟内只能发1次!
 *
 *  @param email 邮件地址
 *  @param block 回调结果
 */
+(void)requestEmailVerify:(NSString*)email withBlock:(AVBooleanResultBlock)block;

/*!
 *  请求手机号码验证
 *  发送短信到指定的手机上，内容有6位数字验证码。验证码10分钟内有效。
 *  
 *  @warning 对同一个手机号码，每天有 5 条数量的限制，并且发送间隔需要控制在一分钟。
 *
 *  @param phoneNumber 11位电话号码
 *  @param block 回调结果
 */
+(void)requestMobilePhoneVerify:(NSString *)phoneNumber withBlock:(AVBooleanResultBlock)block;

/**
 Request a verification code for a phone number.

 @param phoneNumber The phone number that will be verified later.
 @param options     The short message request options.
 @param callback    The callback of request.
 */
+ (void)requestVerificationCodeForPhoneNumber:(NSString *)phoneNumber
                                      options:(nullable TGBUseredShortMessageRequestOptions *)options
                                     callback:(AVBooleanResultBlock)callback;

/*!
 *  验证手机验证码
 *  发送验证码给服务器进行验证。
 *  @param code 6位手机验证码
 *  @param block 回调结果
 */
+(void)verifyMobilePhone:(NSString *)code withBlock:(AVBooleanResultBlock)block;

/*!
 Get roles which current user belongs to.

 @param error The error of request, or nil if request did succeed.

 @return An array of roles, or nil if some error occured.
 */
- (nullable NSArray<TGBRole *> *)getRoles:(NSError **)error;

/*!
 An alias of `-[TGBUsered getRolesAndThrowsWithError:]` methods that supports Swift exception.
 @seealso `-[TGBUsered getRolesAndThrowsWithError:]`
 */
- (nullable NSArray<TGBRole *> *)getRolesAndThrowsWithError:(NSError **)error;

/*!
 Asynchronously get roles which current user belongs to.

 @param block The callback for request.
 */
- (void)getRolesInBackgroundWithBlock:(void (^)(NSArray<TGBRole *> * _Nullable objects, NSError * _Nullable error))block;

/*!
 Signs up the user. Make sure that password and username are set. This will also enforce that the username isn't already taken.
 @param error Error object to set on error. 
 @return whether the sign up was successful.
 */
- (BOOL)signUp:(NSError **)error;

/*!
 An alias of `-[TGBUsered signUp:]` methods that supports Swift exception.
 @seealso `-[TGBUsered signUp:]`
 */
- (BOOL)signUpAndThrowsWithError:(NSError **)error;

/*!
 Signs up the user asynchronously. Make sure that password and username are set. This will also enforce that the username isn't already taken.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error) 
 */
- (void)signUpInBackgroundWithBlock:(AVBooleanResultBlock)block;

/*!
 用旧密码来更新密码。在 3.1.6 之后，更新密码成功之后不再需要强制用户重新登录，仍然保持登录状态。
 @param oldPassword 旧密码
 @param newPassword 新密码
 @param block 完成时的回调，有以下签名 (id object, NSError *error)
 @warning 此用户必须登录且同时提供了新旧密码，否则不能更新成功。
 */
- (void)updatePassword:(NSString *)oldPassword newPassword:(NSString *)newPassword block:(AVIdResultBlock)block;

/*!
 Refresh user session token asynchronously.

 @param block The callback of request.
 */
- (void)refreshSessionTokenWithBlock:(AVBooleanResultBlock)block;

/*!
 Makes a request to login a user with specified credentials. Returns an
 instance of the successfully logged in TGBUsered. This will also cache the user 
 locally so that calls to userFromCurrentUser will use the latest logged in user.
 @param username The username of the user.
 @param password The password of the user.
 @param error The error object to set on error.
 @return an instance of the TGBUsered on success. If login failed for either wrong password or wrong username, returns nil.
 */
+ (nullable instancetype)logInWithUsername:(NSString *)username
                                  password:(NSString *)password
                                     error:(NSError **)error;

/*!
 Makes an asynchronous request to log in a user with specified credentials.
 Returns an instance of the successfully logged in TGBUsered. This will also cache 
 the user locally so that calls to userFromCurrentUser will use the latest logged in user. 
 @param username The username of the user.
 @param password The password of the user.
 @param block The block to execute. The block should have the following argument signature: (TGBUsered *user, NSError *error) 
 */
+ (void)logInWithUsernameInBackground:(NSString *)username
                             password:(NSString *)password
                                block:(TGBUseredResultBlock)block;

//phoneNumber + password
/*!
 *  使用手机号码和密码登录
 *  @param phoneNumber 11位电话号码
 *  @param password 密码
 *  @param error 发生错误通过此参数返回
 */
+ (nullable instancetype)logInWithMobilePhoneNumber:(NSString *)phoneNumber
                                           password:(NSString *)password
                                              error:(NSError **)error;
/*!
 *  使用手机号码和密码登录
 *  @param phoneNumber 11位电话号码
 *  @param password 密码
 *  @param block 回调结果
 */
+ (void)logInWithMobilePhoneNumberInBackground:(NSString *)phoneNumber
                                      password:(NSString *)password
                                         block:(TGBUseredResultBlock)block;
//phoneNumber + smsCode

/*!
 *  请求登录码验证
 *  发送短信到指定的手机上，内容有6位数字验证码。验证码10分钟内有效。
 *  @param phoneNumber 11位电话号码
 *  @param block 回调结果
 */
+(void)requestLoginSmsCode:(NSString *)phoneNumber withBlock:(AVBooleanResultBlock)block;

/**
 Request a login code for a phone number.

 @param phoneNumber The phone number of an user who will login later.
 @param options     The short message request options.
 @param callback    The callback of request.
 */
+ (void)requestLoginCodeForPhoneNumber:(NSString *)phoneNumber
                               options:(nullable TGBUseredShortMessageRequestOptions *)options
                              callback:(AVBooleanResultBlock)callback;

/*!
 *  使用手机号码和验证码登录
 *  @param phoneNumber 11位电话号码
 *  @param code 6位验证码
 *  @param error 发生错误通过此参数返回
 */
+ (nullable instancetype)logInWithMobilePhoneNumber:(NSString *)phoneNumber
                                            smsCode:(NSString *)code
                                              error:(NSError **)error;

/*!
 *  使用手机号码和验证码登录
 *  @param phoneNumber 11位电话号码
 *  @param code 6位验证码
 *  @param block 回调结果
 */
+ (void)logInWithMobilePhoneNumberInBackground:(NSString *)phoneNumber
                                       smsCode:(NSString *)code
                                         block:(TGBUseredResultBlock)block;


/*!
 *  使用手机号码和验证码注册或登录
 *  用于手机号直接注册用户，需要使用 [AVOSCloud requestSmsCodeWithPhoneNumber:callback:] 获取验证码
 *  @param phoneNumber 11位电话号码
 *  @param code 6位验证码
 *  @param error 发生错误通过此参数返回
 */
+ (nullable instancetype)signUpOrLoginWithMobilePhoneNumber:(NSString *)phoneNumber
                                                    smsCode:(NSString *)code
                                                      error:(NSError **)error;

/*!
 *  使用手机号码和验证码注册或登录
 *  用于手机号直接注册用户，需要使用 [AVOSCloud requestSmsCodeWithPhoneNumber:callback:] 获取验证码
 *  @param phoneNumber 11位电话号码
 *  @param code 6位验证码
 *  @param block 回调结果
 */
+ (void)signUpOrLoginWithMobilePhoneNumberInBackground:(NSString *)phoneNumber
                                               smsCode:(NSString *)code
                                                 block:(TGBUseredResultBlock)block;

/**
 Use mobile phone number & SMS code & password to sign up or login.

 @param phoneNumber Phone number.
 @param smsCode SMS code.
 @param password Password.
 @param block Result callback.
 */
+ (void)signUpOrLoginWithMobilePhoneNumberInBackground:(NSString *)phoneNumber
                                               smsCode:(NSString *)smsCode
                                              password:(NSString *)password
                                                 block:(TGBUseredResultBlock)block;


/** @name Logging Out */

/*!
 Logs out the currently logged in user on disk.
 */
+ (void)logOut;

/** @name Requesting a Password Reset */


/*!
 Send a password reset request for a specified email and sets an error object. If a user
 account exists with that email, an email will be sent to that address with instructions 
 on how to reset their password.
 @param email Email of the account to send a reset password request.
 @param error Error object to set on error.
 @return true if the reset email request is successful. False if no account was found for the email address.
 */
+ (BOOL)requestPasswordResetForEmail:(NSString *)email
                               error:(NSError **)error;

/*!
 Send a password reset request asynchronously for a specified email.
 If a user account exists with that email, an email will be sent to that address with instructions
 on how to reset their password.
 @param email Email of the account to send a reset password request.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error) 
 */
+ (void)requestPasswordResetForEmailInBackground:(NSString *)email
                                           block:(AVBooleanResultBlock)block;

/*!
 *  使用手机号请求密码重置，需要用户绑定手机号码
 *  发送短信到指定的手机上，内容有6位数字验证码。验证码10分钟内有效。
 *  @param phoneNumber 11位电话号码
 *  @param block 回调结果
 */
+(void)requestPasswordResetWithPhoneNumber:(NSString *)phoneNumber
                                     block:(AVBooleanResultBlock)block;

/**
 Request a password reset code for a phone number.

 @param phoneNumber The phone number of an user whose password will be reset.
 @param options     The short message request options.
 @param callback    The callback of request.
 */
+ (void)requestPasswordResetCodeForPhoneNumber:(NSString *)phoneNumber
                                       options:(nullable TGBUseredShortMessageRequestOptions *)options
                                      callback:(AVBooleanResultBlock)callback;

/*!
 *  使用验证码重置密码
 *  @param code 6位验证码
 *  @param password 新密码
 *  @param block 回调结果
 */
+(void)resetPasswordWithSmsCode:(NSString *)code
                    newPassword:(NSString *)password
                          block:(AVBooleanResultBlock)block;

/*!
 *  用 sessionToken 来登录用户
 *  @param sessionToken sessionToken
 *  @param block        回调结果
 */
+ (void)becomeWithSessionTokenInBackground:(NSString *)sessionToken block:(TGBUseredResultBlock)block;
/*!
 *  用 sessionToken 来登录用户
 *  @param sessionToken sessionToken
 *  @param error        回调错误
 *  @return 登录的用户对象
 */
+ (nullable instancetype)becomeWithSessionToken:(NSString *)sessionToken error:(NSError **)error;

/** @name Querying for Users */

/*!
 Creates a query for TGBUsered objects.
 */
+ (TGBQuery *)query;

// MARK: - Auth Data

/**
 Login use auth data.

 @param authData Get from third platform, data format e.g. { "id" : "id_string", "access_token" : "access_token_string", ... ... }.
 @param platformId The key for the auth data, to identify auth data.
 @param options See TGBUseredAuthDataLoginOption.
 @param callback Result callback.
 */
- (void)loginWithAuthData:(NSDictionary *)authData
               platformId:(NSString *)platformId
                  options:(TGBUseredAuthDataLoginOption * _Nullable)options
                 callback:(void (^)(BOOL succeeded, NSError * _Nullable error))callback;

/**
 Associate auth data to the TGBUsered instance.
 
 @param authData Get from third platform, data format e.g. { "id" : "id_string", "access_token" : "access_token_string", ... ... }.
 @param platformId The key for the auth data, to identify auth data.
 @param options See TGBUseredAuthDataLoginOption.
 @param callback Result callback.
 */
- (void)associateWithAuthData:(NSDictionary *)authData
                   platformId:(NSString *)platformId
                      options:(TGBUseredAuthDataLoginOption * _Nullable)options
                     callback:(void (^)(BOOL succeeded, NSError * _Nullable error))callback;

/**
 Disassociate auth data from the TGBUsered instance.

 @param platformId The key for the auth data, to identify auth data.
 @param callback Result callback.
 */
- (void)disassociateWithPlatformId:(NSString *)platformId
                          callback:(void (^)(BOOL succeeded, NSError * _Nullable error))callback;

// MARK: - Anonymous

/**
 Login anonymously.

 @param callback Result callback.
 */
+ (void)loginAnonymouslyWithCallback:(void (^)(TGBUsered * _Nullable user, NSError * _Nullable error))callback;

/**
 Check whether the instance of TGBUsered is anonymous.

 @return Result.
 */
- (BOOL)isAnonymous;

@end

@interface TGBUseredShortMessageRequestOptions : TGBDynamicObject

@property (nonatomic, copy, nullable) NSString *validationToken;

@end

@interface TGBUsered (Deprecated)

/**
 Use a SNS's auth data to login or signup.
 if the auth data already bind to a valid TGBUsered, then the instance of the TGBUsered will return in result block.
 if the auth data not bind to a exist TGBUsered, then a new instance of TGBUsered will be created and return in result block.
 
 @param authData a Dictionary with specific format.
 e.g.
 {
 "authData" : {
 'platform' : {
 'uid' : someChars,
 'access_token' : someChars,
 ... ... (other attribute)
 }
 }
 }
 @param platform if the auth data belongs to Weibo, QQ or Weixin(Wechat),
 please use `LeanCloudSocialPlatformXXX` to assign platform.
 if not above platform, use a custom string.
 @param block result callback.
 */
+ (void)loginOrSignUpWithAuthData:(NSDictionary *)authData
                         platform:(NSString *)platform
                            block:(TGBUseredResultBlock)block
__deprecated_msg("deprecated, use -[loginWithAuthData:platformId:options:callback:] instead.");

/**
 Associate a SNS's auth data to a instance of TGBUsered.
 after associated, user can login by auth data.
 
 @param authData a Dictionary with specific format.
 e.g.
 {
 "authData" : {
 'platform' : {
 'uid' : someChars,
 'access_token' : someChars,
 ... ... (other attribute)
 }
 }
 }
 @param platform if the auth data belongs to Weibo, QQ or Weixin(Wechat),
 please use `LeanCloudSocialPlatformXXX` to assign platform.
 if not above platform, use a custom string.
 @param block result callback.
 */
- (void)associateWithAuthData:(NSDictionary *)authData
                     platform:(NSString *)platform
                        block:(TGBUseredResultBlock)block
__deprecated_msg("deprecated, use -[associateWithAuthData:platformId:options:callback:] instead.");

/**
 Disassociate the specified platform's auth data from a instance of TGBUsered.
 
 @param platform if the auth data belongs to Weibo, QQ or Weixin(Wechat),
 please use `LeanCloudSocialPlatformXXX` to assign platform.
 if not above platform, use a custom string.
 @param block result callback.
 */
- (void)disassociateWithPlatform:(NSString *)platform
                           block:(TGBUseredResultBlock)block
__deprecated_msg("deprecated, use -[disassociateWithPlatformId:callback:] instead.");

/*!
 Signs up the user. Make sure that password and username are set. This will also enforce that the username isn't already taken.
 @return true if the sign up was successful.
 */
- (BOOL)signUp AV_DEPRECATED("2.6.10");

/*!
 Signs up the user asynchronously. Make sure that password and username are set. This will also enforce that the username isn't already taken.
 */
- (void)signUpInBackground AV_DEPRECATED("2.6.10");

/*!
 Signs up the user asynchronously. Make sure that password and username are set. This will also enforce that the username isn't already taken.
 @param target Target object for the selector.
 @param selector The selector that will be called when the asynchrounous request is complete. It should have the following signature: `(void)callbackWithResult:(NSNumber *)result error:(NSError **)error`. error will be nil on success and set if there was an error. `[result boolValue]` will tell you whether the call succeeded or not.
 */
- (void)signUpInBackgroundWithTarget:(id)target selector:(SEL)selector AV_DEPRECATED("2.6.10");

/*!
 update user's password
 @param oldPassword old password
 @param newPassword new password
 @param target Target object for the selector.
 @param selector The selector that will be called when the asynchrounous request is complete. It should have the following signature: `(void)callbackWithResult:(id)object error:(NSError *)error`. error will be nil on success and set if there was an error.
 @warning the user must have logged in, and provide both oldPassword and newPassword, otherwise can't update password successfully.
 */
- (void)updatePassword:(NSString *)oldPassword newPassword:(NSString *)newPassword withTarget:(id)target selector:(SEL)selector AV_DEPRECATED("2.6.10");

/*!
 Makes a request to login a user with specified credentials. Returns an instance
 of the successfully logged in TGBUsered. This will also cache the user locally so
 that calls to userFromCurrentUser will use the latest logged in user.
 @param username The username of the user.
 @param password The password of the user.
 @return an instance of the TGBUsered on success. If login failed for either wrong password or wrong username, returns nil.
 */
+ (nullable instancetype)logInWithUsername:(NSString *)username
                                  password:(NSString *)password  AV_DEPRECATED("2.6.10");

/*!
 Makes an asynchronous request to login a user with specified credentials.
 Returns an instance of the successfully logged in TGBUsered. This will also cache
 the user locally so that calls to userFromCurrentUser will use the latest logged in user.
 @param username The username of the user.
 @param password The password of the user.
 */
+ (void)logInWithUsernameInBackground:(NSString *)username
                             password:(NSString *)password AV_DEPRECATED("2.6.10");

/*!
 Makes an asynchronous request to login a user with specified credentials.
 Returns an instance of the successfully logged in TGBUsered. This will also cache
 the user locally so that calls to userFromCurrentUser will use the latest logged in user.
 The selector for the callback should look like: myCallback:(TGBUsered *)user error:(NSError **)error
 @param username The username of the user.
 @param password The password of the user.
 @param target Target object for the selector.
 @param selector The selector that will be called when the asynchrounous request is complete.
 */
+ (void)logInWithUsernameInBackground:(NSString *)username
                             password:(NSString *)password
                               target:(id)target
                             selector:(SEL)selector AV_DEPRECATED("2.6.10");

+ (nullable instancetype)logInWithMobilePhoneNumber:(NSString *)phoneNumber
                                           password:(NSString *)password AV_DEPRECATED("2.6.10");
+ (void)logInWithMobilePhoneNumberInBackground:(NSString *)phoneNumber
                                      password:(NSString *)password AV_DEPRECATED("2.6.10");
+ (void)logInWithMobilePhoneNumberInBackground:(NSString *)phoneNumber
                                      password:(NSString *)password
                                        target:(id)target
                                      selector:(SEL)selector AV_DEPRECATED("2.6.10");

+ (nullable instancetype)logInWithMobilePhoneNumber:(NSString *)phoneNumber
                                            smsCode:(NSString *)code AV_DEPRECATED("2.6.10");
+ (void)logInWithMobilePhoneNumberInBackground:(NSString *)phoneNumber
                                       smsCode:(NSString *)code AV_DEPRECATED("2.6.10");
+ (void)logInWithMobilePhoneNumberInBackground:(NSString *)phoneNumber
                                       smsCode:(NSString *)code
                                        target:(id)target
                                      selector:(SEL)selector AV_DEPRECATED("2.6.10");

/*!
 Send a password reset request for a specified email. If a user account exists with that email,
 an email will be sent to that address with instructions on how to reset their password.
 @param email Email of the account to send a reset password request.
 @return true if the reset email request is successful. False if no account was found for the email address.
 */
+ (BOOL)requestPasswordResetForEmail:(NSString *)email AV_DEPRECATED("2.6.10");

/*!
 Send a password reset request asynchronously for a specified email and sets an
 error object. If a user account exists with that email, an email will be sent to
 that address with instructions on how to reset their password.
 @param email Email of the account to send a reset password request.
 */
+ (void)requestPasswordResetForEmailInBackground:(NSString *)email AV_DEPRECATED("2.6.10");

/*!
 Send a password reset request asynchronously for a specified email and sets an error object.
 If a user account exists with that email, an email will be sent to that address with instructions
 on how to reset their password.
 @param email Email of the account to send a reset password request.
 @param target Target object for the selector.
 @param selector The selector that will be called when the asynchronous request is complete. It should have the following signature: (void)callbackWithResult:(NSNumber *)result error:(NSError **)error. error will be nil on success and set if there was an error. [result boolValue] will tell you whether the call succeeded or not.
 */
+ (void)requestPasswordResetForEmailInBackground:(NSString *)email
                                          target:(id)target
                                        selector:(SEL)selector AV_DEPRECATED("2.6.10");

/*!
 Whether the user is an authenticated object for the device. An authenticated TGBUsered is one that is obtained via
 a signUp or logIn method. An authenticated object is required in order to save (with altered values) or delete it.
 @return whether the user is authenticated.
 */
- (BOOL)isAuthenticated AV_DEPRECATED("Deprecated in AVOSCloud SDK 3.7.0. Use -[TGBUsered isAuthenticatedWithSessionToken:callback:] instead.");

@end

NS_ASSUME_NONNULL_END
