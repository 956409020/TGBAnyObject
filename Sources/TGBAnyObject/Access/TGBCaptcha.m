//
//  TGBCaptcha.m
//  AVOS
//
//  Created by Tang Tianyong on 03/05/2017.
//  Copyright © 2017 LeanCloud Inc. All rights reserved.
//

#import "TGBCaptcha.h"
#import "TGBDynamicObject_Internal.h"
#import "TGBNSDictionary+LeanCloud.h"
#import "TGBPaasClient.h"
#import "TGBUtils.h"

@implementation TGBCaptchaDigest

@dynamic nonce;
@dynamic URLString;

@end

@implementation TGBCaptchaRequestOptions

@dynamic width;
@dynamic height;

@end

@implementation TGBCaptcha

+ (void)requestCaptchaWithOptions:(TGBCaptchaRequestOptions *)options
                         callback:(TGBCaptchaRequestCallback)callback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    parameters[@"width"]  = options[@"width"];
    parameters[@"height"] = options[@"height"];

    [[TGBPaasClient sharedInstance] getObject:@"requestCaptcha" withParameters:parameters block:^(id object, NSError *error) {
        if (error) {
            [TGBUtils callIdResultBlock:callback object:nil error:error];
            return;
        }

        NSDictionary *dictionary = [object lc_selectEntriesWithKeyMappings:@{
            @"captcha_token" : @"nonce",
            @"captcha_url"   : @"URLString"
        }];

        TGBCaptchaDigest *captchaDigest = [[TGBCaptchaDigest alloc] initWithDictionary:dictionary];

        [TGBUtils callIdResultBlock:callback object:captchaDigest error:nil];
    }];
}

+ (void)verifyCaptchaCode:(NSString *)captchaCode
         forCaptchaDigest:(TGBCaptchaDigest *)captchaDigest
                 callback:(TGBCaptchaVerificationCallback)callback
{
    NSParameterAssert(captchaCode);
    NSParameterAssert(captchaDigest);

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    parameters[@"captcha_code"]  = captchaCode;
    parameters[@"captcha_token"] = captchaDigest.nonce;

    [[TGBPaasClient sharedInstance] postObject:@"verifyCaptcha" withParameters:parameters block:^(id object, NSError *error) {
        if (error) {
            [TGBUtils callIdResultBlock:callback object:object error:error];
            return;
        }

        NSString *validationToken = object[@"validate_token"];

        [TGBUtils callIdResultBlock:callback object:validationToken error:nil];
    }];
}

@end
