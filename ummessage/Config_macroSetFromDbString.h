//
//  Config_macroSetFromString.h
//  smpp-multipart-join
//
//  Created by Andreas Fink on 29.01.2025.
//


#define STRING(o,tag,len,dictname,var,accessor,dbname,options)     if((o) && ([fieldName isEqualToString:@(dbname)])) { o.accessor = str;                               }
#define INTEGER(o,tag,len,dictname,var,accessor,dbname,options)    if((o) && ([fieldName isEqualToString:@(dbname)])) { o.accessor = @(str.integerValue);               }
#define BOOLEAN(o,tag,len,dictname,var,accessor,dbname,options)    if((o) && ([fieldName isEqualToString:@(dbname)])) { o.accessor = [ConfigObject boolFromString:str]; }
#define TEXT(o,tag,len,dictname,var,accessor,dbname,options)       if((o) && ([fieldName isEqualToString:@(dbname)])) { o.accessor = str;                               }
#define DOUBLE(o,tag,len,dictname,var,accessor,dbname,options)     if((o) && ([fieldName isEqualToString:@(dbname)])) { o.accessor = @(str.doubleValue);                }
#define DATA(o,tag,len,dictname,var,accessor,dbname,options)       ;
