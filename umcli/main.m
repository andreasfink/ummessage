//
//  main.m
//  umcli
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <Foundation/Foundation.h>
#import <um/um.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        UMHost *host = [[UMHost alloc]initWithLocalhost];
        UMMessageClient *client = [[UMMessageClient alloc]initWithHost:host port:9121];
        [[UMMessageClient alloc]init];
    }
    return 0;
}
