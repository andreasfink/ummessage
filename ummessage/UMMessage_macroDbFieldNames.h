//
//  UMMessage_macroDbFieldNames.h
//  ummessage
//
//  Created by Andreas Fink on 05.03.2025.
//



#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options) [o addObject:@(dbname)];
#define DOUBLE(o,len,tag,dictname,var,accessor,dbname,options)  [o addObject:@(dbname)];
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options) [o addObject:@(dbname)];
#define STRING(o,len,tag,dictname,var,accessor,dbname,options)  [o addObject:@(dbname)];
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)    [o addObject:@(dbname)];
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)    [o addObject:@(dbname)];
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)    [o addObject:@(dbname)];
