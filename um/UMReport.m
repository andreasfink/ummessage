//
//  UMReport.m
//  um
//
//  Created by Andreas Fink on 26.03.2025.
//

#import "UMReport.h"
#import <ulibdb/ulibdb.h>

@implementation UMReport

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

#include "UMReport.def.h"
#include "Config_macroClear.h"

    
    [o appendString:@") VALUES("];
    i=0;
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]];};
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#include "UMReport.def.h"
#include "Config_macroClear.h"


    [o appendString:@") ON DUPLICATE KEY UPDATE "];
    i=0;
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#include "UMReport.def.h"
#include "Config_macroClear.h"
    return o;
}
   
+ (UMReport *)reportFromDbResult:(UMDbResult *)dbResult
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
    UMReport *o = [[UMReport alloc]init];
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
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)     if(str) { o.accessor = str;                 }
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)    if(str) { o.accessor = @(str.integerValue); }
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       if(str) { o.accessor = str.dateValue;       }
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       if(str) { o.accessor = str.unhexedData;     }
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       if(str) { o.accessor = str;                 }
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)     if(str) { o.accessor = @(str.doubleValue);  }
#include "UMReport.def.h"
#include "Config_macroClear.h"
            continue;
        }
        if([field1 isKindOfClass:[NSData class]])
        {
            NSData *data = (NSData *)field1;
            NSLog(@"data=%@",data);

#define STRING(o,len,tag,dictname,f,accessor,dbname,options)         { ; }
#define INTEGER(o,len,tag,dictname,f,accessor,dbname,options)        { ; }
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       { ; }
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       if(data) { o.accessor = data; }
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       { ; }
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)     { ; }
#include "UMReport.def.h"
#include "Config_macroClear.h"
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
#include "Config_macroProcessBeforeEncode.h"
#include "UMReport.def.h"
#include "Config_macroClear.h"
}


- (UMReport *) processAfterDecodeWithContext:(id)context
{
    int p=0;
    UMASN1Object *o = [self getObjectAtPosition:p++];
    
    while(o)
    {
        if(o.asn1_tag.tagClass == UMASN1Class_ContextSpecific)
        {
            switch(o.asn1_tag.tagNumber)
            {
#include "Config_macroProcessAfterDecodeWithContext.h"
#include "UMReport.def.h"
#include "Config_macroClear.h"
            } /* end switch */
            o = [self getObjectAtPosition:p++];
        }
    }
    return self;
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *o = [[UMSynchronizedSortedDictionary alloc]init];
#include "Config_macroObjectValue.h"
#include "UMReport.def.h"
#include "Config_macroClear.h"
    return o;
}

- (NSString *)description
{
    return [[self objectValue]jsonString];
}

@end
