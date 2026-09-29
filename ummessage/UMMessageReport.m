//
//  UMMessageReport *.m
//  um
//
//  Created by Andreas Fink on 26.03.2025.
//

#import "UMMessageReport.h"
#import <ulib/ulib.h>

@implementation UMMessageReport

- (NSString *)insertOrUpdate:(NSString *)tableName session:(UMDbSession *)session
{
    NSMutableString *o = [[NSMutableString alloc]init];
    [o appendFormat:@"INSERT INTO `%@` (",tableName];
    int i=0;

#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };

#include "UMMessageReport.def.h"
#include "UMMessage_macroClear.h"

    
    [o appendString:@") VALUES("];
    i=0;
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]];};
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#include "UMMessageReport.def.h"
#include "UMMessage_macroClear.h"


    [o appendString:@") ON DUPLICATE KEY UPDATE "];
    i=0;
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#include "UMMessageReport.def.h"
#include "UMMessage_macroClear.h"

    return o;
}
   
+ (UMMessageReport *)reportFromDbResult:(UMDbResult *)dbResult
{
    if(dbResult==NULL)
    {
        return NULL;
    }
    if(dbResult.resultArray.count < 1)
    {
        return NULL;
    }
    NSArray *values = dbResult.resultArray[0];
    UMMessageReport *o = [[UMMessageReport alloc]init];
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
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)    if(str) { o.accessor = @(str.integerValue); }
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)     if(str) { o.accessor = str;                 }
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       if(str) { o.accessor = str;                 }
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       if(str) { o.accessor = str.dateValue;       }
#include "UMMessageReport.def.h"
#include "UMMessage_macroClear.h"
            continue;
        }
        if([field1 isKindOfClass:[NSData class]])
        {
            NSData *data = (NSData *)field1;
            NSLog(@"data=%@",data);

#define INTEGER(o,len,tag,dictname,f,accessor,dbname,options)        { ; }
#define STRING(o,len,tag,dictname,f,accessor,dbname,options)         { ; }
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       { ; }
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       { ; }
#include "UMMessageReport.def.h"
#include "UMMessage_macroClear.h"
            continue;
        }
    }
    return o;
}


#pragma mark -
#pragma mark ASN1 functions


- (void) processBeforeEncode
{
    [super processBeforeEncode];
    [_asn1_tag setTagIsConstructed];
    _asn1_list = [[NSMutableArray alloc]init];

    
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)           \
if(field)                                                                   \
{                                                                           \
    UMASN1Integer *i = [[UMASN1Integer alloc]initWithNumber:field];         \
    i.asn1_tag.tagNumber = tag;                                             \
    i.asn1_tag.tagClass = UMASN1Class_ContextSpecific;                      \
    [_asn1_list addObject:i];                                               \
}


#define STRING(o,len,tag,dictname,field,accessor,dbname,options)            \
if(field)                                                                   \
{                                                                           \
    UMASN1UTF8String *u = [[UMASN1UTF8String alloc]initWithString:field];   \
    u.asn1_tag.tagNumber = tag;                                             \
    u.asn1_tag.tagClass = UMASN1Class_ContextSpecific;                      \
    [_asn1_list addObject:u];                                               \
}

#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)              \
if(field)                                                                   \
{                                                                           \
    UMASN1UTF8String *u = [[UMASN1UTF8String alloc]initWithString:field];   \
    u.asn1_tag.tagNumber = tag;                                             \
    u.asn1_tag.tagClass = UMASN1Class_ContextSpecific;                      \
    [_asn1_list addObject:u];                                               \
}
    
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)              \
if(field)                                                                   \
{                                                                           \
    NSString *sd = [NSString stringWithStandardDate:field];                 \
    UMASN1UTF8String *u = [[UMASN1UTF8String alloc]initWithString:sd];      \
    u.asn1_tag.tagNumber = tag;                                             \
    u.asn1_tag.tagClass = UMASN1Class_ContextSpecific;                      \
    [_asn1_list addObject:u];                                               \
}

#include "UMMessageReport.def.h"
#include "UMMessage_macroClear.h"
}


- (UMMessageReport *) processAfterDecodeWithContext:(id)context
{
    int p=0;
    UMASN1Object *o = [self getObjectAtPosition:p++];
    
    while(o)
    {
        if(o.asn1_tag.tagClass == UMASN1Class_ContextSpecific)
        {
            switch(o.asn1_tag.tagNumber)
            {
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)                               \
case tag:                                                                                       \
{                                                                                               \
    UMASN1Integer *i = [[UMASN1Integer alloc]initWithASN1Object:o context:context];             \
    field = i.number;                                                                           \
}

#define STRING(o,len,tag,dictname,field,accessor,dbname,options)                                \
case tag:                                                                                       \
{                                                                                               \
    UMASN1UTF8String *u = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];       \
    field = u.stringValue;                                                                      \
}

#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)                                  \
case tag:                                                                                       \
{                                                                                               \
    UMASN1UTF8String *u = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];       \
    field = u.stringValue;                                                                      \
}

#define DATE(o,len,tag,dictname,field,accessor,dbname,options)                                  \
case tag:                                                                                       \
{                                                                                               \
    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];       \
    field = s.value.dateValue;                                                                  \
}
#include "UMMessageReport.def.h"
#include "UMMessage_macroClear.h"
            } /* end switch */
            o = [self getObjectAtPosition:p++];
        }
    }
    return self;
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *o = [[UMSynchronizedSortedDictionary alloc]init];
    
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)   if(field) { o[@dbname] = field;  }
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { o[@dbname] = field;  }
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)      if(field) { o[@dbname] = field;  }
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)      if(field) { o[@dbname] = field;  }

#include "UMMessageReport.def.h"
#include "UMMessage_macroClear.h"
    return o;
}

- (NSString *)description
{
    return [[self objectValue]jsonString];
}

@end
