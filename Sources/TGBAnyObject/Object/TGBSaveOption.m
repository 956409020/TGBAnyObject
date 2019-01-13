//
//  TGBSaveOption.m
//  AVOS
//
//  Created by Tang Tianyong on 1/12/16.
//  Copyright © 2016 LeanCloud Inc. All rights reserved.
//

#import "TGBSaveOption.h"
#import "TGBSaveOption_internal.h"
#import "TGBQuery.h"
#import "TGBQuery_Internal.h"

@implementation TGBSaveOption

- (NSDictionary *)dictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    if (self.fetchWhenSave)
        result[@"fetchWhenSave"] = @(YES);

    if (self.query)
        result[@"where"] = [self.query whereJSONDictionary];

    return result;
}

@end
