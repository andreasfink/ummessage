//
//  Config_macroDbTableDef.h
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#define STRING(o,len,tag,dictname,var,accessor,dbname,options)  ummessage_addFieldDefString(o,len,dbname,options);
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options) ummessage_addFieldDefInteger(o,len,dbname,options);
#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options) ummessage_addFieldDefInteger(o,len,dbname,options);
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)    ummessage_addFieldDefDate(o,len,dbname,options);
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)    ummessage_addFieldDefData(o,len,dbname,options);
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)    ummessage_addFieldDefText(o,len,dbname,options);
#define REAL(o,len,tag,dictname,var,accessor,dbname,options)  ummessage_addFieldDefDouble(o,len,dbname,options);
