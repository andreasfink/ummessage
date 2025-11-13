//
//  UMMessage_macroProperties.h
//  ummessage
//
//  Created by Andreas Fink on 05.03.2025.
//

#define STRING(o,len,tag,dictname,var,accessor,dbname,options)           @property(readwrite,strong,atomic) UMDirtyString   *accessor;
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)             @property(readwrite,strong,atomic) UMDirtyString   *accessor;
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options)          @property(readwrite,strong,atomic) UMDirtyInteger  *accessor;
#define REAL(o,len,tag,dictname,var,accessor,dbname,options)             @property(readwrite,strong,atomic) UMDirtyDouble   *accessor;
#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options)          @property(readwrite,strong,atomic) UMDirtyBoolean  *accessor;
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)             @property(readwrite,strong,atomic) UMDirtyDate     *accessor;
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)             @property(readwrite,strong,atomic) UMDirtyData     *accessor;
#define BINARY(o,len,tag,dictname,var,accessor,dbname,options)           @property(readwrite,strong,atomic) UMDirtyData     *accessor;
