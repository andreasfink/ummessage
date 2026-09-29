//
//  main.m
//  test-tool
//
//  Created by Andreas Fink on 11.03.2025.
//

#import <ulib/ulib.h>
#import <ulib/ulib.h>
#import <ummessage/ummessage.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        UMASN1Real *r = [[UMASN1Real alloc]initWithValue:0.5];
        NSLog(@"r=%@",r);
        [r processBeforeEncode];
        NSLog(@"r=%@",r);
        NSData *d = [r berEncoded];
        NSLog(@"r=%@",r);
        NSLog(@"d=%@",d);
        UMASN1Object *a = [[UMASN1Object alloc]initWithBerData:d];
        NSLog(@"a=%@",a);
        UMASN1Real *r2 = [[UMASN1Real alloc]initWithASN1Object:a context:NULL];
        NSLog(@"r2=%@",r2);
        NSLog(@"r2.value=%lf",r2.value);

        UMMessageObject *msg = [[UMMessageObject alloc]initWithNewIdAndInstance:@"default"];
        UMSynchronizedSortedDictionary *dict = msg.objectValue;
        NSLog(@"Message1: %@",dict.jsonString);
        NSData *data =[msg berEncoded];
        UMMessageObject *msg2 = [[UMMessageObject alloc]initWithBerData:data];
        UMSynchronizedSortedDictionary *dict2 = msg2.objectValue;
        NSLog(@"Message2: %@",dict2.jsonString);

    }
    return 0;
}
