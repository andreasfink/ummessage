//
//  UMMessageServerCommandDeleteMessageResponse.m
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <um/UMMessageServerCommandDeleteMessageResponse.h>
#import <um/UMMessageServerCommandTypes.h>

@implementation UMMessageServerCommandDeleteMessageResponse

- (void) processBeforeEncode
{
    _command = UMMessageServerCommandType_DELETE_MESSAGE_RESPONSE;
    
    [super processBeforeEncode];
    UMASN1Integer *i= [[UMASN1Integer alloc]initWithValue:_status];
    i.asn1_tag.tagNumber = 3;
    i.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:i];
    
    if(_error)
    {
        UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithString:_error];
        s.asn1_tag.tagNumber = 4;
        s.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [_asn1_list addObject:s];
    }
}

- (NSString *) objectName
{
    return @"UMMessageServerCommandDeleteMessageResponse";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [super objectValue];
    dict[@"status"] = @(_status);
    if(_error)
    {
        dict[@"error"] = _error;
    }
    return dict;
}

- (UMMessageServerCommandDeleteMessageResponse *) processAfterDecodeWithContext:(id)context
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
                    _status = i.value;
                    break;
                }
                case 4:
                {
                    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
                    _error = s.stringValue;
                    break;
                }
                
            }
        }
        o = [self getObjectAtPosition:pos++];
    }
    return self;
}
@end
