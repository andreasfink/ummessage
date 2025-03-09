//
//  UMMessageServer.m
//  ummessage-server
//
//  Created by Andreas Fink on 08.03.2025.
//

#import "UMMessageServer.h"
#import "UMMessageHandler.h"

@implementation UMMessageServer

- (UMMessageServer *)initWithPort:(NSInteger)port
{
    self = [super init];
    if(self)
    {
        _port = port;
        _listener = [[UMSocket alloc] initWithType:UMSOCKET_TYPE_TCP];
        _listener.localHost = [[UMHost alloc]initWithLocalhost];
    }
    return self;
}

- (void)backgroundInit
{
    UMSocketError err = [_listener bind];
    if(err)
    {
        NSLog(@"bind() failed with err=%@",[UMSocket getSocketErrorString:err]);
        return;
    }
    err = [_listener listen:128];
    if(err)
    {
        NSLog(@"listen() failed with err=%@",[UMSocket getSocketErrorString:err]);
        return;
    }
}
- (void)backgroundExit
{
    [_listener close];
}

- (int)work
{
    @autoreleasepool
    {
        UMSocketError err = UMSocketError_no_error;
        UMSocket *newSocket = [_listener accept:&err];
        if((err!= UMSocketError_no_error) && (err!=UMSocketError_has_data) && (err!=UMSocketError_has_data_and_hup))
        {
            NSLog(@"accept() failed with err=%@",[UMSocket getSocketErrorString:err]);
        }
        if(newSocket)
        {
            UMMessageHandler *h = [[UMMessageHandler alloc]initWithSocket:newSocket];
            [_incomingConnections addObject:h];
            [h startBackgroundTask];
        }
    }
    return -1;
}

- (void)processCommand:(UMMessageServerCommand *)md
            fromSocket:(UMSocket *)s
{
    
}

@end
