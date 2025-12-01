//
//  UMMessage_macroSetIsDirty.h
//  ummessage
//
//  Created by Andreas Fink on 17.11.2025.
//

#define STRING(o,len,tag,dictname,field,accessor,dbname,options)     field.isDirty=o;
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       field.isDirty=o;
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)    field.isDirty=o;
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)       field.isDirty=o;
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       field.isDirty=o;
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       field.isDirty=o;
#define BINARY(o,len,tag,dictname,field,accessor,dbname,options)     field.isDirty=o;
