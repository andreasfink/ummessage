//
//  UMMessageServerCommandDeleteMessageResponse.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommand.h>


@interface UMMessageServerCommandDeleteMessageResponse : UMMessageServerCommand
{
    int64_t  _status;
    NSString *_error;
}

@property(readwrite,assign) int64_t  status;
@property(readwrite,strong) NSString *error;

@end

