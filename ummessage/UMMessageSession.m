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
#import <ummessage/UMMessageServerCommandHelloRequest.h>
#import <ummessage/UMMessageServerCommandHelloResponse.h>
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

@implementation UMMessageSession

- (int)processGenericError:(UMMessageServerCommandGenericError *)cmd
{
    NSLog(@"GENERIC_ERROR %@",cmd.objectValue);
    return cmd.status;
}

- (int)processHelloRequest:(UMMessageServerCommandHelloRequest *)cmd
{
    UMMessageServerCommandHelloResponse *res = [[UMMessageServerCommandHelloResponse alloc]init];
    res.sequenceNumber = cmd.sequenceNumber;
    UMSocketError err = [self sendCommand:res];
    if(err != UMSocketError_no_error)
    {
        return -1;
    }
    return 0;
}

- (int)processHelloResponse:(UMMessageServerCommandHelloResponse *)cmd
{
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
    return UMMessageServerCommandError_NO_ERROR;
}

- (UMMessageServerCommandError) insertMessage:(UMMessage *)msg
{
    return UMMessageServerCommandError_NO_ERROR;
}

- (UMMessageServerCommandError) updateMessage:(UMMessage *)msg
{
    return UMMessageServerCommandError_NO_ERROR;
}

- (UMMessageServerCommandError) deleteMessage:(NSString *)messageId
{
    return UMMessageServerCommandError_NO_ERROR;
}




@end
