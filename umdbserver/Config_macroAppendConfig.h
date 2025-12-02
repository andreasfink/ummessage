//
//  Config_macroAppendConfig.h
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options)          appendConfig_BOOLEAN(o,dictname,var,dbname,tag,options);
#define REAL(o,len,tag,dictname,var,accessor,dbname,options)             appendConfig_REAL(o,dictname,var,dbname,tag,options);
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options)          appendConfig_INTEGER(o,dictname,var,dbname,tag,options);
#define STRING(o,len,tag,dictname,var,accessor,dbname,options)           appendConfig_STRING(o,dictname,var,dbname,tag,options);
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)             appendConfig_TEXT(o,dictname,var,dbname,tag,options);
#define FILTERED_STRING(o,len,tag,dictname,var,accessor,dbname,options)  appendConfig_FILTERED_STRING(o,dictname,var,dbname,tag,options);
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)             appendConfig_DATE(o,dictname,var,dbname,tag,options);
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)             appendConfig_DATA(o,dictname,var,dbname,tag,options);
#define ARRAY_VERBOSE(o,len,tag,dictname,var,accessor,dbname,options)    appendConfig_ARRAY_VERBOSE(o,dictname,var,dbname,tag,options);
#define ARRAY_COMPACT(o,len,tag,dictname,var,accessor,dbname,options)    appendConfig_ARRAY_COMPACT(o,dictname,var,dbname,tag,options);
#define HEXDATA(o,len,tag,dictname,var,accessor,dbname,options)          appendConfig_HEXDATA(o,dictname,var,dbname,tag,options);

