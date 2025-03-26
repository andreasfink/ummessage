//
//  UMMessageUdhConcatenated.m
//  um
//
//  Created by Andreas Fink on 26.03.2025.
//

#import "UMMessageUdhConcatenated.h"

@implementation UMMessageUdhConcatenated

- (void)prepareEncode
{
    _iei = UdhIEI_concatenated;
    unsigned char bytes[3];
    bytes[0] = _ref      & 0xFF;
    bytes[1] = _maxParts & 0xFF;
    bytes[2] = _currentPart & 0xFF;
    _data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
}

- (UMMessageUdhConcatenated *)initWithUdh:(UMMessageUdh *)udh
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
        if(_data.length !=3)
        {
            return NULL;
        }
        _ref = bytes[0];
        _maxParts = bytes[1];
        _currentPart = bytes[2];
    }
    return self;
}
- (UMMessageUdhConcatenated *)copyWithZone:(NSZone *)zone
{
    UMMessageUdhConcatenated *u = [[UMMessageUdhConcatenated alloc]init];
    u->_ref = _ref;
    u->_maxParts = _maxParts;
    u->_currentPart = _currentPart;
    u->_iei = _iei;
    u->_data = [_data copy];
    return u;
}

@end
