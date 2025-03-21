//
//  ConfigDatabasePool.m
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#import "ConfigDatabasePool.h"
#import "ConfigMacroHelper.h"

@implementation ConfigDatabasePool

+ (NSString *)type
{
    return @"database-pool";
}

- (NSString *)type
{
    return [ConfigDatabasePool type];
}


- (ConfigDatabasePool *)initWithConfig:(NSDictionary *)dict
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
#include "ConfigDatabasePool.def.h"
#include "Config_macroClear.h"
}


- (UMSynchronizedSortedDictionary *)config
{
    UMSynchronizedSortedDictionary *o = [super config];
#include "Config_macroAppendDict.h"
#include "ConfigDatabasePool.def.h"
#include "Config_macroClear.h"
    return o;
}

- (void)setConfig:(NSDictionary *)o
{
    [self setSuperConfig:o];
#include "Config_macroSetConfigFromDict.h"
#include "ConfigDatabasePool.def.h"
#include "Config_macroClear.h"
}


- (ConfigDatabasePool *)copyWithZone:(NSZone *)zone
{
    UMSynchronizedSortedDictionary *currentConfig = [self config];
    return [[ConfigDatabasePool allocWithZone:zone]initWithConfig:[currentConfig dictionaryCopy]];
}
@end



