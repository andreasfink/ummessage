//
//  UMMessage_macroClearDirty.h
//  ummessage
//
//  Created by Andreas Fink on 17.11.2025.
//
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)     [field clearDirty];
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       [field clearDirty];
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)    [field clearDirty];
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)       [field clearDirty];
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       [field clearDirty];
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       [field clearDirty];
#define BINARY(o,len,tag,dictname,field,accessor,dbname,options)     [field clearDirty];
