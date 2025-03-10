//
//  UMMessageSession.m
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <um/UMMessageSession.h>
#import <um/UMMessageServer.h>
#import <um/UMMessageHandler.h>
#import <um/UMMessageServerCommandTypes.h>
#import <um/UMMessageServerCommand.h>
#import <um/UMMessageServerCommandError.h>
#import <um/UMMessageServerCommandGenericError.h>
#import <um/UMMessageServerCommandHelloRequest.h>
#import <um/UMMessageServerCommandHelloResponse.h>
#import <um/UMMessageServerCommandLoginRequest.h>
#import <um/UMMessageServerCommandLoginResponse.h>
#import <um/UMMessageServerCommandInsertMessageRequest.h>
#import <um/UMMessageServerCommandInsertMessageResponse.h>
#import <um/UMMessageServerCommandUpdateMessageRequest.h>
#import <um/UMMessageServerCommandUpdateMessageResponse.h>
#import <um/UMMessageServerCommandGetMessageRequest.h>
#import <um/UMMessageServerCommandGetMessageResponse.h>
#import <um/UMMessageServerCommandDeleteMessageRequest.h>
#import <um/UMMessageServerCommandDeleteMessageResponse.h>
#import <um/UMMessage.h>

@implementation UMMessageSession
- (UMMessageSession *)init
{
    self = [super init];
    if(self)
    {
        _lastSequenceNumber = 0;
        _lock = [[UMMutex alloc]initWithName:@"ummessage-session"];
        _handshakeTimer = [[UMTimer alloc]initWithTarget:self
                                                selector:@selector(doHandshake)
                                                  object:NULL
                                                 seconds:10
                                                    name:NULL
                                                 repeats:YES
                                         runInForeground:YES];
        _serverApiVersion = 1;
        _clientApiVersion = 1;
        _serverName = @"umserver";
        _clientName = @"umcli";
        [_handshakeTimer start];
    }
    return self;
}

- (NSInteger)getSequenceNumber
{
    NSInteger i;
    ummutex_lock(_lock);
    i = _lastSequenceNumber+1;
    if(i > 0x7FFF)
    {
        i=1;
    }
    _lastSequenceNumber = i;
    ummutex_unlock(_lock);
    return i;
}

- (void)doHandshake
{
    UMMessageServerCommandHelloRequest *req = [[UMMessageServerCommandHelloRequest alloc]init];
    req.sequenceNumber = [self getSequenceNumber];
    req.apiVersion = 1;
    req.clientName = _clientName;
    [self sendCommand:req];
    _lastHandshakeRequested = [NSDate date];
}

- (int)processGenericError:(UMMessageServerCommandGenericError *)cmd
{
    NSLog(@"GENERIC_ERROR %@",cmd.objectValue);
    return cmd.status;
}

- (int)processHelloRequest:(UMMessageServerCommandHelloRequest *)cmd
{
    _clientName         = cmd.clientName;
    _clientApiVersion   = cmd.apiVersion;
    UMMessageServerCommandHelloResponse *res = [[UMMessageServerCommandHelloResponse alloc]init];
    res.sequenceNumber = cmd.sequenceNumber;
    res.serverName = _serverName;
    res.apiVersion = _serverApiVersion;
    
    UMSocketError err;
    if(_clientApiVersion != _serverApiVersion)
    {
        UMMessageServerCommandGenericError *ge = [[UMMessageServerCommandGenericError alloc]init];
        ge.status = UMMessageServerCommandError_API_VERSION_MISMATCH;
        ge.error = @"API versions are not matching";
        err = [self sendCommand:ge];
        return -1;
    }
    else
    {
        err = [self sendCommand:res];
    }
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}

- (int)processHelloResponse:(UMMessageServerCommandHelloResponse *)cmd
{
    _lastHandshakeReceived = [NSDate date];
    _serverApiVersion = cmd.apiVersion;
    _serverName = cmd.serverName;
    return 0;
}

