//
//  UMMessageServerCommandHelloResponse.m
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommandHelloResponse.h>
#import <ummessage/UMMessageServerCommandTypes.h>

@implementation UMMessageServerCommandHelloResponse

- (void) processBeforeEncode
{
    _command = UMMessageServerCommandType_HELLO_RESPONSE;
    
    [super processBeforeEncode];

    UMASN1UTF8String *i101= [[UMASN1UTF8String alloc]initWithValue:_serverName];
    i101.asn1_tag.tagNumber = 101;
    i101.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:i101];

    UMASN1Integer *i102= [[UMASN1Integer alloc]initWithValue:_apiVersion];
    i102.asn1_tag.tagNumber = 102;
    i102.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:i102];
}

- (NSString *) objectName
{
    return @"UMMessageServerCommandHelloResponse";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [super objectValue];
    dict[@"server-name"] = _serverName;
    dict[@"api-version"] = @(_apiVersion);
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
                case 3:
                {
                    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
                    _serverName = s.stringValue;
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
