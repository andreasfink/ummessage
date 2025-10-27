//
//  UMMessageHistory.h
//  um
//
//  Created by Andreas Fink on 07.04.2025.
//

#import <ulibasn1/ulibasn1.h>
#import <ulibdb/ulibdb.h>
#import <ummessage/UMMessageHistoryFields.h>

@interface UMMessageHistory : UMASN1Sequence
{
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  NSString *field;
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    NSDate   *field;
#include <ummessage/UMMessageHistory.def.h>
#undef STRING
#undef DATE
    UMSynchronizedArray *_entries;
}

#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  @property(readwrite,atomic,strong) NSString *accessor;
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    @property(readwrite,atomic,strong) NSDate   *accessor;
#include <ummessage/UMMessageHistory.def.h>
#undef STRING
#undef DATE

@property(readwrite,strong,atomic) UMSynchronizedArray *entries;

+ (NSString *)sqlTableDefForTableName:(NSString *)tableName;
+ (NSArray<NSString *>*)dbFieldNames;
- (NSString *)insert:(NSString *)tableName session:(UMDbSession *)session;
- (NSString *)description;
- (UMSynchronizedSortedDictionary *) objectValue;
- (void) processBeforeEncode;
- (UMMessageHistory *) processAfterDecodeWithContext:(id)context;


- (void)addEntryWithArchiveId:(NSString *)archive
                     instance:(NSString *)instance
                    messageId:(NSString *)messageId
                       msisdn:(NSString *)msisdn
                           ts:(NSDate *)ts
                        delay:(double)delay
                         text:(NSString *)text;


@end
