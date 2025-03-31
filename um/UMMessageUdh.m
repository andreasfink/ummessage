//
//  UMMessageUdh.m
//  um
//
//  Created by Andreas Fink on 26.03.2025.
//

#import "UMMessageUdh.h"
#import "UMMessageUdhConcatenated.h"
#import "UMMessageUdhConcatenated16BitRef.h"

@implementation UMMessageUdh

- (UMMessageUdh *)initWithData:(NSData *)d atPosition:(int *)pos1
{
	UMMessageUdh * returnValue = self;
    self = [super init];
    int len = (int)d.length;
    int pos = *pos1;
    
    if(pos >= len)
    {
        return NULL;
    }
    const unsigned char *bytes = d.bytes;
    
    if((len-pos) > 2)
    {
        _iei = bytes[pos++];
        int ieiLen = bytes[pos++];
        if(len-pos-ieiLen >= 0)
        {
            _data = [NSData dataWithBytes:&bytes[pos] length:ieiLen];
        }
        pos += ieiLen;
    }
    switch(_iei)
    {
        case UdhIEI_concatenated:
            returnValue = [[UMMessageUdhConcatenated alloc]initWithUdh:self];
        case UdhIEI_concatenated16bitRef:
            returnValue = [[UMMessageUdhConcatenated16BitRef alloc]initWithUdh:self];
        default:
            returnValue = self;
    }
    *pos1 = pos;
    return returnValue;
}

- (NSData *)encode
{
    [self prepareEncode];
    unsigned char bytes[2];
    bytes[0] = _iei & 0xFF; /* iei */
    bytes[1] = [_data length] & 0xFF; /* iei len */
    NSMutableData *d = [NSMutableData dataWithBytes:bytes length:sizeof(bytes)];
    [d appendData:_data];
    return d;
}

- (void)prepareEncode
{
    /* Function to be overriden */
}

- (UMMessageUdh *)copyWithZone:(NSZone *)zone
{
    UMMessageUdh *u = [[UMMessageUdh allocWithZone:zone]init];
    u.iei =   _iei;
    u.data = [_data copy];
    return u;
}

@end

