//
//  AppDelegate.m
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//



#import "AppDelegate.h"
#import "ConfigStorage.h"
#import "ConfigUser.h"
#import "ConfigDatabasePool.h"

#import "Database.h"

#include <sys/resource.h> /* for rlimit */
#include <time.h> /* for time() */

static int _g_signal_sighup;
static int _g_signal_sigint;
static int _g_signal_sigusr1;
static int _g_signal_sigusr2;

static void signalHandler(int signum);
static void signalHandler(int signum)
{
    if (signum == SIGINT)
    {
        _g_signal_sigint++;
    }
    else if (signum == SIGHUP)
    {
        _g_signal_sighup++;
    }
    else if (signum == SIGUSR1)
    {
        _g_signal_sigusr1++;
    }
    else if (signum == SIGUSR2)
    {
        _g_signal_sigusr2++;
    }
}

@implementation AppDelegate

- (AppDelegate *)init
{
    self = [super init];
    if(self)
    {
        _applicationStart               = [NSDate new];
        _logHandler                     = [[UMLogHandler alloc]initWithConsole];
        self.logFeed                    = [[UMLogFeed alloc]initWithHandler:_logHandler section:@"main"];
        self.logFeed.name = @"smpp";
        _logLevel                       = UMLOG_DEBUG;
        _housekeepingTimer              = [[UMTimer alloc]initWithTarget:self
                                                      selector:@selector(housekeeping)
                                                        object:NULL
                                                       seconds:6
                                                          name:@"housekeeping"
                                                       repeats:YES
                                               runInForeground:NO];
        _port=9121;
        [_housekeepingTimer start];
    }
    return self;
}

- (NSString *)productCopyright
{
    return @"© 2025 Andreas Fink";
}

- (NSDictionary *)appDefinition
{
    return @{
        @"version"    : [self productVersion],
        @"executable" : [self productName],
        @"copyright"  : [self productCopyright],
    };
}

- (NSArray *)commandLineSyntax
{
    return @[
        @{
            @"name"  : @"version",
            @"short" : @"-V",
            @"long"  : @"--version",
            @"help"  : @"shows the software version"
        },
        @{
            @"name"  : @"verbose",
            @"short" : @"-v",
            @"long"  : @"--verbose",
            @"help"  : @"enables verbose mode"
        },
        @{
            @"name"  : @"help",
            @"short" : @"-h",
            @"long" : @"--help",
            @"help"  : @"shows the help screen",
        },
        @{
            @"name"  : @"pid-file",
            @"short" : @"",
            @"long"  : @"--pid-file",
            @"argument" : @"filename",
            @"help"  : @"writes the process-id to the indicated file",
        },
        @{
            @"name"  : @"config",
            @"short" : @"-c",
            @"long"  : @"--read-config",
            @"argument" : @"filename",
            @"help"  : @"reads the config from the file",
        },
        @{
            @"name"  : @"port",
            @"short" : @"-p",
            @"long"  : @"--port",
            @"argument" : @"portnumber",
            @"help"  : @"umdbserver tcp port",
        },
    ];
}

- (NSString *)defaultConfigFile
{
    return @"/etc/umdbserver/umdbserver.conf";
}

- (NSString *)defaultLogDirectory
{
    return @"/var/log/umdbserver";
}

- (NSString *)productName
{
    return @"umdbserver";
}

- (NSString *)productVersion
{
    return @"1.0.0";
}

- (void)processCommandLine:(int)argc argv:(const char **)argv
{
    @autoreleasepool
    {
        NSDictionary    *appDefinition = [self appDefinition];
        NSArray         *commandLineDefinition = [self commandLineSyntax];
        
        _commandLine = [[UMCommandLine alloc]initWithCommandLineDefintion:commandLineDefinition
                                                            appDefinition:appDefinition
                                                                     argc:argc
                                                                     argv:argv];
        _config = [[ConfigStorage alloc]initWithCommandLine:_commandLine
                                      defaultConfigFileName:[self defaultConfigFile]];

        NSDictionary *params = _commandLine.params;
        [_commandLine handleStandardArguments];

        if(params[@"asn1"])
        {
            NSString *s = [UMMessage asn1Def];
            fprintf(stdout,"%s\n",s.UTF8String);
            exit(0);
        }
        
        if(params[@"sql"])
        {
            NSString *s = [UMMessage sqlTableDefForTableName:@"msg"];
            fprintf(stdout,"%s\n",s.UTF8String);
            exit(0);
        }
        
        if(params[@"port"])
        {
            id param = params[@"port"];
            if([param isKindOfClass:[NSArray class]])
            {
                NSArray *a = (NSArray *)param;
                if(a.count>0)
                {
                    param = a[0];
                }
            }
            if([param isKindOfClass:[NSString class]])
            {
                NSString *s = (NSString *)param;
                int i = [s intValue];
                if((i>0xFFFF) || (i<1))
                {
                    fprintf(stderr,"port number %d is out of range for tcp ports",i);
                    exit(-1);
                }
                _port = i;
            }
        }
    }
}

