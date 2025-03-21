//
//  AppDelegate.h
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#import <ulibasn1/ulibasn1.h>
#import <ulibdb/ulibdb.h>
#import <um/um.h>
#import <ulibdb/ulibdb.h>

@class ConfigStorage;
@class Database;

@interface AppDelegate : UMObject<UMMessageSessionAuthenticationDelegate>
{
    UMMessageServer                 *_server;
    BOOL                            _must_quit;
    NSDate                          *_applicationStart;
    UMLogLevel                      _logLevel;
    UMLogHandler                    *_logHandler;
    UMCommandLine                   *_commandLine;
    NSDictionary                    *_enabledOptions;
    UMTimer                         *_housekeepingTimer;
    int                             _port;
    ConfigStorage                   *_config;
    Database                        *_db;
    UMDbPool                        *_dbPool;
}


- (int)main:(int)argc argv:(const char **)argv;

@end


