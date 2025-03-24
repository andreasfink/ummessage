//
//  UMMessageServerCommandInsertMessageResponse.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <um/UMMessageServerCommand.h>
#import <um/UMMessageServerCommandError.h>

@interface UMMessageServerCommandInsertMessageResponse : UMMessageServerCommand
{
    UMMessageServerCommandError   _status;
    NSString    *_error;
}

@property(readwrite,atomic,assign)   UMMessageServerCommandError   status;
@property(readwrite,atomic,strong)   NSString    *error;

@end

