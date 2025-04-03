//
//  UMMessage.m
//  ummessage
//
//  Created by Andreas Fink on 03.03.2025.
//  Copyright 2025 Andreas Fink, Paradieshofstrasse 101, 4054 Basel andreas@fink.org
//

#import "UMMessage.h"
#import <ulib/ulib.h>
#import <ulibdb/ulibdb.h>
#import <um/UMMessageFields.h>
#import <um/UMMessageUdh.h>
#import <um/UMMessageUdhConcatenated.h>
#import <um/UMMessageUdhConcatenated16BitRef.h>
#import "UMMessage_macroHelper.h"

#define     MAXADDRLEN      18

static      struct tm    last_msgid_time_trec;
static      int          last_msgid_serial = 0;
static      UMMutex      *g_messageIdLock = NULL;

@implementation UMMessage

- (UMMessage *)init
{
    self = [super init];
    if(self)
    {
#include <um/UMMessage_macroInit.h>
#include <um/UMMessage.def.h>
#include <um/UMMessage_macroClear.h>
    }
    return self;
}


- (UMMessage *)initWithNewIdAndInstance:(NSString *)instance
{
    self = [self init];
    if(self)
    {
        _instance.stringValue = instance;
        _messageId.stringValue = [UMMessage uniqueMessageIdWithPrefix:@""];
        
    }
    return self;
}

+ (NSString *)uniqueMessageId
{
    return [UMMessage uniqueMessageIdWithPrefix:@""];
}

+ (NSString *)uniqueMessageIdWithPrefix:(NSString *)prefix
{
    int           this_msgid_serial;
    time_t        this_msgid_time_t;
    struct tm     this_msgid_time_trec;
    
    if(g_messageIdLock==NULL)
    {
        g_messageIdLock = [[UMMutex alloc]initWithName:@"messageIdLock"];
    }
    ummutex_lock(g_messageIdLock);
    time(&this_msgid_time_t);
    gmtime_r(&this_msgid_time_t, &this_msgid_time_trec);
    
    this_msgid_time_trec.tm_mon++;
    if(      (this_msgid_time_trec.tm_year  == last_msgid_time_trec.tm_year)
       &&    (this_msgid_time_trec.tm_mon   == last_msgid_time_trec.tm_mon)
       &&    (this_msgid_time_trec.tm_mday  == last_msgid_time_trec.tm_mday)
       &&    (this_msgid_time_trec.tm_hour  == last_msgid_time_trec.tm_hour)
       &&    (this_msgid_time_trec.tm_min   == last_msgid_time_trec.tm_min)
       &&    (this_msgid_time_trec.tm_sec   == last_msgid_time_trec.tm_sec))
    {
        last_msgid_serial = last_msgid_serial + 1;
        if(last_msgid_serial > 9990)
        {
            usleep(1.1);
        }
        this_msgid_serial = last_msgid_serial;
    }
    else
    {
        this_msgid_serial = last_msgid_serial = 1;
    }
    NSString *s = [NSString stringWithFormat:@"%@%04d%02d%02d%02d%02d%02d%04d",
                   prefix,
                   this_msgid_time_trec.tm_year+1900 - 2000,
                   this_msgid_time_trec.tm_mon,
                   this_msgid_time_trec.tm_mday,
                   this_msgid_time_trec.tm_hour,
                   this_msgid_time_trec.tm_min,
                   this_msgid_time_trec.tm_sec,
                   this_msgid_serial];
    last_msgid_time_trec    = this_msgid_time_trec;
    last_msgid_serial       = this_msgid_serial;
    ummutex_unlock(g_messageIdLock);
    return s;
}



+(NSString *)sqlTableDefForTableName:(NSString *)tableName
{
    UMSynchronizedSortedDictionary *o = [[UMSynchronizedSortedDictionary alloc]init];
    
#include "UMMessage_macroDbTableDef.h"
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
    return fieldDefsToSql(o,tableName);
}

