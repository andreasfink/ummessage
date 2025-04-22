//
//  UMMessageHistoryEntry.m
//  um
//
//  Created by Andreas Fink on 07.04.2025.
//
#import "UMMessageHistoryEntry.h"
#import "UMMessage_macroHelper.h"
#import <ulibdb/ulibdb.h>

@implementation UMMessageHistoryEntry

- (UMMessageHistoryEntry *)init
{
    self = [super init];
    if(self)
    {
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  field = @"";
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    field = [NSDate date];
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)    field = 0.0;
#include <um/UMMessageHistoryEntry.def.h>
#undef STRING
#undef DATE
#undef REAL
        
    }
    return self;
}

+(NSString *)sqlTableDefForTableName:(NSString *)tableName
{
    UMSynchronizedSortedDictionary *o = [[UMSynchronizedSortedDictionary alloc]init];
    
#define STRING(o,len,tag,dictname,var,accessor,dbname,options)  addFieldDefString(o,len,dbname,options);
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)    addFieldDefDate(o,len,dbname,options);
#define REAL(o,len,tag,dictname,var,accessor,dbname,options)    addFieldDefDouble(o,len,dbname,options);
#include <um/UMMessageHistoryEntry.def.h>
#undef STRING
#undef DATE
#undef REAL

    return fieldDefsToSql(o,tableName);
}

+(NSArray<NSString *>*)dbFieldNames
{
    NSMutableArray *o = [[NSMutableArray alloc]init];
    
#define STRING(o,len,tag,dictname,var,accessor,dbname,options)  [o addObject:@(dbname)];
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)    [o addObject:@(dbname)];
#define REAL(o,len,tag,dictname,var,accessor,dbname,options)    [o addObject:@(dbname)];
#include <um/UMMessageHistoryEntry.def.h>
#undef STRING
#undef DATE
#undef REAL

    return o;
}

- (NSString *)insert:(NSString *)tableName session:(UMDbSession *)session
{
    NSMutableString *o = [[NSMutableString alloc]init];
    [o appendFormat:@"INSERT INTO `%@` (",tableName];
    int i=0;
    
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)    if(1)     { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#include <um/UMMessageHistoryEntry.def.h>
#undef STRING
#undef DATE
#undef REAL

    [o appendString:@") VALUES("];
    i=0;
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field]];};
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
<<<<<<< HEAD
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)    if(1) { if(i++)     { [o appendString:@","]; } [o appendFormat:@"\"%lf\"",field]; };
=======
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)    if(1)     { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%lf\"",field]; };
>>>>>>> 7bf6a4ae5008f715bbcbbc70ce76b4468b7a3841
#include <um/UMMessageHistoryEntry.def.h>
#undef STRING
#undef DATE
#undef REAL

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
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)      if(1)     { dict[@(dictname)] = @(field); }
#include <um/UMMessageHistoryEntry.def.h>
#undef STRING
#undef DATE
#undef REAL

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
    NSString *sd = [NSString stringWithStandardDate:field.dateValue];                   \
    UMASN1UTF8String *u = [[UMASN1UTF8String alloc]initWithString:sd];                  \
    u.asn1_tag.tagNumber = tag;                                                         \
    u.asn1_tag.tagClass = UMASN1Class_ContextSpecific;                                  \
    [_asn1_list addObject:u];                                                           \
}

#define REAL(o,len,tag,dictname,field,accessor,dbname,options)                          \
if(1)                                                                                   \
{                                                                                       \
    UMASN1Real *r = [[UMASN1Real alloc]initWithValue:field];                            \
    r.asn1_tag.tagNumber = tag;                                                         \
    r.asn1_tag.tagClass = UMASN1Class_ContextSpecific;                                  \
    [_asn1_list addObject:r];                                                           \
}

#include <um/UMMessageHistoryEntry.def.h>
#undef STRING
#undef DATE
#undef REAL
}


- (UMMessageHistoryEntry *) processAfterDecodeWithContext:(id)context
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
                    
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)                                  \
case tag:                                                                                       \
{                                                                                               \
    UMASN1Real *r = [[UMASN1Real alloc]initWithASN1Object:o context:context];                   \
    field = r.value;\
}\
break;

#include <um/UMMessageHistoryEntry.def.h>
#undef STRING
#undef DATE
#undef REAL
                default:
                    break;
            }
        }
        o = [self getObjectAtPosition:pos++];
    }
    return self;
}


- (UMMessageHistoryEntry *)initWithArchiveId:(NSString *)archive
                                    instance:(NSString *)instance
                                   messageId:(NSString *)messageId
                                      msisdn:(NSString *)msisdn
                                          ts:(NSDate *)ts
                                       delay:(double)delay
                                        text:(NSString *)text
{
    self = [super init];
    if(self)
    {
        _archiveId          = archive;
        _instance           = instance;
        _messageId          = messageId;
        _msisdn             = msisdn;
        _ts                 = ts;
        _delaySinceStart    = delay;
        _text = text;
    }
    return self;
}


@end


