//
//  Config_macroSetFromDbData.h
//  smpp-multipart-join
//
//  Created by Andreas Fink on 29.01.2025.
//

#define BOOLEAN(o,tag,len,dictname,var,accessor,dbname,options)    ;
#define DOUBLE(o,tag,len,dictname,var,accessor,dbname,options)     ;
#define INTEGER(o,tag,len,dictname,var,accessor,dbname,options)    ;
#define STRING(o,tag,len,dictname,var,accessor,dbname,options)     ;
#define DATE(o,tag,len,dictname,var,accessor,dbname,options)       ;
#define DATA(o,tag,len,dictname,var,accessor,dbname,options)       ;
#define DATA(o,tag,len,dictname,var,accessor,dbname,options)       if((o) && ([fieldName isEqualToString:@(dbname)])) { o.accessor = [[UMDirtyData alloc]intiWithData:d]];}
