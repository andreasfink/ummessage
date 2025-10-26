//
//  UMMessageUdhConcatenated.h
//  um
//
//  Created by Andreas Fink on 26.03.2025.
//

#import <um/UMMessageUdh.h>

@interface UMMessageUdhConcatenated : UMMessageUdh
{
    NSInteger   _ref;
    NSInteger   _maxParts;
    NSInteger   _currentPart;
}

@property(readwrite,assign) NSInteger   ref;
@property(readwrite,assign) NSInteger   maxParts;
@property(readwrite,assign) NSInteger   currentPart;

- (UMMessageUdhConcatenated *)initWithUdh:(UMMessageUdh *)udh;
- (UMMessageUdhConcatenated *)copyWithZone:(NSZone *)zone;
- (void)prepareEncode;

@end

