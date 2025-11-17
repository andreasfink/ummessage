//
//  UMMessage_macroLoadFromDbBinary.h
//  ummessage
//
//  Created by Andreas Fink on 17.11.2025.
//

#define STRING(o,len,tag,dictname,f,accessor,dbname,options)         { ; }
#define INTEGER(o,len,tag,dictname,f,accessor,dbname,options)        { ; }
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       { ; }
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       { ; }
#define BINARY(o,len,tag,dictname,field,accessor,dbname,options)     if(o) { self.accessor  = [[UMDirtyData alloc]initWithData:o];      }
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       { ; }
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)     { ; }