+(NSArray<NSString *>*)dbFieldNames
{
    NSMutableArray *o = [[NSMutableArray alloc]init];
#include "UMMessage_macroDbFieldNames.h"
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
    return o;
}

- (NSString *)insert:(NSString *)tableName session:(UMDbSession *)session
{
    NSMutableString *o = [[NSMutableString alloc]init];
    [o appendFormat:@"INSERT INTO `%@` (",tableName];
    int i=0;
    
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
    
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
    
    
    [o appendString:@") VALUES("];
    i=0;
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]];};
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
    
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
    
    [o appendString:@")"];
    return o;
}

- (NSString *)update:(NSString *)tableName session:(UMDbSession *)session
{
    NSMutableString *o = [[NSMutableString alloc]init];
    [o appendFormat:@"UPDATE `%@` SET ",tableName];
    int i=0;
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
    [o appendFormat:@"WHERE archive_id=`%@` ",[session sqlEscapeString:_archiveId.stringValue]];
    return o;
}

- (NSString *)updateIfDirty:(NSString *)tableName session:(UMDbSession *)session
{
    NSMutableString *o = [[NSMutableString alloc]init];
    [o appendFormat:@"UPDATE `%@` SET ",tableName];
    int i=0;
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field.isDirty) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) if(field.isDirty) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field.isDirty) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)    if(field.isDirty) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    if(field.isDirty) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)  if(field.isDirty) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
    [o appendFormat:@"WHERE archive_id=`%@` ",[session sqlEscapeString:_archiveId.stringValue]];
    return o;
}


- (NSString *)delete:(NSString *)tableName session:(UMDbSession *)session
{
    return [NSString stringWithFormat:@"DELETE FROM `%@` WHERE archive_id=`%@` ",tableName,[session sqlEscapeString:_archiveId.stringValue]];
}


- (NSString *)insertOrUpdate:(NSString *)tableName session:(UMDbSession *)session
{
    NSMutableString *o = [[NSMutableString alloc]init];
    [o appendFormat:@"INSERT INTO `%@` (",tableName];
    int i=0;
    
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
    
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
    
    
    [o appendString:@") VALUES("];
    i=0;
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]];};
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
    
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
    
    
    [o appendString:@") ON DUPLICATE KEY UPDATE "];
    i=0;
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
    return o;
}

+ (void)asn1DefAppendString:(NSMutableString *)o
                        len:(NSInteger)len
                        tag:(NSInteger)tag
                   dictname:(const char *)dictname
                    options:(const char *)options
                       type:(const char *)type
{
    NSMutableString *s = [[NSMutableString alloc]init];
    [s appendFormat:@"    %s",dictname];
    while(s.length < 34)
    {
        [s appendString:@" "];
    }
    [s appendFormat:@"[%ld] %s,\n",tag,type];
    [o appendFormat:@"%@",s];
}

+ (NSString *)asn1Def
{
    NSMutableString *o = [[NSMutableString alloc]init];
    [o appendFormat:@"UMMessage ::= SEQUENCE\n{\n"];
    
#define STRING(o,len1,tag1,dictname1,field1,accessor1,dbname1,options1) \
[UMMessage asn1DefAppendString:o len:len1 \
tag:tag1 \
dictname:dictname1 \
options:options1 \
type:"UTF8String"];
    
#define INTEGER(o,len1,tag1,dictname1,field1,accessor1,dbname1,options1) \
[UMMessage asn1DefAppendString:o len:len1 \
tag:tag1 \
dictname:dictname1 \
options:options1 \
type:"INTEGER"];
    
#define DATE(o,len1,tag1,dictname1,field1,accessor1,dbname1,options1) \
[UMMessage asn1DefAppendString:o len:len1 \
tag:tag1 \
dictname:dictname1 \
options:options1 \
type:"UTF8String"];
#define DATA(o,len1,tag1,dictname1,field1,accessor1,dbname1,options1) \
[UMMessage asn1DefAppendString:o len:len1 \
tag:tag1 \
dictname:dictname1 \
options:options1 \
type:"OCTETSTRING"];
    
#define TEXT(o,len1,tag1,dictname1,field1,accessor1,dbname1,options1) \
[UMMessage asn1DefAppendString:o len:len1 \
tag:tag1 \
dictname:dictname1 \
options:options1 \
type:"UTF8String"];
    
#define DOUBLE(o,len1,tag1,dictname1,field1,accessor1,dbname1,options1) \
[UMMessage asn1DefAppendString:o len:len1 \
tag:tag1 \
dictname:dictname1 \
options:options1 \
type:"REAL"];
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
    
    /* remove the last , before the \n */
    NSInteger n = [o length];
    o = [[o substringWithRange:NSMakeRange(0,n-2)] mutableCopy];
    [o appendString:@"\n}\n"];
    return o;
}



