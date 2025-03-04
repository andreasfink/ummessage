//
//  Config_macroVariables.h
//  smpp-multipart-join
//
//  Created by Andreas Fink on 28.01.2025.
//

#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options)           UMDirtyBoolean *var;
#define DOUBLE(o,len,tag,dictname,var,accessor,dbname,options)            UMDirtyDouble *var;
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options)           UMDirtyInteger *var;
#define STRING(o,len,tag,dictname,var,accessor,dbname,options)            UMDirtyString *var;
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)              UMDirtyString *var;
#define FILTERED_STRING(o,len,tag,dictname,var,accessor,dbname,options)   UMDirtyString *var;
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)              UMDirtyDate   *var;
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)              UMDirtyData   *var;
#define ARRAY_COMPACT(o,len,tag,dictname,var,accessor,dbname,options)     NSArray<NSString *> *var;
#define ARRAY_VERBOSE(o,len,tag,dictname,var,accessor,dbname,options)     NSArray<NSString *> *var;
#define HEXDATA(o,len,tag,dictname,var,accessor,dbname,options)           NSData *var;

