//
//  UMMessage_macroSetFromString.h
//  ummessage
//
//  Created by Andreas Fink on 05.03.2025.
//


#define BOOLEAN(o,tag,len,dictname,var,accessor,dbname,options)    if((o) && ([fieldName isEqualToString:@(dbname)])) { o.accessor = [[UMDirtyBoolean alloc]initWithString:str]]; }
#define DOUBLE(o,tag,len,dictname,var,accessor,dbname,options)     if((o) && ([fieldName isEqualToString:@(dbname)])) { o.accessor = [[UMDirtyDouble  alloc]initWithString:str]]; }
#define INTEGER(o,tag,len,dictname,var,accessor,dbname,options)    if((o) && ([fieldName isEqualToString:@(dbname)])) { o.accessor = [[UMDirtyInteger alloc]initWithString:str]]; }
#define STRING(o,tag,len,dictname,var,accessor,dbname,options)     if((o) && ([fieldName isEqualToString:@(dbname)])) { o.accessor = [[UMDirtyStrig   alloc]initWithString:str]]; }
#define DATE(o,tag,len,dictname,var,accessor,dbname,options)       if((o) && ([fieldName isEqualToString:@(dbname)])) { o.accessor = [[UMDirtyDate    alloc]initWithString:str]]; }
/* binary data objects are set with UMMessage_macroSetFromDbData instead but if its stored as hex string, thats where it goes */
#define DATA(o,tag,len,dictname,var,accessor,dbname,options)       if((o) && ([fieldName isEqualToString:@(dbname)])) { o.accessor = [[UMDirtyData    alloc]initWithString:str]]; }

