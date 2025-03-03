//
//  Config_macroDbFieldNames.h
//  smpp-multipart-join
//
//  Created by Andreas Fink on 29.01.2025.
//

#define STRING(o,len,tag,dictname,var,accessor,dbname,options)  [o addObject:@(dbname)];
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options) [o addObject:@(dbname)];
#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options) [o addObject:@(dbname)];
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)    [o addObject:@(dbname)];
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)    [o addObject:@(dbname)];
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)    [o addObject:@(dbname)];
#define DOUBLE(o,len,tag,dictname,var,accessor,dbname,options)  [o addObject:@(dbname)];
