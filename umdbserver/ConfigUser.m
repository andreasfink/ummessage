//
//  ConfigUser.m
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#import "ConfigUser.h"
#import "ConfigMacroHelper.h"
#import <ulibdb/ulibdb.h>
#import "Database.h"

@implementation ConfigUser

+ (NSString *)type
{
    return @"user";
}

- (NSString *)type
{
    return [ConfigUser type];
}

- (ConfigUser *)initWithConfig:(NSDictionary *)dict
{
    self = [super initWithConfig:dict];
    if(self)
    {
        [self setConfig:dict];
    }
    return self;
}

- (void)appendConfigToString:(NSMutableString *)o
{
    [super appendConfigToString:o];
#include "Config_macroAppendConfig.h"
#include "ConfigUser.def.h"
#include <um/UMMessage_macroClear.h>
}

- (UMSynchronizedSortedDictionary *)config
{
    UMSynchronizedSortedDictionary *o = [super config];
#include "Config_macroAppendDict.h"
#include "ConfigUser.def.h"
#include <um/UMMessage_macroClear.h>
    return o;
}

- (void)setConfig:(NSDictionary *)o
{
    [super setSuperConfig:o];
#include "Config_macroSetConfigFromDict.h"
#include "ConfigUser.def.h"
#include "ConfigUser.def.h"
#include <um/UMMessage_macroClear.h>
}

- (ConfigUser *)copyWithZone:(NSZone *)zone
{
    UMSynchronizedSortedDictionary *currentConfig = [self config];
    return [[ConfigUser allocWithZone:zone]initWithConfig:[currentConfig dictionaryCopy]];
}

+(NSArray<ConfigUser *>*) configsFromDbResult:(UMDbResult *)dbResult
{
    if(dbResult==NULL)
    {
        return NULL;
    }
    if(dbResult.resultArray.count < 1)
    {
        return NULL;
    }
    
    NSMutableArray<ConfigUser *>* arr = [[NSMutableArray alloc]init];
    for(NSInteger j=0;j<dbResult.resultArray.count;j++ )
    {
        NSArray *values = dbResult.resultArray[j];
        ConfigUser *o = [[ConfigUser alloc]init];
        for(NSInteger i=0;i<dbResult.columNames.count;i++)
        {
            id v = values[i];
            NSString *fieldName     = dbResult.columNames[i];
            if([v isKindOfClass:[NSData class]])
            {
                NSData *d = (NSData *)v;
#pragma unused(d)
#include "Config_macroSetFromDbData.h"
#include "ConfigObject.def.h"
#include "ConfigUser.def.h"
#include <um/UMMessage_macroClear.h>
            }
            else if([v isKindOfClass:[NSString class]])
            {
                NSString  *str = (NSString  *)v;
#include "Config_macroSetFromDbString.h"
#include "ConfigObject.def.h"
#include "ConfigUser.def.h"
#include <um/UMMessage_macroClear.h>
            }
        }
        [arr addObject:o];
    }
    return arr;
}


+(NSString *)sqlTableDefForTableName:(NSString *)tableName
{
    UMSynchronizedSortedDictionary *o = [[UMSynchronizedSortedDictionary alloc]init];

#include "Config_macroDbTableDef.h"
#include "ConfigObject.def.h"
#include "ConfigUser.def.h"
#include "Config_macroClear.h"
        return fieldDefsToSql(o,tableName);
}
   
+(NSArray<NSString *>*)dbFieldNames
{
    NSMutableArray *o = [[NSMutableArray alloc]init];
#include "Config_macroDbFieldNames.h"
#include "ConfigObject.def.h"
#include "ConfigUser.def.h"
#include "Config_macroClear.h"
    return o;
}

@end

