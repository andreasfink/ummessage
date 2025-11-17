//
//  UMMessage_macroSetDirty.h
//  ummessage
//
//  Created by Andreas Fink on 17.11.2025.
//

#define STRING(o,len,tag,dictname,field,accessor,dbname,options)     field.isDirty=dirt;
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       field.isDirty=dirt;
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)    field.isDirty=dirt;
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)       field.isDirty=dirt;
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       field.isDirty=dirt;
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       field.isDirty=dirt;
#define BINARY(o,len,tag,dictname,field,accessor,dbname,options)     field.isDirty=dirt;
