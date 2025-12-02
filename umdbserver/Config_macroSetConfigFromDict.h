//
//  Config_macroSetDict.h
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options)            { NSNumber *v = setConfigFromDict_BOOLEAN(o,dictname,dbname,tag,options);         if(v) { var=v;}}
#define REAL(o,len,tag,dictname,var,accessor,dbname,options)               { NSNumber *v = setConfigFromDict_REAL(o,dictname,dbname,tag,options);          if(v) { var=v;}}
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options)            { NSNumber *v = setConfigFromDict_INTEGER(o,dictname,dbname,tag,options);         if(v) { var=v;}}
#define STRING(o,len,tag,dictname,var,accessor,dbname,options)             { NSString *v = setConfigFromDict_STRING(o,dictname,dbname,tag,options);          if(v) { var=v;}}
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)               { NSString *v = setConfigFromDict_TEXT(o,dictname,dbname,tag,options);            if(v) { var=v;}}
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)               { NSDate   *v = setConfigFromDict_DATE(o,dictname,dbname,tag,options);            if(v) { var=v;}}
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)               { NSData   *v = setConfigFromDict_DATA(o,dictname,dbname,tag,options);            if(v) { var=v;}}

