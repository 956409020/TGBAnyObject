//
//  TGBDatabaseMigrator.m
//  AVOS
//
//  Created by Tang Tianyong on 6/1/15.
//  Copyright (c) 2015 LeanCloud Inc. All rights reserved.
//

#import "TGBDatabaseMigrator.h"
#import "TGBDatabaseCoordinator.h"
#import "TGBDatabase.h"
#import "TGBDatabaseAdditions.h"

#import <libkern/OSAtomic.h>

@interface TGBDatabaseMigrator () {
    TGBDatabaseCoordinator *_coordinator;
    OSSpinLock _coordinatorLock;
}

@property (readonly) TGBDatabaseCoordinator *coordinator;

@end

@implementation TGBDatabaseMigrator

- (instancetype)init {
    self = [super init];

    if (self) {
        _coordinatorLock = OS_SPINLOCK_INIT;
    }

    return self;
}

- (instancetype)initWithDatabasePath:(NSString *)databasePath {
    self = [super init];

    if (self) {
        _databasePath = [databasePath copy];
    }

    return self;
}

- (NSInteger)versionOfDatabase {
    __block NSInteger version = 0;

    [self.coordinator executeJob:^(TGBDatabase *db) {
        version = (NSInteger)[db userVersion];
    }];

    return version;
}

- (void)applyMigrations:(NSArray *)migrations
            fromVersion:(uint32_t)fromVersion
               database:(TGBDatabase *)database
{
    for (TGBDatabaseMigration *migration in migrations) {
        if (migration.block) {
            migration.block(database);
        }

        [database setUserVersion:++fromVersion];
    }
}

- (void)executeMigrations:(NSArray *)migrations {
    uint32_t newVersion = (uint32_t)[migrations count];
    uint32_t oldVersion = (uint32_t)[self versionOfDatabase];

    if (oldVersion < newVersion) {
        NSArray *restMigrations = [migrations subarrayWithRange:NSMakeRange(oldVersion, newVersion - oldVersion)];

        [self.coordinator
         executeTransaction:^(TGBDatabase *db) {
             [self applyMigrations:restMigrations fromVersion:oldVersion database:db];
         }
         fail:^(TGBDatabase *db) {
             [db setUserVersion:oldVersion];
         }];
    }
}

#pragma mark - Lazy loading

- (TGBDatabaseCoordinator *)coordinator {
    OSSpinLockLock(&_coordinatorLock);

    if (!_coordinator) {
        _coordinator = [[TGBDatabaseCoordinator alloc] initWithDatabasePath:_databasePath];
    }

    OSSpinLockUnlock(&_coordinatorLock);

    return _coordinator;
}

@end

@implementation TGBDatabaseMigration

+ (instancetype)migrationWithBlock:(TGBDatabaseJob)block {
    return [[self alloc] initWithBlock:block];
}

- (instancetype)initWithBlock:(TGBDatabaseJob)block {
    self = [super init];

    if (self) {
        _block = [block copy];
    }

    return self;
}

@end
