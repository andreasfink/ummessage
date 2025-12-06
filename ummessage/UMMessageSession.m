//
//  UMMessageSession.m
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageSession.h>
#import <ummessage/UMMessageServer.h>
#import <ummessage/UMMessageHandler.h>
#import <ummessage/UMMessageServerCommandTypes.h>
#import <ummessage/UMMessageServerCommand.h>
#import <ummessage/UMMessageServerCommandError.h>
#import <ummessage/UMMessageServerCommandGenericError.h>
#import <ummessage/UMMessageServerCommandHeartbeatRequest.h>
#import <ummessage/UMMessageServerCommandHeartbeatResponse.h>
#import <ummessage/UMMessageServerCommandLoginRequest.h>
#import <ummessage/UMMessageServerCommandLoginResponse.h>
#import <ummessage/UMMessageServerCommandInsertMessageRequest.h>
#import <ummessage/UMMessageServerCommandInsertMessageResponse.h>
#import <ummessage/UMMessageServerCommandUpdateMessageRequest.h>
#import <ummessage/UMMessageServerCommandUpdateMessageResponse.h>
#import <ummessage/UMMessageServerCommandGetMessageRequest.h>
#import <ummessage/UMMessageServerCommandGetMessageResponse.h>
#import <ummessage/UMMessageServerCommandDeleteMessageRequest.h>
#import <ummessage/UMMessageServerCommandDeleteMessageResponse.h>
#import <ummessage/UMMessageSessionCompletionObject.h>
#import <ummessage/UMMessageObject.h>

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
        _pendingSequences = [[UMSynchronizedDictionary alloc]init];
        _username = @"testuser";
        _password = @"testpass";
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
    UMMessageServerCommandHeartbeatRequest *req = [[UMMessageServerCommandHeartbeatRequest alloc]init];
    req.sequenceNumber = [self getSequenceNumber];
    [self sendCommand:req];
    _lastHandshakeRequested = [NSDate date];
}

- (int)processGenericError:(UMMessageServerCommandGenericError *)cmd
{
    NSString *s = [NSString stringWithFormat:@"%@",cmd.objectValue];
    fprintf(stderr,"GENERIC_ERROR %s",s.UTF8String);
    return cmd.status;
}

- (int)processHeartbeatRequest:(UMMessageServerCommandHeartbeatRequest *)cmd
{
    UMMessageServerCommandHeartbeatResponse *res = [[UMMessageServerCommandHeartbeatResponse alloc]init];
    res.sequenceNumber = cmd.sequenceNumber;
    UMSocketError err;
    err = [self sendCommand:res];
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}

- (int)processHeartbeatResponse:(UMMessageServerCommandHeartbeatResponse *)cmd
{
    _lastHandshakeReceived = [NSDate date];
    return 0;
}

- (int)processLoginRequest:(UMMessageServerCommandLoginRequest *)cmd
{
    UMMessageServerCommandError error = [_server.authenticationDelegate login:cmd.username
                                                                     password:cmd.password
                                                                         host:_socket.connectedRemoteAddress
                                                                     instance:cmd.instance];
    UMMessageServerCommandLoginResponse *res = [[UMMessageServerCommandLoginResponse alloc]init];
    if(error ==UMMessageServerCommandError_NO_ERROR)
    {
        _authenticated = YES;
        _instance = cmd.instance;
    }
    res.status = error;
    res.sequenceNumber = cmd.sequenceNumber;
    res.apiVersion = _serverApiVersion;
    res.serverName = _serverName;
    UMSocketError err = [self sendCommand:res];
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}

