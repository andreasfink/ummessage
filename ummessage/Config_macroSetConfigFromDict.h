//
//  Config_macroSetDict.h
//  smpp-multipart-join
//
//  Created by Andreas Fink on 23.01.2025.
//

#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options)            { NSNumber *v = setConfigFromDict_BOOLEAN(o,dictname,dbname,tag,options);         if(v) { var=v;}}
#define DOUBLE(o,len,tag,dictname,var,accessor,dbname,options)             { NSNumber *v = setConfigFromDict_DOUBLE(o,dictname,dbname,tag,options);          if(v) { var=v;}}
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options)            { NSNumber *v = setConfigFromDict_INTEGER(o,dictname,dbname,tag,options);         if(v) { var=v;}}
#define STRING(o,len,tag,dictname,var,accessor,dbname,options)             { NSString *v = setConfigFromDict_STRING(o,dictname,dbname,tag,options);          if(v) { var=v;}}
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)               { NSString *v = setConfigFromDict_TEXT(o,dictname,dbname,tag,options);            if(v) { var=v;}}
#define FILTERED_STRING(o,len,tag,dictname,var,accessor,dbname,options)    { NSString *v = setConfigFromDict_FILTERED_STRING(o,dictname,dbname,tag,options); if(v) { var=v;}}
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)               { NSDate   *v = setConfigFromDict_DATE(o,dictname,dbname,tag,options);            if(v) { var=v;}}
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)               { NSData   *v = setConfigFromDict_DATA(o,dictname,dbname,tag,options);            if(v) { var=v;}}
#define ARRAY_COMPACT(o,len,tag,dictname,var,accessor,dbname,options)      { NSArray  *v = setConfigFromDict_ARRAY_COMPACT(o,dictname,dbname,tag,options);   if(v) { var=v;}}
#define ARRAY_VERBOSE(o,len,tag,dictname,var,accessor,dbname,options)      { NSArray  *v = setConfigFromDict_ARRAY_VERBOSE(o,dictname,dbname,tag,options);   if(v) { var=v;}}
#define HEXDATA(o,len,tag,dictname,var,accessor,dbname,options)            { NSData   *v = setConfigFromDict_HEXDATA(o,dictname,dbname,tag,options);         if(v) { var=v;}}

