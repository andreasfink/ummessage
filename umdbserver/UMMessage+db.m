//
//  UMMessage+db.m
//  umdbserver
//
//  Created by Andreas Fink on 21.03.2025.
//

#import <ummessage/UMMessageObject.h>
#import <ulibdb/ulibdb.h>

@implementation UMMessageObject(db)

+ (UMMessageObject *)messageFromDbResult:(UMDbResult *)dbResult
{
    if(dbResult==NULL)
    {
        return NULL;
    }
    if(dbResult.resultArray.count < 1)
    {
        return NULL;
    }
    NSArray *values = dbResult.resultArray[0];
    UMMessageObject *o = [[UMMessageObject alloc]init];
    for(NSInteger i=0;i<dbResult.columNames.count;i++)
    {
        id field1 = values[i];
        if([field1 isKindOfClass:[NSNull class]])
        {
            continue;
        }
        if([field1 isKindOfClass:[NSString class]])
        {
            NSString *str = (NSString *)field1;
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)     if(str) { o.accessor = [[UMDirtyString alloc]initWithString:str]; }
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options)    if(str) { o.accessor = [[UMDirtyInteger alloc]initWithString:str]; }
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       if(str) { o.accessor = [[UMDirtyDate alloc]initWithString:str]; }
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       if(str) { o.accessor = [[UMDirtyData alloc]initWithString:str];  }
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       if(str) { o.accessor = [[UMDirtyString alloc]initWithString:str]; }
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)     if(str) { o.accessor = [[UMDirtyDouble alloc]initWithString:str]; }
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
            continue;
        }
        if([field1 isKindOfClass:[NSData class]])
        {
            NSData *data = (NSData *)field1;
#define STRING(o,len,tag,dictname,f,accessor,dbname,options)         { ; }
#define INTEGER(o,len,tag,dictname,f,accessor,dbname,options)        { ; }
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)       { ; }
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)       if(data) { o.accessor = [[UMDirtyData alloc]initWithData:data];  }
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)       { ; }
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)     { ; }
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
            continue;
        }
    }
    return o;
}

@end
