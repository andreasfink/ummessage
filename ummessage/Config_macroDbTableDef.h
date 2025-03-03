//
//  Config_macroDbTableDef.h
//  smpp-multipart-join
//
//  Created by Andreas Fink on 29.01.2025.
//

#define STRING(o,len,tag,dictname,var,accessor,dbname,options)  addFieldDefString(o,len,dbname,options);
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options) addFieldDefInteger(o,len,dbname,options);
#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options) addFieldDefInteger(o,len,dbname,options);
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)    addFieldDefDate(o,len,dbname,options);
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)    addFieldDefData(o,len,dbname,options);
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)    addFieldDefText(o,len,dbname,options);
#define DOUBLE(o,len,tag,dictname,var,accessor,dbname,options)  addFieldDefDouble(o,len,dbname,options);
