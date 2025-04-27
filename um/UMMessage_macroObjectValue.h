//
//  UMMessage_macroObjectValue.h
//  ummessage
//
//  Created by Andreas Fink on 05.03.2025.
//



#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)                               \
if(field)                                                                                       \
{                                                                                               \
    o[@dbname] = field.currentValue;                                                            \
}

#define BOOLEAN(o,len,tag,dictname,field,accessor,dbname,options)                               \
if(field)                                                                                       \
{                                                                                               \
    o[@dbname] = field.currentValue;                                                            \
}

#define REAL(o,len,tag,dictname,field,accessor,dbname,options)                                  \
if(field)                                                                                       \
{                                                                                               \
    o[@dbname] = field;                                                                         \
}

#define STRING(o,len,tag,dictname,field,accessor,dbname,options)                                \
if(field)                                                                                       \
{                                                                                               \
    o[@dbname] = field.currentValue;                                                            \
}

#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)                                  \
if(field)                                                                                       \
{                                                                                               \
    o[@dbname] = field.currentValue;                                                            \
}

#define DATE(o,len,tag,dictname,field,accessor,dbname,options)                                  \
if(field)                                                                                       \
{                                                                                               \
    o[@dbname] = field.currentValue;                                                            \
}

#define DATA(o,len,tag,dictname,field,accessor,dbname,options)                                  \
if(field)                                                                                       \
{                                                                                               \
    o[@dbname] = field.currentValue;                                                            \
}
    
    
