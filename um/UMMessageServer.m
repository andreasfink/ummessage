//
//  UMMessageServer.m
//  ummessage-server
//
//  Created by Andreas Fink on 08.03.2025.
//

#import <um/UMMessageServer.h>
#import <um/UMMessageHandler.h>
#import <um/UMMessageServerCommand.h>
#import <um/UMMessageServerCommandTypes.h>

@implementation UMMessageServer

- (UMMessageServer *)initWithPort:(NSInteger)port
{
    self = [super initWithName:@"UMMessageServer"];
    if(self)
    {
        _port = port;
        _listener = [[UMSocket alloc] initWithType:UMSOCKET_TYPE_TCP];
        _listener.localHost = [[UMHost alloc]initWithLocalhost];
        _listener.localPort = port;
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
            UMMessageHandler *h = [[UMMessageHandler alloc]initWithSocket:newSocket server:self];
            [_incomingConnections addObject:h];
            [h startBackgroundTask];
        }
    }
    return -1;
}


@end
