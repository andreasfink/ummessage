//
//  Database.m
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#import "Database.h"
#include <ummessage/UMMessageObject.h>
#import "DatabaseCacheEntry.h"


@implementation Database

- (Database *)init
{
    self = [super init];
    if(self)
    {
        _msgCache  = [[UMSynchronizedDictionary alloc]init];
        _cacheLock = [[UMMutex alloc]initWithName:@"db-lock"];
        _expiryTime = 30*60.0; /* 30 minutes */

        _msgTableName                       = @"msg";
        _messagesTable                      = [[UMDbTable alloc]init];
        _messagesTable.tableName            = _msgTableName;
    }
    return self;
}

-(void)setDbPool:(UMDbPool *)dbPool
{
    _dbPool                             = dbPool;
    _messagesTable.pool                 = dbPool;
}

- (UMDbPool *)dbPool
{
    return _dbPool;
}

- (BOOL)autocreateTables
{
    BOOL success=NO;
    UMDbSession *session = [_dbPool grabSession:FLF];
    if(session)
    {
        NSArray *sqlCommands = @[
            [UMMessageObject sqlTableDefForTableName:_msgTableName],
        ];
        success = [session queriesWithNoResult:sqlCommands allowFail:YES];
        [session.pool returnSession:session file:FLF];
    }
    return success;
}


- (UMMessageServerCommandError)insertOrUpdateMessage:(UMMessageObject *)msg
{
    UMMessageServerCommandError err=UMMessageServerCommandError_NO_ERROR;
    if(msg!=NULL)
    {
        [self insertObject:msg
                 intoCache:_msgCache
                       key:msg.archiveId.stringValue];
        UMDbSession *session = [_dbPool grabSession:FLF];
        if(session)
        {
            NSArray *sqlCommands = @[[msg insertOrUpdate:_msgTableName session:session]];
            BOOL success = [session queriesWithNoResult:sqlCommands allowFail:YES];
            if(success==NO)
            {
                err = UMMessageServerCommandError_INSERT_FAILURE;
            }
            else
            {
                msg.hasBeenInserted = YES;
                msg.isDirty = NO;
            }
            [session.pool returnSession:session file:FLF];
        }
        else
        {
            err = UMMessageServerCommandError_NO_DB_SESSIONS_AVAILABLE;
        }
    }
    return err;
}

- (UMMessageServerCommandError)insertMessage:(UMMessageObject *)msg
{
    UMMessageServerCommandError err=UMMessageServerCommandError_NO_ERROR;
    if(msg!=NULL)
    {
        [self insertObject:msg
                 intoCache:_msgCache
                       key:msg.archiveId.stringValue];
        UMDbSession *session = [_dbPool grabSession:FLF];
        if(session)
        {
            NSArray *sqlCommands = @[[msg insert:_msgTableName session:session]];
            BOOL success = [session queriesWithNoResult:sqlCommands allowFail:YES];
            if(success==NO)
            {
                err = UMMessageServerCommandError_INSERT_FAILURE;
            }
            else
            {
                msg.hasBeenInserted = YES;
                msg.isDirty = NO;
            }
            [session.pool returnSession:session file:FLF];
        }
        else
        {
            err = UMMessageServerCommandError_NO_DB_SESSIONS_AVAILABLE;
        }
    }
    return err;
}

- (UMMessageServerCommandError)updateMessage:(UMMessageObject *)msg
{
    UMMessageServerCommandError err=UMMessageServerCommandError_NO_ERROR;
    if(msg!=NULL)
    {
        [self insertObject:msg
                 intoCache:_msgCache
                       key:msg.archiveId.stringValue];
        UMDbSession *session = [_dbPool grabSession:FLF];
        if(session)
        {
            NSArray *sqlCommands = @[[msg update:_msgTableName session:session]];
            BOOL success = [session queriesWithNoResult:sqlCommands allowFail:YES];
            if(success==NO)
            {
                err = UMMessageServerCommandError_INSERT_FAILURE;
            }
            else
            {
                msg.hasBeenInserted = YES;
                msg.isDirty = NO;
            }
            [session.pool returnSession:session file:FLF];
        }
        else
        {
            err = UMMessageServerCommandError_NO_DB_SESSIONS_AVAILABLE;
        }
    }
    return err;
}

