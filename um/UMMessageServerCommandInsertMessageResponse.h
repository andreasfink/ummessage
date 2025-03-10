//
//  UMMessageServerCommandInsertMessageResponse.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <um/UMMessageServerCommand.h>

@interface UMMessageServerCommandInsertMessageResponse : UMMessageServerCommand
{
    NSInteger   _status;
    NSString    *_error;
}

@property(readwrite,atomic,assign)   NSInteger   status;
@property(readwrite,atomic,strong)   NSString    *error;

@end

