//
//  TGBDatabaseCoordinator.h
//  AVOS
//
//  Created by Tang Tianyong on 6/1/15.
//  Copyright (c) 2015 LeanCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGBDatabaseCommon.h"

@interface TGBDatabaseCoordinator : NSObject

@property (readonly) NSString *databasePath;

- (instancetype)initWithDatabasePath:(NSString *)databasePath;

- (void)executeTransaction:(TGBDatabaseJob)job fail:(TGBDatabaseJob)fail;

- (void)executeJob:(TGBDatabaseJob)job;

@end
