//
//  Config_macroCopy.h
//  smpp-multipart-join
//
//  Created by Andreas Fink on 29.01.2025.
//

#define STRING(o,len,tag,dictname,field,accessor,dbname,options)     o.accessor = [field copy];
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)    o.accessor = [field copy];
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       o.accessor = [field copy];
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       o.accessor = [field copy];
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       o.accessor = [field copy];
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)     o.accessor = [field copy];
