//
//  UMMessageServerCommandHelloRequest.m
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommandHelloRequest.h>
#import <ummessage/UMMessageServerCommandTypes.h>

@implementation UMMessageServerCommandHelloRequest

- (void) processBeforeEncode
{
    _command = UMMessageServerCommandType_HELLO_REQUEST;
    
    [super processBeforeEncode];

    UMASN1UTF8String *s= [[UMASN1UTF8String alloc]initWithValue:_clientName];
    s.asn1_tag.tagNumber = 3;
    s.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:s];

    UMASN1Integer *i= [[UMASN1Integer alloc]initWithValue:_apiVersion];
    i.asn1_tag.tagNumber = 4;
    i.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:i];
}


- (NSString *) objectName
{
    return @"UMMessageServerCommandHelloRequest";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [super objectValue];
    dict[@"client-name"] = _clientName;
    dict[@"api-version"] = @(_apiVersion);
    return dict;
}

- (UMMessageServerCommandHelloRequest *) processAfterDecodeWithContext:(id)context
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
                case 3:
                {
                    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
                    _clientName = s.stringValue;
                    break;
                }
                case 4:
                {
                    UMASN1Integer *i = [[UMASN1Integer alloc]initWithASN1Object:o context:context];
                    _apiVersion = i.value;
                    break;
                }
            }
        }
        o = [self getObjectAtPosition:pos++];
    }
    return self;
}
@end
