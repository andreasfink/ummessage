//
//  UMMessageHandler.m
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageHandler.h>
#import <ummessage/UMMessageSession.h>
#import <ummessage/UMMessageServer.h>
#import <ummessage/UMMessageServerCommand.h>

@implementation UMMessageHandler

- (UMMessageHandler *)initWithSocket:(UMSocket *)s server:(UMMessageServer *)server
{
    self = [super initWithName:@"UMMessageHandler"];

    if(self)
    {
        _socket = s;
        _server = server;
        _maxReceiveBuffer = 10485760; /* 10MB */
        _session = [[UMMessageSession alloc]init];
        _session.socket = _socket;
        _session.server = _server;
        _session.directory = _server.directory;
    }
    return self;
}

- (void)backgroundInit
{
}
- (void)backgroundExit
{
    [_socket close];
}

- (int)work
{
    BOOL hasData = YES;
    while(hasData)
    {
        @autoreleasepool
        {
            UMSocketError err =  [_socket receiveToBufferWithBufferLimit:_maxReceiveBuffer];
            if( (err != UMSocketError_has_data) &&
                (err != UMSocketError_has_data_and_hup) &&
                (err != UMSocketError_no_error) &&
                (err != UMSocketError_try_again) )
            {
                NSLog(@"error while reading %@",[UMSocket getSocketErrorString:err]);
                hasData = NO;
                [self shutdownBackgroundTaskFromWithin];
            }
            else
            {
                hasData =YES;
            }
            if(err == UMSocketError_has_data_and_hup)
            {
                [self terminateHandler];
            }
            if(hasData)
            {
                ummutex_lock(_socket.dataLock);
                @try
                {
                    NSUInteger pos = 0;
                    
                    UMASN1Object *o = [[UMASN1Object alloc]initWithBerData:_socket.receiveBuffer atPosition:&pos context:NULL];
                    if(pos > 0)
                    {
                        [_socket deleteFromReceiveBuffer:pos];
                    }
                    if(o)
                    {
                        UMMessageServerCommand *cmd = [[UMMessageServerCommand alloc]initWithASN1Object:o context:NULL];
                        if(cmd)
                        {
                            int err = [_session processCommand:cmd];
                            if(err)
                            {
                                [self terminateHandler];
                            }
                        }
                    }
                }
                @catch(NSException *e)
                {
                    
                }
                ummutex_unlock(_socket.dataLock);
            }
        }
    }
    return 0;
}
- (void) terminateHandler
{
    _session.socket = NULL;
    _session.server = NULL;
    _session = NULL;
    [self shutdownBackgroundTaskFromWithin];
}
@end
