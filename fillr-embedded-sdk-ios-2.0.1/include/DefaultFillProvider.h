//
//  FillrEmbeddedSDK.h
//  POP
//
//  Created by Alex Bin Zhao on 18/08/2016.
//  Copyright © 2016 POP TECH Pty. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FillrSDK/Fillr.h"
#import "FillViewController.h"

@interface DefaultFillProvider : NSObject<FillProvider>

+ (DefaultFillProvider *)sharedInstance;

@property (strong, nonatomic) UIViewController *rootViewController;
@property (strong, nonatomic) FillViewController *fillViewController;

@end