- (int)processLoginResponse:(UMMessageServerCommandLoginResponse *)cmd
{
    NSNumber *seq = @(cmd.sequenceNumber);
    if(cmd.serverName)
    {
        _serverName = cmd.serverName;
    }
    _serverApiVersion = cmd.apiVersion;
    if(cmd.status == UMMessageServerCommandError_NO_ERROR)
    {
        _clientSuccessfullyLoggedIn = YES;
    }
    else
    {
        _clientSuccessfullyLoggedIn = NO;
    }
    
    UMMessageSessionCompletionObject *co =_pendingSequences[seq];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [co.objectToCall performSelector:co.selectorToCall withObject:cmd];
#pragma clang diagnostic pop
    return 0;
}

- (int)processInsertMessageRequest:(UMMessageServerCommandInsertMessageRequest *)cmd
{
    UMMessageServerCommandError error;
    if(_server.insertOrUpdateMessageDelegate)
    {
        error = [_server.insertOrUpdateMessageDelegate insertOrUpdateMessage:cmd.message];
    }
    else
    {
        error = [self localInsertMessage:cmd.message];
    }
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
    NSNumber *seq = @(cmd.sequenceNumber);
    
    UMMessageSessionCompletionObject *co = _pendingSequences[seq];
    if(co)
    {
        [_pendingSequences removeObjectForKey:seq];
        {
            if(co.objectToCall)
            {
                if([co.objectToCall respondsToSelector:co.selectorToCall])
                {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [co.objectToCall performSelector:co.selectorToCall withObject:cmd];
                }
#pragma clang diagnostic pop
            }
        }
    }
    return 0;
}

- (int)processUpdateMessageRequest:(UMMessageServerCommandUpdateMessageRequest *)cmd
{
    UMMessageServerCommandError error;
    if(_server.updateMessageDelegate)
    {
        error = [_server.updateMessageDelegate updateMessage:cmd.message];
    }
    else if (_server.insertOrUpdateMessageDelegate)
    {
        error = [_server.insertOrUpdateMessageDelegate insertOrUpdateMessage:cmd.message];
    }
    else
    {
        error = [self localUpdateMessage:cmd.message];
    }
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
    UMMessageServerCommandGetMessageResponse *res = [[UMMessageServerCommandGetMessageResponse alloc]init];
    if(!_authenticated)
    {
        res.status = UMMessageServerCommandError_NOT_AUTHORIZED;
        res.sequenceNumber = cmd.sequenceNumber;
    }
    else
    {
        UMMessageObject *msg;
        UMMessageServerCommandError err = UMMessageServerCommandError_NO_ERROR;
        if(_server.getMessageDelegate)
        {
            msg = [_server.getMessageDelegate getMessage:cmd.messageId instance:cmd.instance error:&err];
        }
        else
        {
            msg = [self localGetMessage:cmd.messageId instance:cmd.instance error:&err];
        }
        res.status = err;
        if(err==UMMessageServerCommandError_NO_ERROR)
        {
            res.message = msg;
        }
    }
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
    UMMessageServerCommandError error = UMMessageServerCommandError_NO_ERROR;
    if(_server.deleteMessageDelegate)
    {
        error = [_server.deleteMessageDelegate deleteMessage:cmd.messageId];
    }
    else
    {
        error = [self localDeleteMessage:cmd.messageId];
    }
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
        case UMMessageServerCommandType_HEARTBEAT_REQUEST:
        {
            UMMessageServerCommandHeartbeatRequest *cmd1 = [[UMMessageServerCommandHeartbeatRequest alloc]initWithASN1Object:cmd context:NULL];
            return [self processHeartbeatRequest:cmd1];
            
        }
            break;
            
        case UMMessageServerCommandType_HEARTBEAT_RESPONSE:
        {
            UMMessageServerCommandHeartbeatResponse *cmd1 = [[UMMessageServerCommandHeartbeatResponse alloc]initWithASN1Object:cmd context:NULL];
            return [self processHeartbeatResponse:cmd1];
            
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
            int i =  [self processInsertMessageRequest:cmd1];
            return i;
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
        default:
        {
            UMMessageServerCommandGenericError *cmd1 = [[UMMessageServerCommandGenericError alloc]initWithASN1Object:cmd context:NULL];
            cmd1.status = UMMessageServerCommandError_UNSUPPORTED_COMMAND;
            cmd1.error = @"Unknown command";
            [self sendCommand:cmd1];
            return -1;
        }
    }
    return 0;
}

