//
//  SDKBundleManager.m
//  FillrSDK
//
//  Created by Alex Bin Zhao on 28/10/2016.
//  Copyright © 2016 Pop Tech Pty. Ltd. All rights reserved.
//

#import "SDKBundleManager.h"

@implementation SDKBundleManager

+ (NSBundle *)sdkBundle {
    static NSBundle *sdkBundle = nil;
    if (!sdkBundle) {
        sdkBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"FillrSDKBundle" withExtension:@"bundle"]];
    }
    return sdkBundle;
}

@end
