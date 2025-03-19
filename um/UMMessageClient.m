//
//  UMMessageClient.m
//  ummessage
//
//  Created by Andreas Fink on 10.03.2025.
//

#import <um/UMMessageClient.h>
#import <um/UMMessageHandler.h>
#import <um/UMMessage.h>
#import <um/UMMessageSession.h>
#import <um/UMMessageServerCommandLoginResponse.h>

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
            _session = _handler.session;
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

//typedef void (^UMMesssageClientInsertCompletionHandler)(int status,NSString *error)


- (BOOL)insertMessage:(UMMessage *)msg
{
    return [_session insertMessage:msg onCompletionCallObject:self withSelector:@selector(completionHandler:)];
}

- (void)completionHandler:(UMMessageServerCommand *)cmd
{
    NSLog(@"Completion of %@",cmd);
}
- (BOOL) awaitsResponses
{
    return [_session awaitsResponses];
}

- (BOOL) login
{
    _loginComplete = NO;
    if([_session     doLogin:_username
                    password:_password
                    instance:_instance
      onCompletionCallObject:self
                withSelector:@selector(loginResponse:)])
    {
        while(_loginComplete == NO)
        {
            sleep(1);
        }
    }
    return _loginComplete;
}

- (void)loginResponse:(UMMessageServerCommandLoginResponse *)cmd
{
    if(cmd.status == 0)
    {
        _loginComplete = YES;
    }
    else
    {
        _loginComplete = NO;
    }
    [_session startHeartbeat];
    NSLog(@"Login Answer %@",cmd);
}

@end
