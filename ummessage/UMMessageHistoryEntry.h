//
//  UMMessageHistoryEntry.h
//  ummessage
//
//  Created by Andreas Fink on 07.04.2025.
//

#import <ulib/ulib.h>
#import <ulibdb/ulibdb.h>
#import <ulibasn1/ulibasn1.h>
#import <um/UMMessageHistoryEntryFields.h>

@interface UMMessageHistoryEntry : UMASN1Sequence
{
    
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  NSString *field;
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    NSDate *field;
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)    double field;
#include <um/UMMessageHistoryEntry.def.h>
#undef STRING
#undef DATE
#undef REAL

    BOOL _insertedIntoDb;
}

#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  @property(readwrite,atomic,strong) NSString *accessor;
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    @property(readwrite,atomic,strong) NSDate *accessor;
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)    @property(readwrite,atomic,assign) double accessor;
#include <um/UMMessageHistoryEntry.def.h>
#undef STRING
#undef DATE
#undef REAL

@property(readwrite,assign,atomic) BOOL insertedIntoDb;


+ (NSString *)sqlTableDefForTableName:(NSString *)tableName;
+ (NSArray<NSString *>*)dbFieldNames;
- (NSString *)insert:(NSString *)tableName session:(UMDbSession *)session;
- (NSString *)description;
- (UMSynchronizedSortedDictionary *) objectValue;
- (void) processBeforeEncode;
- (UMMessageHistoryEntry *) processAfterDecodeWithContext:(id)context;

- (UMMessageHistoryEntry *)initWithArchiveId:(NSString *)archive
                                    instance:(NSString *)instance
                                   messageId:(NSString *)messageId
                                      msisdn:(NSString *)msisdn
                                          ts:(NSDate *)date
                                       delay:(double)delay
                                        text:(NSString *)text;

@end



