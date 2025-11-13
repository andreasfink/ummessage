//
//  UMMessageClient.h
//  ummessage
//
//  Created by Andreas Fink on 10.03.2025.
//

#import <ulib/ulib.h>
#import <ummessage/UMMessageServerCommandError.h>

@class UMMessageHandler;
@class UMMessageObject;
@class UMMessageSession;

typedef void (^UMMesssageClientInsertCompletionHandler)(int status,NSString *error);

@interface UMMessageClient : UMObject
{
    UMSocket            *_socket;
    BOOL                _isConnected;
    UMMessageSession    *_session;
    UMMessageHandler    *_handler;
    NSString            *_username;
    NSString            *_password;
    NSString            *_instance;
    BOOL                _loginComplete;
    UMMessageServerCommandError _loginStatus;
    BOOL                _callComplete;
    UMMessageServerCommandError _callResult;
    id                  _callResultObject;

}

@property(readwrite,strong,atomic)  NSString *username;
@property(readwrite,strong,atomic)  NSString *password;
@property(readwrite,strong,atomic)  NSString *instance;
@property(readwrite,assign,atomic)  BOOL loginComplete;
@property(readwrite,assign,atomic)  UMMessageServerCommandError loginStatus;

- (UMMessageClient *)initWithHost:(UMHost *)host port:(int)port;
- (BOOL)connect; /* returns YES if connected */
- (UMMessageServerCommandError)login; /* returns UMMessageServerCommandError_NO_ERROR if logged in */
- (UMMessageServerCommandError)insertMessage:(UMMessageObject *)msg;
- (UMMessageObject *) getMessage:(NSString *)messageId
                  instance:(NSString *)instance
                     error:(UMMessageServerCommandError *)err;
- (BOOL) awaitsResponses;
- (void)close;

@end