+ (UMMessage *)messageFromDbResult:(UMDbResult *)dbResult
{
    UMMessage *o = [[UMMessage alloc]init];
    [o loadFromDbResult:dbResult];
    return o;
}

- (void)loadFromDbResult:(UMDbResult *)dbResult
{
    if(dbResult==NULL)
    {
        return;
    }
    if(dbResult.resultArray.count < 1)
    {
        return;
    }
    NSArray *values = dbResult.resultArray[0];
    for(NSInteger i=0;i<dbResult.columNames.count;i++)
    {
        id field1 = values[i];
        if([field1 isKindOfClass:[NSNull class]])
        {
            continue;
        }
        if([field1 isKindOfClass:[NSString class]])
        {
            NSString *str = (NSString *)field1;
            NSLog(@"str=%@",str);
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)     if(str) { self.accessor = [[UMDirtyString alloc]initWithString:str];    }
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)    if(str) { self.accessor = [[UMDirtyInteger alloc]initWithString:str];   }
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       if(str) { self.accessor = [[UMDirtyDate alloc]initWithString:str];      }
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       if(str) { self.accessor = [[UMDirtyData alloc]initWithString:str];      }
#define BINARY(o,len,tag,dictname,field,accessor,dbname,options)     { ; }
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       if(str) { self.accessor = [[UMDirtyString alloc]initWithString:str];    }
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)     if(str) { self.accessor = [[UMDirtyDouble alloc]initWithString:str];    }
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
            continue;
        }
        if([field1 isKindOfClass:[NSData class]])
        {
            NSData *data = (NSData *)field1;
            NSLog(@"data=%@",data);
            
#define STRING(o,len,tag,dictname,f,accessor,dbname,options)         { ; }
#define INTEGER(o,len,tag,dictname,f,accessor,dbname,options)        { ; }
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       { ; }
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       { ; }
#define BINARY(o,len,tag,dictname,field,accessor,dbname,options)     if(data) { self.accessor  = [[UMDirtyData alloc]initWithData:data];      }
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       { ; }
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)     { ; }
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
            continue;
        }
    }
    return;
}

- (NSString *)description
{
    return [[self objectValue]jsonString];
}

- (UMSynchronizedSortedDictionary *) objectValue
{
    UMSynchronizedSortedDictionary *dict = [[UMSynchronizedSortedDictionary alloc]init];
    
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { dict[@(dictname)] = field.stringValue; }
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)   if(field) { dict[@(dictname)] = field.number; }
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)      if(field) { dict[@(dictname)] = field.stringValue; }
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)      if(field) { dict[@(dictname)] = field.stringValue; }
#define BINARY(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { dict[@(dictname)] = field.stringValue; }
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)      if(field) { dict[@(dictname)] = field.stringValue; }
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { dict[@(dictname)] = field.number; }
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
    return dict;
}

- (void) processBeforeEncode
{
    [super processBeforeEncode];
#include "UMMessage_macroProcessBeforeEncode.h"
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
}