- (int)processLoginRequest:(UMMessageServerCommandLoginRequest *)cmd
{
    UMMessageServerCommandError error = [self login:cmd.username password:cmd.password instance:cmd.instance];
    
    UMMessageServerCommandLoginResponse *res = [[UMMessageServerCommandLoginResponse alloc]init];
    res.status = error;
    res.sequenceNumber = cmd.sequenceNumber;
    UMSocketError err = [self sendCommand:res];
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}

- (int)processLoginResponse:(UMMessageServerCommandLoginResponse *)cmd
{
    if(cmd.status == UMMessageServerCommandError_NO_ERROR)
    {
        _clientSuccessfullyLoggedIn = YES;
    }
    else
    {
        _clientSuccessfullyLoggedIn = NO;
    }
    return 0;
}

- (int)processInsertMessageRequest:(UMMessageServerCommandInsertMessageRequest *)cmd
{
    UMMessageServerCommandError error = [self insertMessage:cmd.message];
    
    UMMessageServerCommandInsertMessageResponse *res = [[UMMessageServerCommandInsertMessageResponse alloc]init];
    res.status = error;
    res.sequenceNumber = cmd.sequenceNumber;
    UMSocketError err = [self sendCommand:res];
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}
 
- (int)processInsertMessageResponse:(UMMessageServerCommandInsertMessageResponse *)cmd
{
    return 0;
}

- (int)processUpdateMessageRequest:(UMMessageServerCommandUpdateMessageRequest *)cmd
{
    UMMessageServerCommandError error = [self updateMessage:cmd.message];

    UMMessageServerCommandUpdateMessageResponse *res = [[UMMessageServerCommandUpdateMessageResponse alloc]init];
    res.status = error;
    res.sequenceNumber = cmd.sequenceNumber;
    UMSocketError err = [self sendCommand:res];
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}

- (int)processUpdateMessageResponse:(UMMessageServerCommandUpdateMessageResponse *)cmd
{
    return 0;
}

- (int)processGetMessageRequest:(UMMessageServerCommandGetMessageRequest *)cmd
{
    UMMessageServerCommandGetMessageResponse *res = [self getMessage:cmd.messageId];
    res.sequenceNumber = cmd.sequenceNumber;
    UMSocketError err = [self sendCommand:res];
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}

- (int)processGetMessageResponse:(UMMessageServerCommandGetMessageResponse *)cmd
{
    return 0;
}

- (int)processDeleteMessageRequest:(UMMessageServerCommandDeleteMessageRequest *)cmd
{
    UMMessageServerCommandError error = [self deleteMessage:cmd.messageId];

    UMMessageServerCommandDeleteMessageResponse *res = [[UMMessageServerCommandDeleteMessageResponse alloc]init];
    res.status = error;
    res.sequenceNumber = cmd.sequenceNumber;
    UMSocketError err = [self sendCommand:res];
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}

- (int)processDeleteMessageResponse:(UMMessageServerCommandDeleteMessageResponse *)cmd
{
    return 0;
}

