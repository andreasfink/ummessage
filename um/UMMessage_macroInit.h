//
//  UMMessage_macroInit.h
//  ummessage
//
//  Created by Andreas Fink on 24.03.2025.
//

#define STRING(o,len,tag,dictname,var,accessor,dbname,options)            if(strstr(options,"optional")==NULL)   var=[[UMDirtyString alloc]initWithString:@""];
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)              if(strstr(options,"optional")==NULL)   var=[[UMDirtyString alloc]initWithString:@""];
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options)           if(strstr(options,"optional")==NULL)   var=[[UMDirtyInteger alloc]initWithString:@""];
#define REAL(o,len,tag,dictname,var,accessor,dbname,options)              if(strstr(options,"optional")==NULL)   var=[[UMDirtyDouble alloc]initWithString:@""];
#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options)           if(strstr(options,"optional")==NULL)   var=[[UMDirtyBooelan alloc]initWithString:@""];
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)              if(strstr(options,"optional")==NULL)   var=[[UMDirtyDate alloc]initWithString:@""];
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)              if(strstr(options,"optional")==NULL)   var=[[UMDirtyData alloc]initWithString:@""];
#define BINARY(o,len,tag,dictname,var,accessor,dbname,options)            if(strstr(options,"optional")==NULL)   var=[[UMDirtyData alloc]initWithString:@""];

