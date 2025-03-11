//
//  main.m
//  test-tool
//
//  Created by Andreas Fink on 11.03.2025.
//

#import <Foundation/Foundation.h>
#import <ulibasn1/ulibasn1.h>
#import <um/um.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        UMMessage *msg = [[UMMessage alloc]init];
        msg.messageId = [[UMDirtyString alloc]init];
        msg.messageId.stringValue = [UMMessage uniqueMessageIdWithPrefix:@""];
        
        UMSynchronizedSortedDictionary *dict = msg.objectValue;
        NSLog(@"Message1: %@",dict.jsonString);
        NSData *data =[msg berEncoded];
        UMMessage *msg2 = [[UMMessage alloc]initWithBerData:data];
        UMSynchronizedSortedDictionary *dict2 = msg2.objectValue;
        NSLog(@"Message2: %@",dict2.jsonString);

    }
    return 0;
}
