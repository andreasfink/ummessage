//
//  UMMessageServer.h
//  ummessage-server
//
//  Created by Andreas Fink on 08.03.2025.
//

#import <ulib/ulib.h>

#import <um/UMessageCommandHandlerProtocol.h>
#import <um/UMMessageSessionDelegates.h>

@interface UMMessageServer : UMBackgrounder
{
    NSInteger           _port;
    UMSocket            *_listener;
    UMSynchronizedArray *_incomingConnections; /* array of UMMessageHandler objects */
    NSString            *_rootDirectory;
    id<UMMessageSessionAuthenticationDelegate> _authenticationDelegate;
    id<UMMessageSessionDatabaseDelegate>        _insertOrUpdateDelegate;
    id<UMMessageSessionDatabaseDelegate>        _loadDelegate;
    id<UMMessageSessionDatabaseDelegate>        _deleteDelegate;
}

@property(readwrite,assign,atomic)  NSInteger           port;
@property(readwrite,strong,atomic)  UMSocket            *listener;
@property(readwrite,strong,atomic)  UMSynchronizedArray *incomingConnections;
@property(readwrite,strong,atomic)  NSString            *rootDirectory;
@property(readwrite,strong,atomic)  id<UMMessageSessionAuthenticationDelegate> authenticationDelegate;
@property(readwrite,strong,atomic)  id<UMMessageSessionDatabaseDelegate>       insertDelegate;
@property(readwrite,strong,atomic)  id<UMMessageSessionDatabaseDelegate>       insertOrUpdateDelegate;
@property(readwrite,strong,atomic)  id<UMMessageSessionDatabaseDelegate>       loadDelegate;
@property(readwrite,strong,atomic)  id<UMMessageSessionDatabaseDelegate>       deleteDelegate;

- (UMMessageServer *)initWithPort:(NSInteger)port;
@end

