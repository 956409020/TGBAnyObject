
#import "TGBRelation.h"
#import "TGBQuery.h"
#import "TGBUtils.h"
#import "TGBObject_Internal.h"
#import "TGBQuery_Internal.h"
#import "TGBRelation_Internal.h"
#import "TGBObjectUtils.h"

@implementation TGBRelation

- (TGBQuery *)query
{
    NSString *targetClass;
    if (!self.targetClass) {
        targetClass = self.parent.className;
    } else {
        targetClass = self.targetClass;
    }
    TGBQuery * query = [TGBQuery queryWithClassName:targetClass];
    NSMutableDictionary * dict = [@{@"$relatedTo": @{@"object": [TGBObjectUtils dictionaryFromTGBObjectPointer:self.parent], @"key":self.key}} mutableCopy];
    [query setValue:[NSMutableDictionary dictionaryWithDictionary:dict] forKey:@"where"];
    if (!self.targetClass) {
        query.extraParameters = [@{@"redirectClassNameForKey":self.key} mutableCopy];
    }
    return query;
}

- (void)addObject:(TGBObject *)object
{
    // check object id
    if (![object hasValidObjectId]) {
        NSException * exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                          reason:@"All objects in a relation must have object ids."
                                                        userInfo:nil];
        [exception raise];
    }
    self.targetClass = object.className;
    [self.parent addRelation:object forKey:self.key submit:YES];
}

- (void)removeObject:(TGBObject *)object
{
    [self.parent removeRelation:object forKey:self.key];
}

+(TGBQuery *)reverseQuery:(NSString *)parentClassName
             relationKey:(NSString *)relationKey
             childObject:(TGBObject *)child
{
    NSDictionary * dict = @{relationKey: [TGBObjectUtils dictionaryFromTGBObjectPointer:child]};
    TGBQuery * query = [TGBQuery queryWithClassName:parentClassName];
    [query setValue:[NSMutableDictionary dictionaryWithDictionary:dict] forKey:@"where"];
    return query;
}

+(TGBRelation *)relationFromDictionary:(NSDictionary *)dict {
    TGBRelation * relation = [[TGBRelation alloc] init];
    relation.targetClass = [dict objectForKey:classNameTag];
    return relation;
}

@end