- (void)createInstances
{
    _server =  [[UMMessageServer alloc]initWithPort:_port];
    _server.authenticationDelegate = self;
    self.logFeed = [[UMLogFeed alloc]initWithHandler:_logHandler section:@"umdbserver"];
    self.logFeed.name = @"umdbserver";
    for(NSString *key in _config.database_pool_dict)
    {
        ConfigDatabasePool *poolConfig = _config.database_pool_dict[key];
        UMSynchronizedSortedDictionary *config = [poolConfig config];
        NSDictionary *dict = [config dictionaryCopy];
        UMDbPool *pool = [[UMDbPool alloc]initWithConfig:dict logFeed:_logFeed];
        _dbPool = pool;
        
    }
    Database *db = [[Database alloc]init];
    _db = db;
    _server.insertDelegate = _db;
    _server.insertOrUpdateDelegate= _db;
    _server.deleteDelegate= _db;
    _server.loadDelegate = _db;
    [_db setDbPool:_dbPool];
}

- (void)startInstances
{
    [_dbPool startSessions];
    [_db autocreateTables];
    [_server startBackgroundTask];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self createInstances];
    [self startInstances];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [_server shutdownBackgroundTask];
}

- (void)housekeeping
{
}

- (int)main:(int)argc argv:(const char **)argv
{
    [self setupSignalHandlers];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [self processCommandLine:argc argv:argv];

    /* this initializes some stuff for the main run loop on Linux/GNUStep: */
    [NSOperationQueue mainQueue];
    [self applicationDidFinishLaunching:NULL];
    while(_must_quit==NO)
    {
        @autoreleasepool
        {
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
            [self checkSignals];
        }
    }
    return 0;
}

- (void) writePidFile:(NSString *)filename
{
    if(filename)
    {
        long pid = (long)getpid();
        FILE *f = fopen(filename.UTF8String,"w");
        if(f)
        {
            fprintf(f,"%ld",pid);
            fclose(f);
        }
        else
        {
            fprintf(stderr,"Sorry, can not write pid to '%s'",filename.UTF8String);
        }
    }
}


- (void)signal_SIGHUP
{
    NSLog(@"SIGUP received\n");
    NSLog(@"Quitting\n");
    _must_quit=1;
}

- (void)signal_SIGINT
{
    NSLog(@"SIGINT received\n");
}

- (void)signal_SIGUSR1
{
    NSLog(@"SIGUSR1 received\n");
}


-(void)signal_SIGUSR2
{
    NSLog(@"SIGUSR2 received\n");
}

- (void) setupSignalHandlers
{
    struct sigaction act;
    act.sa_handler = signalHandler;
    sigemptyset(&act.sa_mask);
    act.sa_flags = 0;
    sigaction(SIGINT, &act, NULL);
    sigaction(SIGHUP, &act, NULL);
    sigaction(SIGUSR1, &act, NULL);
    sigaction(SIGUSR2, &act, NULL);
}

- (void)checkSignals
{
    if(_g_signal_sighup>0)
    {
        _g_signal_sighup--;
        [self signal_SIGHUP];
        if(_g_signal_sighup>2)
        {
            exit(-1);
        }
    }
    if(_g_signal_sigint>0)
    {
        _g_signal_sigint--;
        [self signal_SIGINT];
    }
    if(_g_signal_sigusr1>0)
    {
        _g_signal_sigusr1--;
        [self signal_SIGUSR1];/* go into Hot mode */
    }
    if(_g_signal_sigusr2>0)
    {
        _g_signal_sigusr2--;
        [self signal_SIGUSR2]; /* go into Standby Mode */
    }
}

- (BOOL)increaseMaximumOpenFiles:(NSUInteger )newMax /* returns true if successful */
{
    NSUInteger currentCount=0;
    
    struct rlimit r;
    getrlimit(RLIMIT_NOFILE, &r);
    fprintf(stderr,"open file limit is  %ld\n", (long)r.rlim_cur);
    currentCount=(unsigned long)r.rlim_cur;
    if(currentCount < newMax)
    {
        r.rlim_cur = newMax;
        if(r.rlim_max < r.rlim_cur)
        {
            r.rlim_max = r.rlim_cur;
        };
        setrlimit(RLIMIT_NOFILE, &r);
        getrlimit(RLIMIT_NOFILE, &r);
        if(r.rlim_cur != newMax)
        {
            return NO;
        }
    }
    return YES;
}

- (UMMessageServerCommandError)login:(NSString *)username
                            password:(NSString *)password
                                host:(NSString *)host
                            instance:(NSString *)instance
{
    NSLog(@"Login(username %@ password %@ host %@ instance %@)",username,password, host,instance);
    ConfigUser *cu = [_config getUser:username];
    if(cu==NULL)
    {
        return UMMessageServerCommandError_NOT_FOUND;
    }
    if(![cu.password isEqualToString:password])
    {
        return UMMessageServerCommandError_NOT_AUTHORIZED;
    }
    return UMMessageServerCommandError_NO_ERROR;
}

@end

