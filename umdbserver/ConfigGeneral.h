//
//  ConfigGeneral.h
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#import "ConfigObject.h"

@interface ConfigGeneral : ConfigObject
{
    
#include "Config_macroVariables.h"
#include "ConfigGeneral.def.h"
#include "Config_macroClear.h"
    
}

#include "Config_macroProperties.h"
#include "ConfigGeneral.def.h"
#include "Config_macroClear.h"

+ (NSString *)type;
- (NSString *)type;
- (ConfigGeneral *)initWithConfig:(NSDictionary *)dict;

@end

