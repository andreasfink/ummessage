//
//  UMMessageHistory.m
//  um
//
//  Created by Andreas Fink on 07.04.2025.
//

#import "UMMessageHistory.h"
#import "UMMessageHistoryEntry.h"
#import "UMMessage_macroHelper.h"

@implementation UMMessageHistory

- (UMMessageHistory *)init
{
    self = [super init];
    if(self)
    {
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  field = @"";
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    field = [NSDate date];
#include <ummessage/UMMessageHistory.def.h>
#undef STRING
#undef DATE
        _entries = [[UMSynchronizedArray alloc]init];
    }
    return self;
}

+ (NSString *)sqlTableDefForTableName:(NSString *)tableName
{
    UMSynchronizedSortedDictionary *o = [[UMSynchronizedSortedDictionary alloc]init];

#define STRING(o,len,tag,dictname,var,accessor,dbname,options)  ummessage_addFieldDefString(o,len,dbname,options);
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)    ummessage_addFieldDefDate(o,len,dbname,options);
#include <ummessage/UMMessageHistory.def.h>
#undef STRING
#undef DATE
    return ummessage_fieldDefsToSql(o,tableName);
}

+ (NSArray<NSString *>*) dbFieldNames
{
    NSMutableArray *o = [[NSMutableArray alloc]init];
#define STRING(o,len,tag,dictname,var,accessor,dbname,options)  [o addObject:@(dbname)];
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)    [o addObject:@(dbname)];
#include <ummessage/UMMessageHistory.def.h>
#undef STRING
#undef DATE
    return o;
}

- (NSString *)insert:(NSString *)tableName session:(UMDbSession *)session
{
    NSMutableString *o = [[NSMutableString alloc]init];
    [o appendFormat:@"INSERT INTO `%@` (",tableName];
    int i=0;
    
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#include <ummessage/UMMessageHistory.def.h>
#undef STRING
#undef DATE
    
    [o appendString:@") VALUES("];
    i=0;
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field]];};
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#include <ummessage/UMMessageHistory.def.h>
#undef STRING
#undef DATE
    
    [o appendString:@")"];
    return o;
}

- (NSString *)description
{
    return [[self objectValue]jsonString];
}

- (UMSynchronizedSortedDictionary *) objectValue
{
    UMSynchronizedSortedDictionary *dict = [[UMSynchronizedSortedDictionary alloc]init];
    
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { dict[@(dictname)] = field; }
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)      if(field) { dict[@(dictname)] = field; }
#include <ummessage/UMMessageHistory.def.h>
#undef STRING
#undef DATE
    if(_entries.count > 0)
    {
        dict[@"entries"] = _entries.array;
    }
    return dict;
}

- (void) processBeforeEncode
{
    [super processBeforeEncode];
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)                        \
if(field)                                                                               \
{                                                                                       \
    UMASN1UTF8String *u = [[UMASN1UTF8String alloc]initWithString:field];               \
    u.asn1_tag.tagNumber = tag;                                                         \
    u.asn1_tag.tagClass = UMASN1Class_ContextSpecific;                                  \
    [_asn1_list addObject:u];                                                           \
}

#define DATE(o,len,tag,dictname,field,accessor,dbname,options)                          \
if(field)                                                                               \
{                                                                                       \
    NSString *sd = [NSString stringWithStandardDate:field.dateValue]  ;                 \
    UMASN1UTF8String *u = [[UMASN1UTF8String alloc]initWithString:sd];                  \
    u.asn1_tag.tagNumber = tag;                                                         \
    u.asn1_tag.tagClass = UMASN1Class_ContextSpecific;                                  \
    [_asn1_list addObject:u];                                                           \
}
#include <ummessage/UMMessageHistory.def.h>
#undef STRING
#undef DATE
    if(_entries.count > 0)
    {
        UMASN1Sequence *seq = [[UMASN1Sequence alloc]initWithValues:_entries.array];
        seq.asn1_tag.tagNumber = UMMESSAGE_HISTORY_CODETAG_ENTRIES;
        seq.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [_asn1_list addObject:seq];
    }
}


- (UMMessageHistory *) processAfterDecodeWithContext:(id)context
{
    [super processAfterDecodeWithContext:context];
    int pos = 0;
    UMASN1Object *o = [self getObjectAtPosition:pos++];
    while(o)
    {
        if(o.asn1_tag.tagClass==UMASN1Class_ContextSpecific)
        {
            switch(o.asn1_tag.tagNumber)
            {
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)                                \
case tag:                                                                                       \
{                                                                                               \
    UMASN1UTF8String *u = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];       \
    field = u.stringValue;                                                                      \
}\
break;

#define DATE(o,len,tag,dictname,field,accessor,dbname,options)                                  \
case tag:                                                                                       \
{                                                                                               \
    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];       \
    field = s.stringValue.dateValue;                                                           \
}\
break;
#include <ummessage/UMMessageHistory.def.h>
#undef STRING
#undef DATE
                case UMMESSAGE_HISTORY_CODETAG_ENTRIES:
                {
                    UMASN1Sequence *seq = [[UMASN1Sequence alloc]initWithASN1Object:o context:context];
                    NSArray *a = seq.values;
                    _entries = [[UMSynchronizedArray alloc]init];
                    for (UMASN1Object *o in a)
                    {
                        UMMessageHistoryEntry *entry = [[UMMessageHistoryEntry alloc]initWithASN1Object:o context:context];
                        [_entries addObject:entry];
                    }
                }
                default:
                    break;
            }
        }
        o = [self getObjectAtPosition:pos++];
    }
    return self;
}

- (void)addEntryWithArchiveId:(NSString *)archive
                     instance:(NSString *)instance
                    messageId:(NSString *)messageId
                       msisdn:(NSString *)msisdn
                           ts:(NSDate *)ts
                        delay:(double)delay
                         text:(NSString *)text
{
    UMMessageHistoryEntry *entry = [[UMMessageHistoryEntry alloc]initWithArchiveId:archive
                                                                          instance:instance
                                                                         messageId:messageId
                                                                            msisdn:msisdn
                                                                                ts:ts
                                                                             delay:delay
                                                                              text:text];
    [_entries addObject:entry];
}


@end


