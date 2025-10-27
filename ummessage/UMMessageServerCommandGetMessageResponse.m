//
//  UMMessageServerCommandGetMessageResponse.m
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommandGetMessageResponse.h>
#import <ummessage/UMMessage.h>
#import <ummessage/UMMessageServerCommandTypes.h>

@implementation UMMessageServerCommandGetMessageResponse



- (UMMessageServerCommandGetMessageResponse *)init
{
    self = [super init];
    if(self)
    {
        _command = UMMessageServerCommandType_GET_MESSAGE_RESPONSE;
    }
    return self;
}


- (void) processBeforeEncode
{
    _command = UMMessageServerCommandType_GET_MESSAGE_RESPONSE;
    [super processBeforeEncode];
    
    UMASN1Integer *i= [[UMASN1Integer alloc]initWithValue:_status];
    i.asn1_tag.tagNumber = 3;
    i.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:i];
    if(_error)
    {
        UMASN1UTF8String *s104= [[UMASN1UTF8String alloc]initWithValue:_error];
        s104.asn1_tag.tagNumber = 4;
        s104.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [_asn1_list addObject:s104];
    }
    if(_message)
    {
        _message.asn1_tag.tagNumber = 5;
        _message.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [_asn1_list addObject:_message];
    }
}

- (NSString *) objectName
{
    return @"UMMessageServerCommandGetMessageResponse";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [super objectValue];
    dict[@"status"] = @(_status);
    if(_error)
    {
        dict[@"error"] = _error;
    }
    if(_message)
    {
        dict[@"message"] = _message;
    }
    return dict;
}

- (UMMessageServerCommandGetMessageResponse *) processAfterDecodeWithContext:(id)context
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
                    UMASN1Integer *i = [[UMASN1Integer alloc]initWithASN1Object:o context:context];
                    _status = (UMMessageServerCommandError)i.value;
                    break;
                }
                case 4:
                {
                    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
                    _error = s.stringValue;
                    break;
                }
                case 5:
                {
                    UMMessage *msg = [[UMMessage alloc]initWithASN1Object:o context:context];
                    _message = msg;
                    break;
                }
            }
        }
        o = [self getObjectAtPosition:pos++];
    }
    return self;
}
@end
