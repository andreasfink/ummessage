//
//  UMMessage_macroLoadFromDb.h
//  ummessage
//
//  Created by Andreas Fink on 17.11.2025.
//

#define STRING(o,len,tag,dictname,field,accessor,dbname,options)     if(str) { self.accessor = [[UMDirtyString alloc]initWithString:str];    }
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)    if(str) { self.accessor = [[UMDirtyInteger alloc]initWithString:str];   }
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       if(str) { self.accessor = [[UMDirtyDate alloc]initWithString:str];      }
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       if(str) { self.accessor = [[UMDirtyData alloc]initWithString:str];      }
#define BINARY(o,len,tag,dictname,field,accessor,dbname,options)     { ; }
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       if(str) { self.accessor = [[UMDirtyString alloc]initWithString:str];    }
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)     if(str) { self.accessor = [[UMDirtyDouble alloc]initWithString:str];    }

