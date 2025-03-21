//
//  UMMessageServer.h
//  ummessage-server
//
//  Created by Andreas Fink on 08.03.2025.
//

#import <ulib/ulib.h>

#import <um/UMessageCommandHandlerProtocol.h>
#import <um/UMMessageSessionAuthenticationDelegate.h>

@interface UMMessageServer : UMBackgrounder
{
    NSInteger           _port;
    UMSocket            *_listener;
    UMSynchronizedArray *_incomingConnections; /* array of UMMessageHandler objects */
    NSString            *_rootDirectory;
    id<UMMessageSessionAuthenticationDelegate> _authenticationDelegate;
}

@property(readwrite,assign,atomic)  NSInteger           port;
@property(readwrite,strong,atomic)  UMSocket            *listener;
@property(readwrite,strong,atomic)  UMSynchronizedArray *incomingConnections;
@property(readwrite,strong,atomic)  NSString            *rootDirectory;
@property(readwrite,strong,atomic)  id<UMMessageSessionAuthenticationDelegate> authenticationDelegate;

- (UMMessageServer *)initWithPort:(NSInteger)port;
@end

