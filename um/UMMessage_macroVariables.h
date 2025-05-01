//
//  UMMessage_macroVariables.h
//  ummessage
//
//  Created by Andreas Fink on 05.03.2025.
//


#define STRING(o,len,tag,dictname,var,accessor,dbname,options)            UMDirtyString     *var;
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)              UMDirtyString     *var;
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options)           UMDirtyInteger    *var;
#define REAL(o,len,tag,dictname,var,accessor,dbname,options)              UMDirtyDouble     *var;
#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options)           UMDirtyBoolean    *var;
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)              UMDirtyDate       *var;
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)              UMDirtyData       *var;
#define BINARY(o,len,tag,dictname,var,accessor,dbname,options)            UMDirtyData       *var;

