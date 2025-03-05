//
//  UMMessage_macroSetDict.h
//  smpp-multipart-join
//
//  Created by Andreas Fink on 23.01.2025.
//

#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options)            { UMDirtyBoolean *v = setConfigFromDict_BOOLEAN(o,dictname,dbname,tag,options);         if(v) { var=v;}}
#define DOUBLE(o,len,tag,dictname,var,accessor,dbname,options)             { UMDirtyDouble *v = setConfigFromDict_DOUBLE(o,dictname,dbname,tag,options);          if(v) { var=v;}}
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options)            { UMDirtyInteger *v = setConfigFromDict_INTEGER(o,dictname,dbname,tag,options);         if(v) { var=v;}}
#define STRING(o,len,tag,dictname,var,accessor,dbname,options)             { UMDirtyString *v = setConfigFromDict_STRING(o,dictname,dbname,tag,options);          if(v) { var=v;}}
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)               { UMDirtyString *v = setConfigFromDict_TEXT(o,dictname,dbname,tag,options);            if(v) { var=v;}}
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)               { UMDirtyDate   *v = setConfigFromDict_DATE(o,dictname,dbname,tag,options);            if(v) { var=v;}}
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)               { UMDirtyData   *v = setConfigFromDict_DATA(o,dictname,dbname,tag,options);            if(v) { var=v;}}

