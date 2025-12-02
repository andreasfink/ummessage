//
//  main.m
//  umcli
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ulib/ulib.h>
#import <ummessage/ummessage.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        AppDelegate *_appdel = [[AppDelegate alloc]init];
        [_appdel main:argc argv:argv];
        _appdel = NULL;
    }
}

