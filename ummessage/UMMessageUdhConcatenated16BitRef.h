//
//  UMMessageUdhConcatenated16BitRef.h
//  um
//
//  Created by Andreas Fink on 26.03.2025.
//


#import <ummessage/UMMessageObject.h>
#import <ummessage/UMMessageUdh.h>


@interface UMMessageUdhConcatenated16BitRef : UMMessageUdh
{
    NSInteger   _ref;
    NSInteger   _maxParts;
    NSInteger   _currentPart;
}

@property(readwrite,assign) NSInteger   ref;
@property(readwrite,assign) NSInteger   maxParts;
@property(readwrite,assign) NSInteger   currentPart;

- (UMMessageUdhConcatenated16BitRef *)initWithUdh:(UMMessageUdh *)udh;
- (UMMessageUdhConcatenated16BitRef *)copyWithZone:(NSZone *)zone;

@end

