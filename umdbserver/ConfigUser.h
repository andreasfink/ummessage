//
//  ConfigUser.h
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#import "ConfigObject.h"
#import "Database.h"

@class UMDbResult;
@interface ConfigUser : ConfigObject
{
 
#include "Config_macroVariables.h"
#include "ConfigUser.def.h"
#include "Config_macroClear.h"

}

#include "Config_macroProperties.h"
#include "ConfigUser.def.h"
#include "Config_macroClear.h"

+ (NSString *)type;
- (NSString *)type;
- (ConfigUser *)initWithConfig:(NSDictionary *)dict;


+(NSArray<ConfigUser *>*) configsFromDbResult:(UMDbResult *)result;
+(NSString *)sqlTableDefForTableName:(NSString *)tableName;
+(NSArray<NSString *>*)dbFieldNames;

@end
