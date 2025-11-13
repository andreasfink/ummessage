//
//  UMMessageServerCommandInsertMessageRequest.m
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommandInsertMessageRequest.h>
#import <ummessage/UMMessageServerCommandTypes.h>
#import <ummessage/UMMessageObject.h>

@implementation UMMessageServerCommandInsertMessageRequest


- (UMMessageServerCommandInsertMessageRequest *)init
{
    self = [super init];
    if(self)
    {
        _command = UMMessageServerCommandType_INSERT_MESSAGE_REQUEST;
    }
    return self;
}

- (void) processBeforeEncode
{
    _command = UMMessageServerCommandType_INSERT_MESSAGE_REQUEST;
    
    [super processBeforeEncode];
    [_message processBeforeEncode];
    _message.asn1_tag.tagNumber = 3;
    _message.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:_message];
}


- (NSString *) objectName
{
    return @"UMMessageServerCommandInsertMessageRequest";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [super objectValue];
    dict[@"message"] = _message;
    return dict;
}

- (UMMessageServerCommandInsertMessageRequest *) processAfterDecodeWithContext:(id)context
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
                    _message = [[UMMessageObject alloc]initWithASN1Object:o context:context];
                    NSLog(@"Message: %@",_message);
                    break;
            }
        }
        o = [self getObjectAtPosition:pos++];
    }
    return self;
}

@end
