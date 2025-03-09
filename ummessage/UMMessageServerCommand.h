//
//  UMMessageServerCommand.h
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ulibasn1/ulibasn1.h>


@interface UMMessageServerCommand : UMASN1Sequence
{
    NSInteger       _command;
    NSInteger       _flags;
    NSInteger       _sequenceNumber;
}

@property(readwrite,atomic,assign)  NSInteger       command;
@property(readwrite,atomic,assign)  NSInteger       flags;
@property(readwrite,atomic,assign)  NSInteger       sequenceNumber;

- (UMMessageServerCommand *) processAfterDecodeWithContext:(id)context;
- (NSString *) objectName;
- (UMSynchronizedSortedDictionary *) objectValue;

@end

