//
//  ConfigStorage.m
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#import "ConfigStorage.h"

#import "ConfigDatabasePool.h"
#import "ConfigGeneral.h"
#import "ConfigUser.h"

@implementation ConfigStorage


- (ConfigStorage *)initWithCommandLine:(UMCommandLine *)cmd
{
    return [self initWithCommandLine:cmd defaultConfigFileName:@"/etc/smpp/smpp.conf"];
}

- (ConfigStorage *)initWithCommandLine:(UMCommandLine *)cmd defaultConfigFileName:(NSString *)defaultCfgFile
{
    self = [super init];
    if(self)
    {
        [self generalInitialisation];
        _commandLine = cmd;
        NSArray *configFiles = _commandLine.params[@"config"];
        if(configFiles.count ==0)
        {
            configFiles = @[ defaultCfgFile ];
        }
        for(NSString *configFile in configFiles)
        {
            [self loadFromFile:configFile];
        }
    }
    return self;
}

- (void)generalInitialisation
{
    _database_pool_dict     = [[UMSynchronizedSortedDictionary alloc]init];
}

- (void)loadFromFile:(NSString *)filename
{
    UMConfig* cfg = [[UMConfig alloc]initWithFileName:filename];
    [cfg allowSingleGroup:[ConfigGeneral type]];
    [cfg allowMultiGroup:[ConfigUser type]];
    [cfg allowSingleGroup:[ConfigDatabasePool type]];
    [cfg read];
    [self processConfig:cfg];
}

- (void)processConfig:(UMConfig *)cfg
{
    /* as we can read multiple config files, the general options could be further
     enhanced in a second file. Database based configs are loaded in a second step  */
    NSDictionary *general_config = [cfg getSingleGroup:[ConfigGeneral type]];
    if(general_config==NULL)
    {
        general_config = @{@"group" : @"general",
                           @"name"  : @"general",
                           @"hostname" : @"localhost",
                           @"log-level": @(3),
                           @"log-rotations" : @(5),
                           @"log-file": @"main.log",
                           @"log-directory": @".",
                           @"concurrent-tasks" : @(8),
                           };
    }
    if(_generalConfig==NULL)
    {
        _generalConfig = [[ConfigGeneral alloc]initWithConfig:general_config];
    }
    else
    {
        [_generalConfig setConfig:general_config];
    }

    NSDictionary *database_pool_config = [cfg getSingleGroup:[ConfigDatabasePool type]];
    ConfigDatabasePool *e = [[ConfigDatabasePool alloc]initWithConfig:database_pool_config];
    if(e.name.length  > 0)
    {
        _database_pool_dict[e.name] = e;
    }
}


/*----------------------------------------------------------------*/
- (ConfigUser *)getUser:(NSString *)name
{
    return _users_dict[name];
}


@end
