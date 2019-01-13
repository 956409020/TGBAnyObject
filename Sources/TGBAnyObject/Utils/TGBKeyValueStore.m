//
//  TGBKeyValueStore.m
//  AVOS
//
//  Created by Tang Tianyong on 6/26/15.
//  Copyright (c) 2015 LeanCloud Inc. All rights reserved.
//

#import "TGBKeyValueStore.h"
#import "TGBKeyValueSQL.h"
#import "TGBDatabase.h"
#import "TGBDatabaseQueue.h"
#import "TGBPersistenceUtils.h"

#import <libkern/OSAtomic.h>

#ifdef DEBUG
static BOOL shouldLogError = YES;
#else
static BOOL shouldLogError = NO;
#endif

#define LC_OPEN_DATABASE(db, routine) do {        \
    [self.dbQueue inDatabase:^(TGBDatabase *db) {  \
        db.logsErrors = shouldLogError;           \
        routine;                                  \
    }];                                           \
} while (0)

static OSSpinLock dbQueueLock = OS_SPINLOCK_INIT;

@interface TGBKeyValueStore () {
    NSString *_dbPath;
    NSString *_tableName;
    TGBDatabaseQueue *_dbQueue;
}

- (NSString *)dbPath;
- (NSString *)tableName;
- (TGBDatabaseQueue *)dbQueue;

@end

@implementation TGBKeyValueStore

+ (instancetype)sharedInstance {
    static TGBKeyValueStore *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

+ (instancetype)userDefaultsKeyValueStore {
    static TGBKeyValueStore *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initWithDatabasePath:[TGBPersistenceUtils userDefaultsPath]];
    });

    return instance;
}

- (instancetype)initWithDatabasePath:(NSString *)databasePath {
    self = [super init];

    if (self) {
        _dbPath = [databasePath copy];
    }

    return self;
}

- (instancetype)initWithDatabasePath:(NSString *)databasePath tableName:(NSString *)tableName {
    self = [self initWithDatabasePath:databasePath];

    if (self) {
        _tableName = [tableName copy];
    }

    return self;
}

- (NSString *)formatSQL:(NSString *)SQL withTableName:(NSString *)tableName {
    return [NSString stringWithFormat:SQL, tableName];
}

- (NSData *)dataForKey:(NSString *)key {
    __block NSData *data = nil;

    LC_OPEN_DATABASE(db, ({
        NSArray *args = @[key];
        NSString *SQL = [self formatSQL:LC_SQL_SELECT_KEY_VALUE_FMT withTableName:[self tableName]];
        TGBResultSet *result = [db executeQuery:SQL withArgumentsInArray:args];

        if ([result next]) {
            data = [result dataForColumn:LC_FIELD_VALUE];
        }

        [result close];
    }));

    return data;
}

- (void)setData:(NSData *)data forKey:(NSString *)key {
    LC_OPEN_DATABASE(db, ({
        NSArray *args = @[key, data];
        NSString *SQL = [self formatSQL:LC_SQL_UPDATE_KEY_VALUE_FMT withTableName:[self tableName]];
        [db executeUpdate:SQL withArgumentsInArray:args];
    }));
}

- (void)deleteKey:(NSString *)key {
    LC_OPEN_DATABASE(db, ({
        NSArray *args = @[key];
        NSString *SQL = [self formatSQL:LC_SQL_DELETE_KEY_VALUE_FMT withTableName:[self tableName]];
        [db executeUpdate:SQL withArgumentsInArray:args];
    }));
}

- (void)createSchemeForDatabaseQueue:(TGBDatabaseQueue *)dbQueue {
    [dbQueue inDatabase:^(TGBDatabase *db) {
        db.logsErrors = shouldLogError;

        NSString *SQL = [self formatSQL:LC_SQL_CREATE_KEY_VALUE_TABLE_FMT withTableName:[self tableName]];
        [db executeUpdate:SQL];
    }];
}

- (NSString *)dbPath {
    return _dbPath ?: [TGBPersistenceUtils keyValueDatabasePath];
}

- (NSString *)tableName {
    return _tableName ?: LC_TABLE_KEY_VALUE;
}

- (TGBDatabaseQueue *)dbQueue {
    OSSpinLockLock(&dbQueueLock);

    if (!_dbQueue) {
        _dbQueue = [TGBDatabaseQueue databaseQueueWithPath:[self dbPath]];

        [self createSchemeForDatabaseQueue:_dbQueue];
    }

    OSSpinLockUnlock(&dbQueueLock);

    return _dbQueue;
}

@end
