//
//  Config_macroAppendDict.h
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options)          appendDict_BOOLEAN(o,dictname,var,dbname,tag,options);
#define REAL(o,len,tag,dictname,var,accessor,dbname,options)           appendDict_DOUBLE(o,dictname,var,dbname,tag,options);
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options)          appendDict_INTEGER(o,dictname,var,dbname,tag,options);
#define STRING(o,len,tag,dictname,var,accessor,dbname,options)           appendDict_STRING(o,dictname,var,dbname,tag,options);
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)             appendDict_TEXT(o,dictname,var,dbname,tag,options);
#define FILTERED_STRING(o,len,tag,dictname,var,accessor,dbname,options)  appendDict_FILTERED_STRING(o,dictname,var,dbname,tag,options);
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)             appendDict_DATE(o,dictname,var,dbname,tag,options);
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)             appendDict_DATA(o,dictname,var,dbname,tag,options);
#define ARRAY_VERBOSE(o,len,tag,dictname,var,accessor,dbname,options)    appendDict_ARRAY_VERBOSE(o,dictname,var,dbname,tag,options);
#define ARRAY_COMPACT(o,len,tag,dictname,var,accessor,dbname,options)    appendDict_ARRAY_COMPACT(o,dictname,var,dbname,tag,options);
#define HEXDATA(o,len,tag,dictname,var,accessor,dbname,options)          appendDict_HEXDATA(o,dictname,var,dbname,tag,options);
