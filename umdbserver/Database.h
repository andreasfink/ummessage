//
//  Database.h
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#import <ulib/ulib.h>
#import <ulibdb/ulibdb.h>
#import <ulibsmpp/ulibsmpp.h>
#import <ummessage/UMMessageSessionDelegates.h>

@class ConfigUser;
@class UMMessageObject;

@interface Database : UMObject<UMMessageSessionDatabaseDelegate>
{
    UMSynchronizedDictionary *_msgCache;            /* contains DatabaseCacheEntry objects which contain Message objects */
    UMSynchronizedDictionary *_msgInboundCache;     /* contains DatabaseCacheEntry objects which contain Message objects */
    UMSynchronizedDictionary *_msgOutboundCache;    /* contains DatabaseCacheEntry objects which contain Message objects */
    UMSynchronizedDictionary *_transactionCache;    /* contains DatabaseCacheEntry objects which contain SMSTransaction objects */
    UMMutex *_cacheLock;
    UMDbPool    *_dbPool;
    NSTimeInterval _expiryTime;
    NSString *_msgTableName;
    UMDbTable *_messagesTable;
    UMTimer     *_cleanupTimer;
}

@property(readwrite,strong,atomic)  UMDbPool    *dbPool;
@property(readonly,strong,atomic)   NSString    *msgTableName;
@property(readonly,strong,atomic)   UMDbTable   *messagesTable;



- (BOOL)autocreateTables; /* returns YES on success */

- (UMMessageObject *)getMessage:(NSString *)messageId instance:(NSString *)instance error:(UMMessageServerCommandError *)err;

- (UMMessageServerCommandError)insertOrUpdateMessage:(UMMessageObject *)msg;
- (UMMessageServerCommandError)insertMessage:(UMMessageObject *)msg;
- (UMMessageServerCommandError)updateMessage:(UMMessageObject *)msg;
- (UMMessageServerCommandError)deleteMessage:(NSString *)messageId;


@end


void ummessage_addTableDefString(NSMutableString *o,int len, char *dbname);
void ummessage_addTableDefInteger(NSMutableString *o,int len, char *dbname);
void ummessage_addTableDefDate(NSMutableString *o,int len, char *dbname);
void ummessage_addTableDefData(NSMutableString *o,int len, char *dbname);
void ummessage_addTableDefText(NSMutableString *o,int len, char *dbname);
void ummessage_addTableDefArray(NSMutableString *o,int len, char *dbname);
void ummessage_addTableDefDouble(NSMutableString *o,int len, char *dbname);
/*
void addFieldDefString(UMSynchronizedSortedDictionary *o,int len, char *dbname,char *options);
void addFieldDefInteger(UMSynchronizedSortedDictionary *o,int len, char *dbname,char *options);
void addFieldDefDate(UMSynchronizedSortedDictionary *o,int len, char *dbname,char *options);
void addFieldDefData(UMSynchronizedSortedDictionary *o,int len, char *dbname,char *options);
void addFieldDefText(UMSynchronizedSortedDictionary *o,int len, char *dbname,char *options);
void addFieldDefArray(UMSynchronizedSortedDictionary *o,int len, char *dbname,char *options);
void addFieldDefDouble(UMSynchronizedSortedDictionary *o,int len, char *dbname,char *options);
NSString *fieldDefsToSql(UMSynchronizedSortedDictionary *o, NSString *dbTableName);
*/

