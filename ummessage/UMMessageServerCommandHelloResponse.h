//
//  UMMessageServerCommandHelloResponse.h
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommand.h>

@interface UMMessageServerCommandHelloResponse : UMMessageServerCommand
{
    NSString    *_serverName;
    NSInteger   _apiVersion;
}

@property(readwrite,atomic,strong) NSString  *serverName;
@property(readwrite,atomic,assign) NSInteger apiVersion;


@end

