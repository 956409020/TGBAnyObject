//
//  TGBDatabaseMigrator.h
//  AVOS
//
//  Created by Tang Tianyong on 6/1/15.
//  Copyright (c) 2015 LeanCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGBDatabaseCommon.h"

/*!
 * Database migration object.
 */
@interface TGBDatabaseMigration : NSObject

/*!
 * The job of current migration.
 */
@property (readonly) TGBDatabaseJob block;

+ (instancetype)migrationWithBlock:(TGBDatabaseJob)block;

- (instancetype)initWithBlock:(TGBDatabaseJob)block;

@end

/*!
 * SQLite database migrator.
 */
@interface TGBDatabaseMigrator : NSObject

@property (readonly) NSString *databasePath;

- (instancetype)initWithDatabasePath:(NSString *)databasePath;

/*!
 * Migrate database with migrations.
 * @param migrations An array of object confirms TGBDatabaseMigration protocol.
 * NOTE: migration can not be removed, only can be added.
 */
- (void)executeMigrations:(NSArray *)migrations;

@end
