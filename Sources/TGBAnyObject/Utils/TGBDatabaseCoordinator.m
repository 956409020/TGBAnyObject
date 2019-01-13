//
//  TGBDatabaseCoordinator.m
//  AVOS
//
//  Created by Tang Tianyong on 6/1/15.
//  Copyright (c) 2015 LeanCloud Inc. All rights reserved.
//

#import "TGBDatabaseCoordinator.h"
#import "TGBDatabase.h"
#import "TGBDatabaseQueue.h"
//#import "AVLogger.h"
#import "TGBErrorUtils.h"

#import <libkern/OSAtomic.h>

#ifdef DEBUG
#define LC_SHOULD_LOG_ERRORS YES
#else
#define LC_SHOULD_LOG_ERRORS NO
#endif

@interface TGBDatabaseCoordinator () {
    TGBDatabaseQueue *_dbQueue;
    OSSpinLock _dbQueueLock;
}

- (TGBDatabaseQueue *)dbQueue;

@end

@implementation TGBDatabaseCoordinator

- (instancetype)init {
    self = [super init];

    if (self) {
        _dbQueueLock = OS_SPINLOCK_INIT;
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

- (void)executeTransaction:(TGBDatabaseJob)job fail:(TGBDatabaseJob)fail {
    [self executeJob:^(TGBDatabase *db) {
        [db beginTransaction];
        @try {
            job(db);
            [db commit];
        } @catch (NSException *exception) {
            [db rollback];
            fail(db);
        }
    }];
}

- (void)executeJob:(TGBDatabaseJob)job {
    [self.dbQueue inDatabase:^(TGBDatabase *db) {
        db.logsErrors = LC_SHOULD_LOG_ERRORS;
        job(db);
    }];
}

#pragma mark - Lazy loading

- (TGBDatabaseQueue *)dbQueue {
    if (!_databasePath) {
//        AVLoggerError(AVLoggerDomainDefault, @"%@: Database path not found.", [[self class] descriptionb]);
        return nil;
    }

    OSSpinLockLock(&_dbQueueLock);

    if (!_dbQueue) {
        _dbQueue = [TGBDatabaseQueue databaseQueueWithPath:_databasePath];
    }

    OSSpinLockUnlock(&_dbQueueLock);

    return _dbQueue;
}

#pragma mark -

- (void)dealloc {
    [_dbQueue close];
}

@end
