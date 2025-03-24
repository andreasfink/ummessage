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
#import <um/UMMessageServerCommandError.h>

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
            _handler  = [[UMMessageHandler alloc]initWithSocket:_socket client:self];
            _session = _handler.session;
            [_handler startBackgroundTask];
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

- (NSInteger) login
{
    _loginComplete = NO;
    _loginStatus = UMMessageServerCommandError_UNDEFINED;
    if([_session     doLogin:_username
                    password:_password
                    instance:_instance
      onCompletionCallObject:self
                withSelector:@selector(loginResponse:)]==0)
    {
        

        while(_loginStatus == UMMessageServerCommandError_UNDEFINED)
        {
            usleep(100000);
        }
    }
    return _loginStatus;
}

- (void)loginResponse:(UMMessageServerCommandLoginResponse *)cmd
{
    _loginStatus = cmd.status;
    _loginComplete = YES;
    if(_loginStatus == UMMessageServerCommandError_NO_ERROR)
    {
        [_session startHeartbeat];
    }
}

- (void)close
{
    [_handler shutdownBackgroundTask];
    [_handler.session.socket close];
    _handler.session = NULL;
    _session = NULL;
    _handler = NULL;
}
@end