- (int)processCommand:(UMMessageServerCommand *)cmd /* return error code*/
{
    UMMessageServerCommandType cid = (UMMessageServerCommandType)cmd.command;
    switch(cid)
    {
        case UMMessageServerCommandType_GENERIC_ERROR_RESPONSE:
        {
            UMMessageServerCommandGenericError *cmd1 = [[UMMessageServerCommandGenericError alloc]initWithASN1Object:cmd context:NULL];
            return [self processGenericError:cmd1];
        }
            break;
        case UMMessageServerCommandType_HELLO_REQUEST:
        {
            UMMessageServerCommandHelloRequest *cmd1 = [[UMMessageServerCommandHelloRequest alloc]initWithASN1Object:cmd context:NULL];
            return [self processHelloRequest:cmd1];

        }
            break;

        case UMMessageServerCommandType_HELLO_RESPONSE:
        {
            UMMessageServerCommandHelloResponse *cmd1 = [[UMMessageServerCommandHelloResponse alloc]initWithASN1Object:cmd context:NULL];
            return [self processHelloResponse:cmd1];

        }
            break;

        case UMMessageServerCommandType_LOGIN_REQUEST:
        {
            UMMessageServerCommandLoginRequest *cmd1 = [[UMMessageServerCommandLoginRequest alloc]initWithASN1Object:cmd context:NULL];
            return [self processLoginRequest:cmd1];

        }
            break;

        case UMMessageServerCommandType_LOGIN_RESPONSE:
        {
            UMMessageServerCommandLoginResponse *cmd1 = [[UMMessageServerCommandLoginResponse alloc]initWithASN1Object:cmd context:NULL];
            return [self processLoginResponse:cmd1];
        }
            break;

        case UMMessageServerCommandType_INSERT_MESSAGE_REQUEST:
        {
            UMMessageServerCommandInsertMessageRequest *cmd1 = [[UMMessageServerCommandInsertMessageRequest alloc]initWithASN1Object:cmd context:NULL];
            return [self processInsertMessageRequest:cmd1];
        }
            break;

        case UMMessageServerCommandType_INSERT_MESSAGE_RESPONSE:
        {
            UMMessageServerCommandInsertMessageResponse *cmd1 = [[UMMessageServerCommandInsertMessageResponse alloc]initWithASN1Object:cmd context:NULL];
            return [self processInsertMessageResponse:cmd1];
        }
            break;

        case UMMessageServerCommandType_UPDATE_MESSAGE_REQUEST:
        {
            UMMessageServerCommandUpdateMessageRequest *cmd1 = [[UMMessageServerCommandUpdateMessageRequest alloc]initWithASN1Object:cmd context:NULL];
            return [self processUpdateMessageRequest:cmd1];
        }
            break;

        case UMMessageServerCommandType_UPDATE_MESSAGE_RESPONSE:
        {
            UMMessageServerCommandUpdateMessageResponse *cmd1 = [[UMMessageServerCommandUpdateMessageResponse alloc]initWithASN1Object:cmd context:NULL];
            return [self processUpdateMessageResponse:cmd1];
        }
            break;
        case UMMessageServerCommandType_GET_MESSAGE_REQUEST:
        {
            UMMessageServerCommandGetMessageRequest *cmd1 = [[UMMessageServerCommandGetMessageRequest alloc]initWithASN1Object:cmd context:NULL];
            return [self processGetMessageRequest:cmd1];

        }
            break;

        case UMMessageServerCommandType_GET_MESSAGE_RESPONSE:
        {
            UMMessageServerCommandGetMessageResponse *cmd1 = [[UMMessageServerCommandGetMessageResponse alloc]initWithASN1Object:cmd context:NULL];
            return [self processGetMessageResponse:cmd1];
        }
            break;

        case UMMessageServerCommandType_DELETE_MESSAGE_REQUEST:
        {
            UMMessageServerCommandDeleteMessageRequest *cmd1 = [[UMMessageServerCommandDeleteMessageRequest alloc]initWithASN1Object:cmd context:NULL];
            return [self processDeleteMessageRequest:cmd1];
        }
            break;

        case UMMessageServerCommandType_DELETE_MESSAGE_RESPONSE:
        {
            UMMessageServerCommandDeleteMessageResponse *cmd1 = [[UMMessageServerCommandDeleteMessageResponse alloc]initWithASN1Object:cmd context:NULL];
            return [self processDeleteMessageResponse:cmd1];

        }
            break;
    }
    return -1;
}

- (UMSocketError)sendCommand:(UMMessageServerCommand *)cmd
{
    NSData *data = [cmd berEncoded];
    UMSocketError err = [_socket sendData:data];
    int count=0;
    while((err==UMSocketError_try_again) && (count++ < 10))
    {
        usleep(100);
        err = [_socket sendData:data];
    }
    return err;
}

