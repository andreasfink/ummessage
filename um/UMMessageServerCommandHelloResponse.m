//
//  UMMessageServerCommandHelloResponse.m
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <um/UMMessageServerCommandHelloResponse.h>
#import <um/UMMessageServerCommandTypes.h>

@implementation UMMessageServerCommandHelloResponse

- (UMMessageServerCommandHelloResponse *)init
{
    self = [super init];
    if(self)
    {
        _command = UMMessageServerCommandType_HELLO_RESPONSE;
    }
    return self;
}

- (void) processBeforeEncode
{
    _command = UMMessageServerCommandType_HELLO_RESPONSE;
    
    [super processBeforeEncode];
}

- (NSString *) objectName
{
    return @"UMMessageServerCommandHelloResponse";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [super objectValue];
    return dict;
}

- (UMMessageServerCommandHelloResponse *) processAfterDecodeWithContext:(id)context
{
    [super processAfterDecodeWithContext:context];
    int pos = 0;
    UMASN1Object *o = [self getObjectAtPosition:pos++];
    while(o)
    {
        if(o.asn1_tag.tagClass==UMASN1Class_ContextSpecific)
        {
            switch(o.asn1_tag.tagNumber)
            {
            }
        }
        o = [self getObjectAtPosition:pos++];
    }
    return self;
}
@end
