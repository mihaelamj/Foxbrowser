//
//  SGBrowserViewController.m
//  Foxbrowser
//
//  Created by Simon Grätzer on 15.12.12.
//
//
//  Copyright (c) 2012 Simon Peter Grätzer
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SGBrowserViewController.h"
#import "SGBlankController.h"
#import "SGWebViewController.h"

@interface SGBrowserViewController ()

@end

@implementation SGBrowserViewController {
    NSTimer *_timer;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _timer = [NSTimer scheduledTimerWithTimeInterval:5
                                              target:self
                                            selector:@selector(saveCurrentTabs)
                                            userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_timer invalidate];
    _timer = nil;
}

- (BOOL)shouldAutorotate {
    return self.presentedViewController ? [self.presentedViewController shouldAutorotate] : YES;
}

#pragma mark - Abstract methods
- (void)addViewController:(UIViewController *)childController {
    [NSException raise:@"Not implemented Exception" format:@"Method: %s", __FUNCTION__];
}
- (void)showViewController:(UIViewController *)viewController {
    [NSException raise:@"Not implemented Exception" format:@"Method: %s", __FUNCTION__];
}
- (void)removeViewController:(UIViewController *)childController {
    [NSException raise:@"Not implemented Exception" format:@"Method: %s", __FUNCTION__];
}
- (void)removeIndex:(NSUInteger)index {
    [NSException raise:@"Not implemented Exception" format:@"Method: %s", __FUNCTION__];
}
- (void)swapCurrentViewControllerWith:(UIViewController *)viewController {
    [NSException raise:@"Not implemented Exception" format:@"Method: %s", __FUNCTION__];
}
- (void)updateChrome {
    [NSException raise:@"Not implemented Exception" format:@"Method: %s", __FUNCTION__];
};
- (UIViewController *)selectedViewController {return nil;}
- (NSUInteger)selectedIndex {return NSNotFound;}
- (NSUInteger)count {return 0;}
- (NSUInteger)maxCount {return 0;}

#pragma mark - Implemented

- (void)addTab; {
    if (self.count >= self.maxCount) {
        return;
    }
    SGBlankController *latest = [SGBlankController new];
    [self addViewController:latest];
    [self showViewController:latest];
    [self updateChrome];
}

- (void)addTabWithURL:(NSURL *)url withTitle:(NSString *)title;{
    SGWebViewController *webC = [[SGWebViewController alloc] initWithNibName:nil bundle:nil];
    webC.title = title;
    [webC openURL:url];
    
    [self addViewController:webC];
    if (self.count >= self.maxCount) {
        if ([self selectedIndex] != 0)
            [self removeIndex:0];
        else
            [self removeIndex:1];
    }
    [self updateChrome];
}

- (void)openURL:(NSURL *)url title:(NSString *)title {
    if (!url)
        return;
    
    if (!title)
        title = url.host;
        
    if ([[self selectedViewController] isKindOfClass:[SGWebViewController class]]) {
        SGWebViewController *webC = (SGWebViewController *)[self selectedViewController];
        webC.title = title;
        [webC openURL:url];
    } else {
        SGWebViewController *webC = [[SGWebViewController alloc] initWithNibName:nil bundle:nil];
        webC.title = title;
        [webC openURL:url];
        [self swapCurrentViewControllerWith:webC];
    }
}

- (void)handleURLString:(NSString*)input title:(NSString *)title {
    NSURL *url = [[WeaveOperations sharedOperations] parseURLString:input];
    if (!title) {
        title = [input stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        title = [title stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    }
    
    [self openURL:url title:title];
}

- (void)reload; {
    if ([[self selectedViewController] isKindOfClass:[SGWebViewController class]]) {
        SGWebViewController *webC = (SGWebViewController *)[self selectedViewController];
        [webC reload];
        [self updateChrome];
    }
}

- (void)stop {
    if ([[self selectedViewController] isKindOfClass:[SGWebViewController class]]) {
        SGWebViewController *webC = (SGWebViewController *)[self selectedViewController];
        [webC.webView stopLoading];
        [self updateChrome];
    }
}

- (BOOL)isLoading {
    if ([[self selectedViewController] isKindOfClass:[SGWebViewController class]]) {
        SGWebViewController *webC = (SGWebViewController *)[self selectedViewController];
        return webC.loading;
    }
    return NO;
}

- (void)goBack; {
    if ([[self selectedViewController] isKindOfClass:[SGWebViewController class]]) {
        SGWebViewController *webC = (SGWebViewController *)[self selectedViewController];
        [webC.webView goBack];
        [self updateChrome];
    }
}

- (void)goForward; {
    if ([[self selectedViewController] isKindOfClass:[SGWebViewController class]]) {
        SGWebViewController *webC = (SGWebViewController *)[self selectedViewController];
        [webC.webView goForward];
        [self updateChrome];
    }
}

- (BOOL)canGoBack; {
    if ([[self selectedViewController] isKindOfClass:[SGWebViewController class]]) {
        SGWebViewController *webC = (SGWebViewController *)[self selectedViewController];
        return [webC.webView canGoBack];
    }
    return NO;
}

- (BOOL)canGoForward; {
    if ([[self selectedViewController] isKindOfClass:[SGWebViewController class]]) {
        SGWebViewController *webC = (SGWebViewController *)[self selectedViewController];
        return [webC.webView canGoForward];
    }
    return NO;
}

- (BOOL)canStopOrReload {
    if ([[self selectedViewController] isKindOfClass:[SGWebViewController class]]) {
        return YES;
    }
    return NO;
}

- (NSURL *)URL {
    if ([[self selectedViewController] isKindOfClass:[SGWebViewController class]]) {
        SGWebViewController *webC = (SGWebViewController *)[self selectedViewController];
        return webC.location;
    }
    return nil;
}

- (BOOL)canRemoveTab:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[SGBlankController class]] && self.count == 1) {
        return NO;
    }
    return YES;
}

- (NSString *)savedTabsCacheFile {
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:@"latestURLs.plist"];
}

- (void)addSavedTabs {
    NSArray *latest = [NSArray arrayWithContentsOfFile:[self savedTabsCacheFile]];
    if (latest.count > 0) {
        for (NSString *urlString in latest) {
            [self addTabWithURL:[NSURL URLWithString:urlString] withTitle:urlString];
        }
    } else {
        SGBlankController *latest = [SGBlankController new];
        [self addViewController:latest];
    }
}

- (void)saveCurrentTabs {
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(q, ^{
        NSMutableArray *latest = [NSMutableArray arrayWithCapacity:self.count];
        for (UIViewController *controller in self.childViewControllers) {
            if ([controller isKindOfClass:[SGWebViewController class]]) {
                NSURL *url = ((SGWebViewController*)controller).location;
                if (url != nil)
                    [latest addObject:[NSString stringWithFormat:@"%@",url]];
            }
        }
        [latest writeToFile:[self savedTabsCacheFile] atomically:YES];
    });
}

@end