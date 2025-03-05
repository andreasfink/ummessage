//
//  Config_macroProcessAfterDecodeWithContext.h
//  smpp-multipart-join
//
//  Created by Andreas Fink on 29.01.2025.
//

#define STRING(o,len,tag,dictname,field,accessor,dbname,options)                                \
case tag:                                                                                       \
{                                                                                               \
    UMASN1UTF8String *u = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];       \
    field = u.stringValue;                                                                      \
}

#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)                               \
case tag:                                                                                       \
{                                                                                               \
    UMASN1Integer *i = [[UMASN1Integer alloc]initWithASN1Object:o context:context];             \
    field = i.number;                                                                           \
}

#define DATE(o,len,tag,dictname,field,accessor,dbname,options)                                   \
case tag:                                                                                       \
{                                                                                               \
    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];       \
    field = s.value.dateValue;                                                                  \
}


#define DATA(o,len,tag,dictname,field,accessor,dbname,options)                                  \
case tag:                                                                                       \
{                                                                                               \
    UMASN1OctetString *d = [[UMASN1OctetString alloc]initWithASN1Object:o context:context];     \
    field = d.value;                                                                            \
}


#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)                                  \
case tag:                                                                                       \
{                                                                                               \
    UMASN1UTF8String *u = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];       \
    field = u.stringValue;                                                                      \
}

#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)                                \
case tag:                                                                                       \
{                                                                                               \
    UMASN1Real *r = [[UMASN1Real alloc]initWithASN1Object:o context:context];                   \
    field = r.number;                                                                           \
}
