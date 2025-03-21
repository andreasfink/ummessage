//
//  ConfigGeneral.m
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#import "ConfigGeneral.h"
#import "ConfigMacroHelper.h"

@implementation ConfigGeneral

+ (NSString *)type
{
    return @"general";
}

- (NSString *)type
{
    return [ConfigGeneral type];
}

- (ConfigGeneral *)initWithConfig:(NSDictionary *)dict
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
#include "ConfigGeneral.def.h"
#include "Config_macroClear.h"
}

- (UMSynchronizedSortedDictionary *)config
{
    UMSynchronizedSortedDictionary *o = [super config];
    
#include "Config_macroAppendDict.h"
#include "ConfigGeneral.def.h"
#include "Config_macroClear.h"
    return o;
}

- (void)setConfig:(NSDictionary *)o
{
    
#include "Config_macroSetConfigFromDict.h"
#include "ConfigGeneral.def.h"
#include "Config_macroClear.h"
}

- (ConfigGeneral *)copyWithZone:(NSZone *)zone
{
    UMSynchronizedSortedDictionary *currentConfig = [self config];
    return [[ConfigGeneral allocWithZone:zone]initWithConfig:[currentConfig dictionaryCopy]];
}

- (BOOL)canHaveNoName
{
    return YES;
}


@end

