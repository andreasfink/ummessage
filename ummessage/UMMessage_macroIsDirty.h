//
//  UMMessage_macroIsDirty.h
//  ummessage
//
//  Created by Andreas Fink on 17.11.2025.
//

#define STRING(o,len,tag,dictname,field,accessor,dbname,options)     if(field.isDirty) return YES;
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)    if(field.isDirty) return YES;
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       if(field.isDirty) return YES;
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       if(field.isDirty) return YES;
#define BINARY(o,len,tag,dictname,field,accessor,dbname,options)     if(field.isDirty) return YES;
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       if(field.isDirty) return YES;
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)       if(field.isDirty) return YES;
