//
//  Config_macroObjectValue.h
//  smpp-multipart-join
//
//  Created by Andreas Fink on 29.01.2025.
//

#define STRING(o,len,tag,dictname,field,accessor,dbname,options)                                \
if(field)                                                                                       \
{                                                                                               \
    o[@dbname] = field;                                                                         \
}
    
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)                               \
if(field)                                                                                       \
{                                                                                               \
    o[@dbname] = field;                                                                         \
}

    
    
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)                                  \
if(field)                                                                                       \
{                                                                                               \
    o[@dbname] = field;                                                                         \
}

    
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)                                  \
if(field)                                                                                       \
{                                                                                               \
    o[@dbname] = field;                                                                         \
}
    
    
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)                                  \
if(field)                                                                                       \
{                                                                                               \
    o[@dbname] = field;                                                                         \
}

#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)                                \
if(field)                                                                                       \
{                                                                                               \
    o[@dbname] = field;                                                                         \
}
