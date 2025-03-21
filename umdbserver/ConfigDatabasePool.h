//
//  ConfigDatabasePool.h
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#import <ulib/ulib.h>

#import "ConfigObject.h"

@interface ConfigDatabasePool : ConfigObject
{
 
#include "Config_macroVariables.h"
#include "ConfigDatabasePool.def.h"
#include "Config_macroClear.h"

}

#include "Config_macroProperties.h"
#include "ConfigDatabasePool.def.h"
#include "Config_macroClear.h"


+ (NSString *)type;
- (NSString *)type;

- (ConfigDatabasePool *)initWithConfig:(NSDictionary *)dict;

@end
