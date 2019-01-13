
#import <Foundation/Foundation.h>
#import "TGBObject.h"
#import "TGBObject_Internal.h"
#import "TGBRole.h"
#import "TGBRole_Internal.h"
#import "TGBQuery.h"
#import "TGBRelation.h"
#import "TGBRelation_Internal.h"
#import "TGBACL.h"
#import "TGBPaasClient.h"
#import "TGBGlobal.h"
#import "TGBUtils.h"

@implementation TGBRole

@synthesize name = _name;
@synthesize acl = _acl;
@synthesize relationData = _relationData;

+(NSString *)className
{
    return @"_Role";
}

+(NSString *)endPoint
{
    return @"roles";
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super initWithClassName:[TGBRole className]];
    if (self)
    {
        self.name = name;
        _relationData = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+(instancetype)role {
    TGBRole * r = [[TGBRole alloc] initWithName:@""];
    return r;
}

- (instancetype)initWithName:(NSString *)name acl:(TGBACL *)acl
{
    self = [self initWithName:name];
    if (self)
    {
        self.acl = acl;
    }
    return self;
}

+ (instancetype)roleWithName:(NSString *)name
{
    TGBRole * role = [[TGBRole alloc] initWithName:name];
    return role;
}

+ (instancetype)roleWithName:(NSString *)name acl:(TGBACL *)acl
{
    TGBRole * role = [[TGBRole alloc] initWithName:name acl:acl];
    return role;
}

- (TGBRelation *)users
{
    return [self relationForKey:@"users"];
}

- (TGBRelation *)roles
{
    return [self relationForKey:@"roles"];
}

+ (TGBQuery *)query
{
    TGBQuery *query = [[TGBQuery alloc] initWithClassName:[TGBRole className]];
    return query;
}

-(NSMutableDictionary *)initialBodyData {
    return [self.requestManager initialSetAndAddRelationDict];
}

-(void)setName:(NSString *)name {
    _name = name;
    [self addSetRequest:@"name" object:name];
}

-(void)setAcl:(TGBACL *)acl {
    _acl = acl;
    [self addSetRequest:ACLTag object:acl];
}

@end
