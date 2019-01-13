//
//  TGBAnonymousUtils.h
//  AVOSCloud
//
//

#import <Foundation/Foundation.h>
#import "TGBUsered.h"
#import "TGBConstants.h"
#import "TGBAnonymousUtils.h"
#import "TGBUtils.h"
#import "TGBObjectUtils.h"
#import "TGBPaasClient.h"
#import "TGBUsered.h"
#import "TGBUsered_Internal.h"

@implementation TGBAnonymousUtils

+(NSDictionary *)anonymousAuthData
{
    NSString *anonymousId = [[NSUserDefaults standardUserDefaults] objectForKey:AnonymousIdKey];
    if (!anonymousId) {
        anonymousId = [TGBUtils generateCompactUUID];
        [[NSUserDefaults standardUserDefaults] setObject:anonymousId forKey:AnonymousIdKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSDictionary * data = @{authDataTag: @{@"anonymous": @{@"id": anonymousId}}};
    return data;
}

+ (void)logInWithBlock:(TGBUseredResultBlock)block
{
    NSDictionary * parameters = [TGBAnonymousUtils anonymousAuthData];
    [[TGBPaasClient sharedInstance] postObject:@"users" withParameters:parameters block:^(id object, NSError *error) {
        TGBUsered * user = nil;
        if (error == nil)
        {
            if (![object objectForKey:@"authData"]) {
                object = [NSMutableDictionary dictionaryWithDictionary:object];
                [object addEntriesFromDictionary:parameters];
            }
            user = [TGBUsered userOrSubclassUser];
            [TGBObjectUtils copyDictionary:object toObject:user];
            [TGBUsered changeCurrentUser:user save:YES];
        }
        [TGBUtils callUserResultBlock:block user:user error:error];
    }];
}

+ (void)logInWithTarget:(id)target selector:(SEL)selector
{
    [TGBAnonymousUtils logInWithBlock:^(TGBUsered *user, NSError *error) {
        [TGBUtils performSelectorIfCould:target selector:selector object:user object:error];
    }];
}

+ (BOOL)isLinkedWithUser:(TGBUsered *)user
{
    if ([[user linkedServiceNames] containsObject:@"anonymous"])
    {
        return YES;
    }
    return NO;
}

@end
