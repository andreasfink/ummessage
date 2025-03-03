//
//  Config_macroProcessBeforeEncode.h
//  smpp-multipart-join
//
//  Created by Andreas Fink on 29.01.2025.
//



#define STRING(o,len,tag,dictname,field,accessor,dbname,options)                     \
if(field)                                                                   \
{                                                                           \
    UMASN1UTF8String *u = [[UMASN1UTF8String alloc]initWithString:field];   \
    u.asn1_tag.tagNumber = tag;                                             \
    u.asn1_tag.tagClass = UMASN1Class_ContextSpecific;                      \
    [_asn1_list addObject:u];                                               \
}


#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)                    \
if(field)                                                                   \
{                                                                           \
    UMASN1Integer *i = [[UMASN1Integer alloc]initWithNumber:field];         \
    i.asn1_tag.tagNumber = tag;                                             \
    i.asn1_tag.tagClass = UMASN1Class_ContextSpecific;                      \
    [_asn1_list addObject:i];                                               \
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

#define DATA(o,len,tag,dictname,field,accessor,dbname,options)              \
if(field)                                                                   \
{                                                                           \
    UMASN1OctetString *d = [[UMASN1OctetString alloc]initWithValue:field];  \
    d.asn1_tag.tagNumber = tag;                                             \
    d.asn1_tag.tagClass = UMASN1Class_ContextSpecific;                      \
    [_asn1_list addObject:d];                                               \
}

#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)              \
if(field)                                                                   \
{                                                                           \
    UMASN1UTF8String *u = [[UMASN1UTF8String alloc]initWithString:field];   \
    u.asn1_tag.tagNumber = tag;                                             \
    u.asn1_tag.tagClass = UMASN1Class_ContextSpecific;                      \
    [_asn1_list addObject:u];                                               \
}

#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)            \
if(field)                                                                   \
{                                                                           \
    UMASN1Real *r = [[UMASN1Real alloc]initWithNumber:field];               \
    r.asn1_tag.tagNumber = tag;                                             \
    r.asn1_tag.tagClass = UMASN1Class_ContextSpecific;                      \
    [_asn1_list addObject:r];                                               \
}
