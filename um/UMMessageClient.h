//
//  UMMessageClient.h
//  ummessage
//
//  Created by Andreas Fink on 10.03.2025.
//

#import <ulib/ulib.h>

@class UMMessageHandler;
@class UMMessage;

@interface UMMessageClient : UMObject
{
    UMSocket *_socket;
    BOOL     _isConnected;
    UMMessageHandler *_handler;
}

- (UMMessageClient *)initWithHost:(UMHost *)host port:(int)port;
- (BOOL)connect; /* returns YES if connected */
- (BOOL)insertMessage:(UMMessage *)msg onCompletion:^(int status,NSString *error){};

@end
