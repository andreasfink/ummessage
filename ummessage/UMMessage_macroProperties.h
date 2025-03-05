//
//  Config_macroProperties.h
//  smpp-multipart-join
//
//  Created by Andreas Fink on 28.01.2025.
//

#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options)          @property(readwrite,strong,atomic) UMDirtyBoolean *accessor;
#define DOUBLE(o,len,tag,dictname,var,accessor,dbname,options)           @property(readwrite,strong,atomic) UMDirtyDouble *accessor;
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options)          @property(readwrite,strong,atomic) UMDirtyInteger *accessor;
#define STRING(o,len,tag,dictname,var,accessor,dbname,options)           @property(readwrite,strong,atomic) UMDirtyString *accessor;
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)             @property(readwrite,strong,atomic) UMDirtyDate *accessor;
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)             @property(readwrite,strong,atomic) UMDirtyData *accessor;

