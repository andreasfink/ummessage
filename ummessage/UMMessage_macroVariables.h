//
//  UMMessage_macroVariables.h
//  ummessage
//
//  Created by Andreas Fink on 05.03.2025.
//



#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options)           UMDirtyBoolean    *var;
#define DOUBLE(o,len,tag,dictname,var,accessor,dbname,options)            UMDirtyDouble     *var;
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options)           UMDirtyInteger    *var;
#define STRING(o,len,tag,dictname,var,accessor,dbname,options)            UMDirtyString     *var;
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)              UMDirtyString     *var;
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)              UMDirtyDate       *var;
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)              UMDirtyData       *var;

