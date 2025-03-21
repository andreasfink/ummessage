//
//  ConfigStorage.h
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#import <ulib/ulib.h>

@class ConfigGeneral;
@class ConfigUser;

@interface ConfigStorage : UMObject
{
    NSArray                         *_commandLineArguments;
    UMCommandLine                   *_commandLine;
    UMSynchronizedSortedDictionary  *_database_pool_dict;
    UMSynchronizedSortedDictionary  *_users_dict;
    ConfigGeneral                   *_generalConfig;
}

@property(readwrite,strong,atomic)  UMSynchronizedSortedDictionary  *database_pool_dict;
@property(readwrite,strong,atomic)  UMSynchronizedSortedDictionary  *users_dict;

@property(readwrite,strong,atomic)  ConfigGeneral                   *generalConfig;

- (ConfigStorage *)initWithCommandLine:(UMCommandLine *)cmd;
- (ConfigStorage *)initWithCommandLine:(UMCommandLine *)cmd defaultConfigFileName:(NSString *)defaultCfgFile;


- (ConfigUser *)getUser:(NSString *)name;


@end
