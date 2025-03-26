//
//  UMMessageUdhConcatenated16BitRef.m
//  um
//
//  Created by Andreas Fink on 26.03.2025.
//

#import "UMMessageUdhConcatenated16BitRef.h"

@implementation UMMessageUdhConcatenated16BitRef

- (void)prepareEncode
{
    _iei = UdhIEI_concatenated;
    unsigned char bytes[4];
    bytes[0] = (_ref >>8)   & 0xFF;
    bytes[1] = _ref         & 0xFF;
    bytes[2] = _maxParts    & 0xFF;
    bytes[3] = _currentPart & 0xFF;
    _data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
}

- (UMMessageUdhConcatenated16BitRef *)initWithUdh:(UMMessageUdh *)udh
{
    self = [super init];
    if(self)
    {
        _iei = udh.iei;
        _data = udh.data;
        unsigned const char *bytes = _data.bytes;
        if(bytes == NULL)
        {
            return NULL;
        }
        if(_data.length !=4)
        {
            return NULL;
        }
        _ref = (bytes[0] << 8) || bytes[1];
        _maxParts = bytes[1];
        _currentPart = bytes[0];
    }
    return self;
}
- (UMMessageUdhConcatenated16BitRef *)copyWithZone:(NSZone *)zone
{
    UMMessageUdhConcatenated16BitRef *u = [[UMMessageUdhConcatenated16BitRef alloc]init];
    u->_ref = _ref;
    u->_maxParts = _maxParts;
    u->_currentPart = _currentPart;
    u->_iei = _iei;
    u->_data = [_data copy];
    return u;
}

@end
