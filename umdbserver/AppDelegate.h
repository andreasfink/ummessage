//
//  AppDelegate.h
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#import <ulib/ulib.h>
#import <ulib/ulib.h>
#import <ummessage/ummessage.h>
#import <ulib/ulib.h>

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


