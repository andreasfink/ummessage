//
//  Config_macroSetFromDbData.h
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#define STRING(o,tag,len,dictname,var,accessor,dbname,options)     ;
#define INTEGER(o,tag,len,dictname,var,accessor,dbname,options)    ;
#define BOOLEAN(o,tag,len,dictname,var,accessor,dbname,options)    ;
#define TEXT(o,tag,len,dictname,var,accessor,dbname,options)       ;
#define REAL(o,tag,len,dictname,var,accessor,dbname,options)     ;
#define DATA(o,tag,len,dictname,var,accessor,dbname,options)       if((o) && ([fieldName isEqualToString:@(dbname)])) { o.accessor = d;}
