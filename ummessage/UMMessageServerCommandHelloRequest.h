//
//  UMMessageServerCommandHelloRequest.h
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommand.h>

@interface UMMessageServerCommandHelloRequest : UMMessageServerCommand
{
    NSString    *_clientName;
    NSInteger   _apiVersion;
}

@property(readwrite,atomic,strong) NSString  *clientName;
@property(readwrite,atomic,assign) NSInteger apiVersion;

@end


