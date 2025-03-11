//
//  UMMessageClient.m
//  ummessage
//
//  Created by Andreas Fink on 10.03.2025.
//

#import <um/UMMessageClient.h>
#import <um/UMMessageHandler.h>
#import <um/UMMessage.h>

@implementation UMMessageClient

- (UMMessageClient *)initWithHost:(UMHost *)host port:(int)port
{
    self = [super init];
    if(self)
    {
        [host resolve];
        _socket = [[UMSocket alloc]initWithType:UMSOCKET_TYPE_TCP];
        _socket.remoteHost = host;
        _socket.requestedRemotePort = port;
        if([self connect])
        {
            _handler  = [[UMMessageHandler alloc]initWithSocket:_socket client:self];
            [_handler startBackgroundTask];
        }
        else
        {
            return NULL;
        }
    }
    return self;
}

- (BOOL)connect
{
    if(_isConnected==NO)
    {
        UMSocketError err = [_socket connect];
        if(err==UMSocketError_no_error)
        {
            _isConnected = YES;
        }
        else
        {
            NSLog(@"connect failed with error %d (%@)",err,[UMSocket getSocketErrorString:err]);
        }
    }
    return _isConnected;
}

- (BOOL)insertMessage:(UMMessage *)msg
{
    
    return NO;
}

@end
