//
//  UMMessageServerCommandUpdateMessageResponse.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommand.h>

@interface UMMessageServerCommandUpdateMessageResponse : UMMessageServerCommand
{
    NSInteger   _status;
    NSString    *_error;
}

@property(readwrite,atomic,assign)   NSInteger   status;
@property(readwrite,atomic,strong)   NSString    *error;


@end

