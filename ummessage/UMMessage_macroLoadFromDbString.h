//
//  UMMessage_macroLoadFromDbString.h
//  ummessage
//
//  Created by Andreas Fink on 17.11.2025.
//

/* prerequisite:: a NSString fieldName must be set */
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)     if((o) && ([fieldName isEqualToString: @(dbname)])) { self.accessor = [[UMDirtyString alloc]initWithString:o];    }
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)    if((o) && ([fieldName isEqualToString: @(dbname)])) { self.accessor = [[UMDirtyInteger alloc]initWithString:o];   }
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       if((o)  && ([fieldName isEqualToString: @(dbname)])){ self.accessor = [[UMDirtyDate alloc]initWithString:o];      }
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       if((o)  && ([fieldName isEqualToString: @(dbname)])){ self.accessor = [[UMDirtyData alloc]initWithString:o];      }
#define BINARY(o,len,tag,dictname,field,accessor,dbname,options)     { ; }
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       if((o)  && ([fieldName isEqualToString: @(dbname)])){ self.accessor = [[UMDirtyString alloc]initWithString:o];    }
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)       if((o)  && ([fieldName isEqualToString: @(dbname)])){ self.accessor = [[UMDirtyDouble alloc]initWithString:o];    }