- (UMMessage *) processAfterDecodeWithContext:(id)context
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
#include "UMMessage_macroProcessAfterDecodeWithContext.h"
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
                    break;
            }
        }
        o = [self getObjectAtPosition:pos++];
    }
    return self;
}

- (BOOL)isDirty
{
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)     if(field.isDirty) return YES;
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)    if(field.isDirty) return YES;
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       if(field.isDirty) return YES;
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       if(field.isDirty) return YES;
#define BINARY(o,len,tag,dictname,field,accessor,dbname,options)     if(field.isDirty) return YES;
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       if(field.isDirty) return YES;
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)     if(field.isDirty) return YES;
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
    return NO;
}
- (void)setIsDirty:(BOOL) dirt
{
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)     field.isDirty=dirt;
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)    field.isDirty=dirt;
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       field.isDirty=dirt;
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       field.isDirty=dirt;
#define BINARY(o,len,tag,dictname,field,accessor,dbname,options)     field.isDirty=dirt;
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       field.isDirty=dirt;
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)     field.isDirty=dirt;
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
}

- (void)clearDirty
{
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)     [field clearDirty];
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)    [field clearDirty];
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       [field clearDirty];
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       [field clearDirty];
#define BINARY(o,len,tag,dictname,field,accessor,dbname,options)     [field clearDirty];
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       [field clearDirty];
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)     [field clearDirty];
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"
}

- (void) expandUdh
{
    if(_pduUdh==NULL)
    {
        return;
    }
    /* position 0 is the length of the UDH data. */
    int pos = 1;
    _udhs = [[UMSynchronizedArray alloc]init];
    NSData *d = _pduUdh.data;
    UMMessageUdh *u = [[UMMessageUdh alloc] initWithData:d atPosition:&pos];
    while(u)
    {
        if(u.iei==UdhIEI_concatenated)
        {
            u = [[UMMessageUdhConcatenated alloc]initWithUdh:u];
        }
        else if(u.iei==UdhIEI_concatenated16bitRef)
        {
            u = [[UMMessageUdhConcatenated16BitRef alloc]initWithUdh:u];
        }
        [_udhs addObject:u];
        u = [[UMMessageUdh alloc] initWithData:d atPosition:&pos];
    }
}

- (void) packUdh
{
    NSMutableData *d = [[NSMutableData alloc]init];
    
    for(UMMessageUdh *u in _udhs)
    {
        [d appendData:u.encode];
    }
    if(d.length == 0)
    {
        _pduUdh=NULL;
        _pduUdhIndicator=[[UMDirtyInteger alloc]initWithInteger:0];
    }
    else
    {
        NSMutableData *udh = [[NSMutableData alloc]init];
        [udh appendByte:d.length];
        [udh appendData:d];
        _pduUdh = [[UMDirtyData alloc]initWithData:udh];
        _pduUdhIndicator=[[UMDirtyInteger alloc]initWithInteger:1];
        
    }
}


- (void)setMessageStateCode:(UMMessageState)ms
{
    _messageStatus = [[UMDirtyString alloc]initWithString:stringFromMessageState(ms)];
}

- (UMMessageState)messageStateCode
{
    return messageStateFromString(_messageStatus.stringValue);
    
}

- (int)uid
{
    if(_userName)
    {
        return atoi(_userName.stringValue.UTF8String);
    }
    return 0;
}

- (void)setUid:(int)uid
{
    NSString *s = [NSString stringWithFormat:@"%d",uid];
    _userName = UMDIRTY_STRING(s);
}

- (int)gid
{
    if(_groupName)
    {
        return atoi(_groupName.stringValue.UTF8String);
    }
    return 0;
}

- (void)setGid:(int)gid
{
    NSString *s = [NSString stringWithFormat:@"%d",gid];
    _groupName = UMDIRTY_STRING(s);
}


@end