- (UMMessageServerCommandError) login:(NSString *)username
      password:(NSString *)password
      instance:(NSString *)instance
{
    if(([username isEqualToString:_username]) &&( [password isEqualToString:_password]))
    {
        _authenticated = YES;
        _instance = instance;
        return UMMessageServerCommandError_NO_ERROR;
    }
    else
    {
        return UMMessageServerCommandError_NOT_AUTHORIZED;
    }
}
- (UMMessageServerCommandError) insertMessage:(UMMessage *)msg
{
    if(!_authenticated)
    {
        return UMMessageServerCommandError_NOT_AUTHORIZED;
    }
    NSString *filename = [self messageIdToFileName:msg.messageId.stringValue];
    NSData *data = [msg berEncoded];
    if([data writeToFile:filename atomically:YES])
    {
        NSLog(@"write to file '%@' failed",filename);
        return UMMessageServerCommandError_WRITE_FAILURE;
    }
    return UMMessageServerCommandError_NO_ERROR;
}

- (UMMessageServerCommandError) updateMessage:(UMMessage *)msg
{
    if(!_authenticated)
    {
        return UMMessageServerCommandError_NOT_AUTHORIZED;
    }
    NSString *filename = [self messageIdToFileName:msg.messageId.stringValue];
    NSData *data = [msg berEncoded];
    if([data writeToFile:filename atomically:YES])
    {
        NSLog(@"write to file '%@' failed",filename);
        return UMMessageServerCommandError_UPDATE_FAILURE;
    }
    return UMMessageServerCommandError_NO_ERROR;
}

- (UMMessageServerCommandError) deleteMessage:(NSString *)messageId
{
    if(!_authenticated)
    {
        return UMMessageServerCommandError_NOT_AUTHORIZED;
    }
    NSString *filename = [self messageIdToFileName:messageId];
    if([[NSFileManager defaultManager]isDeletableFileAtPath:filename] == NO)
    {
        return UMMessageServerCommandError_NOT_FOUND;
        
    }
    NSError *err;
    [[NSFileManager defaultManager] removeItemAtPath:filename
                                                error:&err];
    if(err)
    {
        NSLog(@"delete failed for file '%@'",filename);
        return UMMessageServerCommandError_DELETE_FAILURE;
    }
    return UMMessageServerCommandError_NO_ERROR;
}

- (UMMessageServerCommandGetMessageResponse *) getMessage:(NSString *)messageId
{
    UMMessageServerCommandGetMessageResponse *res = [[UMMessageServerCommandGetMessageResponse alloc]init];
    if(!_authenticated)
    {
        res.status = UMMessageServerCommandError_NOT_AUTHORIZED;
        return res;
    }
    return res;
}

- (NSString *)messageIdToFileName:(NSString *)msgid
{
    if(msgid.length == 18)
    {
        NSString *year          = [msgid substringWithRange:NSMakeRange(0,4)];
        NSString *month         = [msgid substringWithRange:NSMakeRange(4,2)];
        NSString *day           = [msgid substringWithRange:NSMakeRange(6,2)];
        NSString *hour          = [msgid substringWithRange:NSMakeRange(8,2)];
        //NSString *minute_second = [msgid substringWithRange:NSMakeRange(10,4)];
        
        NSString *path = [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@",_rootDirectory,_instance,year,month,day,hour];
        NSString *filename = [NSString stringWithFormat:@"%@/%@",path,msgid];
        
        NSError *err = NULL;
        [[NSFileManager defaultManager]createDirectoryAtPath:path
                                 withIntermediateDirectories:YES
                                                  attributes:NULL
                                                       error:&err];
        if(err)
        {
            NSLog(@"error while creating path %@",path);
            return NULL;
        }
        return filename;
    }
    return NULL;
}

@end
