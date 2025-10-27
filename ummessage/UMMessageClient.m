//
//  UMMessageClient.m
//  ummessage
//
//  Created by Andreas Fink on 10.03.2025.
//

#import <ummessage/UMMessageClient.h>
#import <ummessage/UMMessageHandler.h>
#import <ummessage/UMMessage.h>
#import <ummessage/UMMessageSession.h>
#import <ummessage/UMMessageServerCommandLoginResponse.h>
#import <ummessage/UMMessageServerCommandInsertMessageResponse.h>
#import <ummessage/UMMessageServerCommandGetMessageResponse.h>
#import <ummessage/UMMessageServerCommandError.h>

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

- (UMMessageServerCommandError)insertMessage:(UMMessage *)msg
{
    _callComplete = NO;
    UMMessageServerCommandError e = [_session insertMessage:msg
                                     onCompletionCallObject:self
                                               withSelector:@selector(insertCompletionHandler:)];
    if(e)
    {
        return e;
    }
    while(_callComplete==NO)
    {
        usleep(1000);
    }
    return _callResult;
}

- (void)insertCompletionHandler:(UMMessageServerCommandInsertMessageResponse *)cmd
{
    _callResult = cmd.status;
    _callComplete = YES;
}



- (UMMessage *) getMessage:(NSString *)messageId
                  instance:(NSString *)instance
                     error:(UMMessageServerCommandError *)err
{
    _callComplete = NO;
    UMMessageServerCommandError e = [_session doGetMessage:messageId
                                                  instance:instance
                                    onCompletionCallObject:self
                                              withSelector:@selector(getMessageCompletionHandler:)];
    if(e)
    {
        *err = e;
        return NULL;
    }
    while(_callComplete==NO)
    {
        usleep(1000);
    }
    *err = _callResult;
    return _callResultObject;
}

- (void)getMessageCompletionHandler:(UMMessageServerCommandGetMessageResponse *)cmd
{
    _callResult = cmd.status;
    _callResultObject = cmd.message;
    _callComplete = YES;
}



- (BOOL) awaitsResponses
{
    return [_session awaitsResponses];
}

- (UMMessageServerCommandError) login
{
    _loginComplete = NO;
    _loginStatus = UMMessageServerCommandError_UNDEFINED;
    UMMessageServerCommandError e = [_session     doLogin:_username
                                                 password:_password
                                                 instance:_instance
                                   onCompletionCallObject:self
                                             withSelector:@selector(loginResponse:)];
    if(e)
    {
        return e;
    }
    while(_callComplete==NO)
    {
        usleep(1000);
    }
    return _callResult;
}

- (void)loginResponse:(UMMessageServerCommandLoginResponse *)cmd
{
    _callComplete = YES;
    _callResult = cmd.status;

    _loginComplete = YES;
    _loginStatus = cmd.status;

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
