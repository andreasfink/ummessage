//
//  Database.h
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#import <ulib/ulib.h>
#import <ulibdb/ulibdb.h>
#import <ulibsmpp/ulibsmpp.h>

@class ConfigUser;
@class UMMessage;

@interface Database : UMObject
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

- (UMMessage *)loadMessage:(NSString *)messageId;
- (UMMessage *)loadMessage:(NSString *)messageId table:(UMDbTable *)dbTable;
- (BOOL)insertOrUpdateMessage:(UMMessage *)msg;  /* returns YES on success */

@end


void addTableDefString(NSMutableString *o,int len, char *dbname);
void addTableDefInteger(NSMutableString *o,int len, char *dbname);
void addTableDefDate(NSMutableString *o,int len, char *dbname);
void addTableDefData(NSMutableString *o,int len, char *dbname);
void addTableDefText(NSMutableString *o,int len, char *dbname);
void addTableDefArray(NSMutableString *o,int len, char *dbname);
void addTableDefDouble(NSMutableString *o,int len, char *dbname);

void addFieldDefString(UMSynchronizedSortedDictionary *o,int len, char *dbname,char *options);
void addFieldDefInteger(UMSynchronizedSortedDictionary *o,int len, char *dbname,char *options);
void addFieldDefDate(UMSynchronizedSortedDictionary *o,int len, char *dbname,char *options);
void addFieldDefData(UMSynchronizedSortedDictionary *o,int len, char *dbname,char *options);
void addFieldDefText(UMSynchronizedSortedDictionary *o,int len, char *dbname,char *options);
void addFieldDefArray(UMSynchronizedSortedDictionary *o,int len, char *dbname,char *options);
void addFieldDefDouble(UMSynchronizedSortedDictionary *o,int len, char *dbname,char *options);
NSString *fieldDefsToSql(UMSynchronizedSortedDictionary *o, NSString *dbTableName);
