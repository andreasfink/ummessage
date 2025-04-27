//
//  UMMessage_macroProcessAfterDecodeWithContext.h
//  ummessage
//
//  Created by Andreas Fink on 05.03.2025.
//


#define STRING(o,len,tag,dictname,field,accessor,dbname,options)                                \
case tag:                                                                                       \
{                                                                                               \
    UMASN1UTF8String *u = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];       \
    field = [[UMDirtyString alloc]initWithString:u.stringValue];                                \
}\
break;

#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)                                  \
case tag:                                                                                       \
{                                                                                               \
    UMASN1UTF8String *u = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];       \
    field = [[UMDirtyString alloc]initWithString:u.stringValue];                                \
}\
break;

#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)                               \
case tag:                                                                                       \
{                                                                                               \
    UMASN1Integer *i = [[UMASN1Integer alloc]initWithASN1Object:o context:context];             \
    field = [[UMDirtyInteger alloc]initWithNumber:i.number];                                    \
}\
break;

#define BOOLEAN(o,len,tag,dictname,field,accessor,dbname,options)                               \
case tag:                                                                                       \
{                                                                                               \
    UMASN1Integer *i = [[UMASN1Integer alloc]initWithASN1Object:o context:context];             \
    field = [[UMDirtyBoolean alloc]initWithNumber:i.number];                                    \
}

#define REAL(o,len,tag,dictname,field,accessor,dbname,options)                                \
case tag:                                                                                       \
{                                                                                               \
    UMASN1Real *r = [[UMASN1Real alloc]initWithASN1Object:o context:context];                   \
    field = [[UMDirtyDouble alloc]initWithNumber:r.number];                                     \
}\
break;

#define DATE(o,len,tag,dictname,field,accessor,dbname,options)                                  \
case tag:                                                                                       \
{                                                                                               \
    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];       \
    field = [[UMDirtyDate alloc]initWithDate:s.value.dateValue];                                \
}\
break;


#define DATA(o,len,tag,dictname,field,accessor,dbname,options)                                  \
case tag:                                                                                       \
{                                                                                               \
    UMASN1OctetString *d = [[UMASN1OctetString alloc]initWithASN1Object:o context:context];     \
    field = [[UMDirtyData alloc]initWithData:d.value];                                          \
}\
break;


