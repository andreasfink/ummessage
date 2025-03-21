//
//  AppDelegate.m
//  umcli
//
//  Created by Andreas Fink on 20.03.2025.
//



#import "AppDelegate.h"
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
        _hostname = @"localhost";
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
            @"name"  : @"port",
            @"short" : @"-p",
            @"long"  : @"--port",
            @"argument" : @"portnumber",
            @"help"  : @"umserver tcp port",
        },
        @{
            @"name"  : @"host",
            @"long"  : @"--host",
            @"argument" : @"hostname",
            @"help"  : @"hostname or address of umserver",
        },
       
        @{
            @"name"  : @"asn1",
            @"long"  : @"--asn1",
            @"help"  : @"prints out ASN1 specification of UMMessage and quits",
        },
        @{
            @"name"  : @"sql",
            @"long"  : @"--sql",
            @"help"  : @"prints out SQL creation statement for a DB table to hold UMMessage and quits",
        },
    ];
}

- (NSString *)defaultConfigFile
{
    return @"/etc/umcli.conf";
}

- (NSString *)defaultLogDirectory
{
    return @"/var/log/umcli";
}

- (NSString *)productName
{
    return @"umcli";
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
        [_commandLine handleStandardArguments];
        NSDictionary *params = _commandLine.params;

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
        if(params[@"host"])
        {
            id param = params[@"host"];
            if([param isKindOfClass:[NSArray class]])
            {
                NSArray *a = (NSArray *)param;
                if(a.count>0)
                {
                    _hostname = (NSString *)a[0];
                }
            }
            if([param isKindOfClass:[NSString class]])
            {
                _hostname = param;
            }
        }
    }
}

- (void)createInstances
{
    
    UMHost *host = [[UMHost alloc]initWithName:_hostname];
    _client = [[UMMessageClient alloc]initWithHost:host port:_port];
    _client.instance = @"default-instance";
    _client.username = @"testuser";
    _client.password = @"testpass";
    self.logFeed = [[UMLogFeed alloc]initWithHandler:_logHandler section:@"umcli"];
    self.logFeed.name = @"umcli";
}

- (void)startInstances
{
    if([_client connect] == NO)
    {
        fprintf(stderr,"Connection failed\n");
        fflush(stderr);
        exit(-1);
    }
    NSInteger e = [_client login];
    if(e != UMMessageServerCommandError_NO_ERROR)
    {
        fprintf(stderr,"Login failed with error %ld\n",e);
        fflush(stderr);
        exit(-1);
    }
 
    
    UMMessage *msg = [[UMMessage alloc]init];
    msg.messageId = [[UMDirtyString alloc]init];
    msg.messageId.stringValue = [UMMessage uniqueMessageIdWithPrefix:@""];
    
    [_client insertMessage:msg];
    
    while([_client awaitsResponses])
    {
        sleep(1);
    }
    fprintf(stderr,"completed\n");
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self createInstances];
    [self startInstances];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [_client close];
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

@end

