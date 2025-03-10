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
}

- (UMMessageClient *)initWithHost:(UMHost *)host port:(int)port;
- (BOOL)connect; /* returns YES if connected */
- (BOOL)insertMessage:(UMMessage *)msg;
@end
