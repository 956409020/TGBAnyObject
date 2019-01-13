//
//  TGBCloudQueryResult.m
//  AVOS
//
//  Created by Qihe Bian on 9/22/14.
//
//

#import "TGBCloudQueryResult.h"
#import "TGBCloudQueryResult_Internal.h"

@implementation TGBCloudQueryResult

- (void)setClassName:(NSString *)className {
    _className = className;
}

- (void)setResults:(NSArray *)results {
    _results = results;
}

- (void)setCount:(NSUInteger)count {
    _count = count;
}
@end
