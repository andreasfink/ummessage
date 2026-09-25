//
//  AppDelegate.h
//  umcli
//
//  Created by Andreas Fink on 20.03.2025.
//


#import <ulib/ulib.h>
#import <ummessage/ummessage.h>

@interface AppDelegate : UMObject
{
    UMMessageClient                 *_client;
    int                             _port;
    NSString                        *_hostname;
    NSString                        *_instance;
    BOOL                            _must_quit;
    NSDate                          *_applicationStart;
    UMLogLevel                      _logLevel;
    UMLogHandler                    *_logHandler;
    UMCommandLine                   *_commandLine;
    NSDictionary                    *_enabledOptions;
    UMTimer                         *_housekeepingTimer;
}


- (int)main:(int)argc argv:(const char **)argv;

@end