- (UMSocketError)sendCommand:(UMMessageServerCommand *)cmd
{
    if(_server)
    {
        NSLog(@"Server Sending %@",cmd.objectValue.jsonString);
    }
    if(_client)
    {
        NSLog(@"Client Sending %@",cmd.objectValue.jsonString);
    }
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


- (UMMessageServerCommandError) localInsertMessage:(UMMessageObject *)msg
{
    if(!_authenticated)
    {
        return UMMessageServerCommandError_NOT_AUTHORIZED;
    }
    NSString *filename = [self messageIdToFileName:msg.messageId.stringValue];
    NSString *filename1 = [NSString stringWithFormat:@"%@.json",filename];
    NSString *filename2 = [NSString stringWithFormat:@"%@.ber",filename];
    NSString *s = [[msg objectValue]jsonString];
    NSData *data = [msg berEncoded];
    NSError *err1=NULL;
    NSError *err2=NULL;

    [s writeToFile:filename1 atomically:YES encoding:NSUTF8StringEncoding  error:&err1];
    if(err1)
    {
        NSLog(@"write to file '%@' failed.\n%@\n",filename1,err1);
    }
    [data writeToFile:filename2 options:NSDataWritingAtomic error:&err2];
    if(err2)
    {
        NSLog(@"write to file '%@' failed.\n%@\n",filename2,err2);
        return UMMessageServerCommandError_WRITE_FAILURE;
    }
    return UMMessageServerCommandError_NO_ERROR;
}

- (UMMessageServerCommandError) localUpdateMessage:(UMMessageObject *)msg
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

- (UMMessageServerCommandError) localDeleteMessage:(NSString *)messageId
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


- (UMMessageServerCommandError) doGetMessage:(NSString *)messageId
                                    instance:(NSString *)instance
                      onCompletionCallObject:(id)obj
                                withSelector:(SEL)sel
{
    if((obj) && (sel))
    {
        if(![obj respondsToSelector:sel])
        {
            UMAssert(0,@"Object does not respond to selector");
        }
    }
    NSInteger seq = [self getSequenceNumber];
    
    UMMessageSessionCompletionObject *co = [[UMMessageSessionCompletionObject alloc]init];
    co.objectToCall = obj;
    co.selectorToCall = sel;

    UMMessageServerCommandGetMessageRequest *req = [[UMMessageServerCommandGetMessageRequest alloc]init];
    req.sequenceNumber = seq;
    req.messageId = messageId;
    req.instance = instance;
    _pendingSequences[@(seq)] = co;
    UMSocketError err = [self sendCommand:req];
    if(err != UMSocketError_no_error)
    {
        [_pendingSequences removeObjectForKey:@(seq)];
        return UMMessageServerCommandError_INVALID_STATE;
    }
    return UMMessageServerCommandError_NO_ERROR;
}

- (UMMessageObject *)localGetMessage:(NSString *)messageId instance:(NSString *)instance error:(UMMessageServerCommandError *)e
{
    if(!_authenticated)
    {
        *e = UMMessageServerCommandError_NOT_AUTHORIZED;
        return NULL;
    }
    
    NSString *filename = [self messageIdToFileName:messageId instance:instance];
    NSString *filename2 = [NSString stringWithFormat:@"%@.ber",filename];

    NSData *data = [NSData dataWithContentsOfFile:filename];
    if(data)
    {
        UMMessageObject *msg;
        @try
        {
            msg = [[UMMessageObject alloc]initWithBerData:data];
        }
        @catch(NSException *ex)
        {
            NSLog(@"exception while loading %@: %@",filename2,ex);
        }
        if(msg)
        {
            *e = UMMessageServerCommandError_NO_ERROR;
            return msg;
        }
    }
    *e = UMMessageServerCommandError_LOAD_FAILURE;
    return NULL;
}

- (NSString *)messageIdToFileName:(NSString *)msgid
{
    return [self messageIdToFileName:(NSString *)msgid instance:_instance];
}

- (NSString *)messageIdToFileName:(NSString *)msgid instance:(NSString *)instance
{
    if(msgid.length == 18)
    {
        NSString *year          = [msgid substringWithRange:NSMakeRange(0,4)];
        NSString *month         = [msgid substringWithRange:NSMakeRange(4,2)];
        NSString *day           = [msgid substringWithRange:NSMakeRange(6,2)];
        NSString *hour          = [msgid substringWithRange:NSMakeRange(8,2)];
        NSString *min           = [msgid substringWithRange:NSMakeRange(10,2)];
        NSString *sec           = [msgid substringWithRange:NSMakeRange(12,2)];
        NSString *micro         = [msgid substringWithRange:NSMakeRange(14,4)];
        NSString *hour_tenmin   = [msgid substringWithRange:NSMakeRange(8,3)];

        NSString *path = [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@",_rootDirectory,instance,year,month,day,hour_tenmin];
        NSString *filename = [NSString stringWithFormat:@"%@/%@-%@-%@_%@:%@:%@.%@",path,year,month,day,hour,min,sec,micro];
        
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

- (UMMessageServerCommandError)insertMessage:(UMMessageObject *)msg
                      onCompletionCallObject:(id)obj
                                withSelector:(SEL)sel
{
    NSInteger seq = [self getSequenceNumber];
    
    UMMessageSessionCompletionObject *co = [[UMMessageSessionCompletionObject alloc]init];
    co.objectToCall = obj;
    co.selectorToCall = sel;
    
    UMMessageServerCommandInsertMessageRequest *req = [[UMMessageServerCommandInsertMessageRequest alloc]init];
    req.sequenceNumber = seq;
    req.message = msg;
    _pendingSequences[@(seq)] = co;
    UMSocketError err = [self sendCommand:req];
    if(err != UMSocketError_no_error)
    {
        [_pendingSequences removeObjectForKey:@(seq)];
        return UMMessageServerCommandError_INVALID_STATE;
    }
    return UMMessageServerCommandError_NO_ERROR;
}

- (BOOL) awaitsResponses
{
    if(_pendingSequences.count > 0)
    {
        return YES;
    }
    return NO;
}


- (UMMessageServerCommandError) doLogin:(NSString *)username
                               password:(NSString *)password
                               instance:(NSString *)instance
                 onCompletionCallObject:(id)obj
                           withSelector:(SEL)sel
{
    if((obj) && (sel))
    {
        if(![obj respondsToSelector:sel])
        {
            UMAssert(0,@"Object does not respond to selector");
        }
    }
    NSInteger seq = [self getSequenceNumber];
    
    UMMessageSessionCompletionObject *co = [[UMMessageSessionCompletionObject alloc]init];
    co.objectToCall = obj;
    co.selectorToCall = sel;
    
    UMMessageServerCommandLoginRequest *req = [[UMMessageServerCommandLoginRequest alloc]init];
    req.sequenceNumber = seq;
    req.username = username;
    req.password = password;
    req.instance = instance;
    req.apiVersion = 1;
    _pendingSequences[@(seq)] = co;
    UMSocketError err = [self sendCommand:req];
    if(err != UMSocketError_no_error)
    {
        [_pendingSequences removeObjectForKey:@(seq)];
        return UMMessageServerCommandError_INVALID_STATE;
    }
    return UMMessageServerCommandError_NO_ERROR;
}

- (void)startHeartbeat
{
    [_handshakeTimer start];
}

- (void)stopHeartbeat
{
    [_handshakeTimer stop];
}

@end