- (UMMessageServerCommandError)deleteMessage:(NSString *)archiveId
{
    UMMessageServerCommandError err = UMMessageServerCommandError_NO_ERROR;
    [self deleteObjectFromCache:_msgCache forKey:archiveId];
    
    UMDbSession *session = [_dbPool grabSession:FLF];
    if(session)
    {
        NSArray *sqlCommands = @[[NSString stringWithFormat:@"DELETE FROM `%@` WHERE archive_id=`%@` ",_msgTableName,[session sqlEscapeString:archiveId.stringValue]]];
        BOOL success = [session queriesWithNoResult:sqlCommands allowFail:YES];
        if(success==NO)
        {
            err = UMMessageServerCommandError_DELETE_FAILURE;
        }
        [session.pool returnSession:session file:FLF];
    }
    else
    {
        err = UMMessageServerCommandError_NO_DB_SESSIONS_AVAILABLE;
    }
    return err;
}


- (UMMessageObject *)getMessage:(NSString *)messageId instance:(NSString *)instance error:(UMMessageServerCommandError *)err
{
    UMMessageObject *m = [self getObjectFromCache:_msgCache forKey:messageId];
    if(m==NULL)
    {
        UMDbSession *session = [_dbPool grabSession:FLF];
        if(session)
        {
            UMDbQuery *query;
            if(_dbPool.dbDriverType!=UMDBDRIVER_REDIS)
            {
                query = [UMDbQuery queryForFile:__FILE__ line: __LINE__];
                if(![query isInCache])
                {
                    [query setType:UMDBQUERYTYPE_SELECT_BY_KEY];
                    [query setTable:_messagesTable];
                    [query setPrimaryKeyName:@"message_id"];
                }
            }
            else
            {
                /* the REDIS way */
                query = [UMDbQuery queryForFile:__FILE__ line: __LINE__];
                if(![query isInCache])
                {
                    [query setType:UMDBQUERYTYPE_SELECT_BY_KEY_FROM_LIST];
                    [query setTable:_messagesTable];
                    [query setFields:@[@"key",@"message_id"]];
                    [query setPrimaryKeyName:@"key"];
                }
            }
            UMDbResult *result = [session cachedQueryWithMultipleRowsResult:query
                                                                 parameters:@[]
                                                                  allowFail:NO
                                                            primaryKeyValue:messageId];
            if(result.resultArray.count ==0)
            {
                *err = UMMessageServerCommandError_NOT_FOUND;
            }
            else
            {
                m = [UMMessageObject messageFromDbResult:result];
            }
            [session.pool returnSession:session file:FLF];
        }
        else
        {
            *err = UMMessageServerCommandError_NO_DB_SESSIONS_AVAILABLE;
        }
    }
    return m;
}

- (void)insertObject:(id)o
           intoCache:(UMSynchronizedDictionary *)cache
                 key:(NSString *)key
{
    ummutex_lock(_cacheLock);
    DatabaseCacheEntry *e = cache[key];
    if(e == NULL)
    {
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:_expiryTime];
        e = [[DatabaseCacheEntry alloc]initWithObject:o
                                               expiry:date
                                                  key:key];
    }
    _msgInboundCache[key] = e;
    ummutex_unlock(_cacheLock);
}

- (id)getObjectFromCache:(UMSynchronizedDictionary *)cache
                  forKey:(NSString *)key
{
    id cachedObject = NULL;
    ummutex_lock(_cacheLock);
    DatabaseCacheEntry *e = cache[key];
    if(e == NULL)
    {
        cachedObject = e.cachedObject;
    }
    ummutex_unlock(_cacheLock);
    return cachedObject;
}

- (void)deleteObjectFromCache:(UMSynchronizedDictionary *)cache
                       forKey:(NSString *)key
{
    [cache removeObjectForKey:key];
}

- (void)cacheExpire:(UMSynchronizedDictionary *)cache
{
    ummutex_lock(_cacheLock);
    NSArray *keys = [_msgCache allKeys];
    NSDate *now = [NSDate date];
    for(id key in keys)
    {
        DatabaseCacheEntry *e = cache[key];
        if([e.expiry isLessThan:now])
        {
            [cache removeObjectForKey:key];
        }
    }
    ummutex_unlock(_cacheLock);
}

- (void)housekeeping
{
    [self cacheExpire:_msgCache];
    [self cacheExpire:_msgInboundCache];
    [self cacheExpire:_msgOutboundCache];
}

@end

