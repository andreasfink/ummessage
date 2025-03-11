//
//  UMMessageClient.h
//  ummessage
//
//  Created by Andreas Fink on 10.03.2025.
//

#import <ulib/ulib.h>

@class UMMessageHandler;
@class UMMessage;
@class UMMessageSession;

typedef void (^UMMesssageClientInsertCompletionHandler)(int status,NSString *error);

@interface UMMessageClient : UMObject
{
    UMSocket *_socket;
    BOOL             _isConnected;
    UMMessageSession *_session;
    UMMessageHandler *_handler;
    NSString *_username;
    NSString *_password;
    NSString *_instance;
    BOOL _loggedIn;
    BOOL _loginComplete;
}

@property(readwrite,strong,atomic)  NSString *username;
@property(readwrite,strong,atomic)  NSString *password;
@property(readwrite,strong,atomic)  NSString *instance;
@property(readwrite,assign,atomic)  BOOL loggedIn;

- (UMMessageClient *)initWithHost:(UMHost *)host port:(int)port;
- (BOOL)connect; /* returns YES if connected */
- (BOOL)login; /* returns YES if logged in */
- (BOOL)insertMessage:(UMMessage *)msg;
- (BOOL) awaitsResponses;

@end
