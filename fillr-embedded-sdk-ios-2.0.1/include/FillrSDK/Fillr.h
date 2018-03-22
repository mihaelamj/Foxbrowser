/*
 * Copyright 2015-present Pop Tech Pty Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "FillrAutofillInputAccessoryView.h"
#import "FillrAutofillEbatesCoachmarkView.h"

typedef enum {
    FillrStateDownloadingApp,
    FillrStateOpenApp,
    FillrStateFormFilled
} FillrSessionState;

typedef enum {
    IntegratedBrowser_Default,
    IntegratedBrowser_FoxBrowser,
    IntegratedBrowser_Ebates,
    IntegratedBrowser_Klarna
} IntegratedBrowser;

@protocol FillrDelegate<NSObject>
- (void)fillrStateChanged:(FillrSessionState)state currentWebView:(UIView *)currentWebView;
- (void)onFillrDismissThresholdExceeded;
- (void)onFillrToolbarVisibilityChanged:(BOOL)isVisible isFillrInstalled:(BOOL)isFillrInstalled;
- (void)onFillrToolbarClicked:(BOOL)isFillrInstalled;
@end

@protocol FillrCloudBrowserDelegate <NSObject>
- (void)onFillButtonClicked:(id)sender;
- (void)onFillApproved:(NSString *)mappings profileData:(NSString *)profileData;
@end

@protocol FillProvider<NSObject>
- (BOOL)canHandleOpenURL:(NSURL *)url;
- (void)handleOpenURL:(NSURL *)url;
- (void)cancel;
- (void)fillForm:(NSString *)mappingMetaData inWebView:(UIView *)webView;
- (void)handleStartLoadNewPage;
- (void)captureValues:(NSString *)mappingMetaData values:(NSString *)values mappingHandler:(void (^)(BOOL anyFillableField))mappingHandler;
- (void)getMappings:(NSString *)mappingMetaData devKey:devKey secretKey:secretKey completionHandler:(void (^)(NSDictionary * mappings))completionHandler;
- (void)onFillrToolbarShown;
- (void)onFillrToolbarClicked;
- (void)onFillrToolbarDismiss;
@end

@protocol FillrProfilePayloadDelegate <NSObject>
- (void)onProfilePayloadRequestedForWebView:(UIView *)webView requestedFields:(NSArray *)requestedFields payloadHandler:(void (^)(NSDictionary *payload))payloadHandler;
@end

@interface Fillr : NSObject <FillrAutofillToolbarDelegate, FillrAutofillEbatesCoachmarkDelegate>


@property (assign, nonatomic) BOOL overlayInputAccessoryView;
@property (weak, nonatomic) id <FillrDelegate> delegate;
@property (weak, nonatomic) id <FillrCloudBrowserDelegate> cloudBrowserDelegate;
@property (strong, nonatomic) id <FillProvider> fillProvider;
@property (strong, nonatomic) id <FillrProfilePayloadDelegate> profilePayloadDelegate;
@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) BOOL visible;
@property UIImage *toolbarIcon;
@property (assign, nonatomic) BOOL isDolphin;
@property (strong, nonatomic) UIColor *toolbarTextColor;
@property (strong, nonatomic) UIColor *toolbarThemeColor;
@property (readonly, nonatomic) IntegratedBrowser integratedBrowser;

@property (readonly, nonatomic) NSString *devKey;
@property (readonly, nonatomic) NSString *urlScheme;
@property (assign, nonatomic) BOOL localWidget;

+ (Fillr *)sharedInstance;

- (void)initialiseWithDevKey:(NSString *)devKey secretKey:(NSString *)secretKey andUrlScheme:(NSString *)urlScheme;

- (void)setBrowserName:(NSString *)browserName toolbarBrowserName:(NSString *)toolbarBrowserName;

- (BOOL)canHandleOpenURL:(NSURL *)url;
- (void)handleOpenURL:(NSURL *)url;
- (void)cancel;

- (BOOL)canHandleWebViewRequest:(NSURLRequest *)request;
- (void)handleWebViewRequest:(NSURLRequest *)request forWebView:(UIView *)webView;
- (void)handleWebViewDidStartLoad:(UIView *)webView;
- (void)handleWebViewDidFinishLoad:(UIView *)webView;

- (void)installFillr;
- (BOOL)hasFillrInstalled;
- (void)showDownloadDialog;
- (void)trackWebview:(UIView *)webView;
- (BOOL)hasWebview;

- (void)fillFormWithMappings:(NSDictionary *)mappings andPayload:(NSDictionary *)profilePayload;

- (void)disableForCurrentDomain;
    
- (void)applyContentScriptToController:(WKUserContentController *)contentController;
- (WKWebViewConfiguration *)getDefaultWKWebViewConfiguration;

- (NSString *)loadLocalWidget;

- (BOOL)isHeadlessFillEnabled;
- (void)setHeadlessFillEnabled:(BOOL)enabled;
- (void)triggerFill:(UIView *)webView;

- (NSUInteger)webViewCount;

@end
