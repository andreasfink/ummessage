//
//  UMMessageClient.h
//  ummessage
//
//  Created by Andreas Fink on 10.03.2025.
//

#import <ulib/ulib.h>

@class UMMessageHandler;

@interface UMMessageClient : UMObject
{
    UMSocket *_socket;
    BOOL     _isConnected;
    UMMessageHandler *_handler;
}

- (UMMessageClient *)initWithHost:(UMHost *)host port:(int)port;
- (BOOL)connect; /* returns YES if connected */
@end
