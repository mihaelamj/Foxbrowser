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

#import "Fillr.h"
#import "FillrAlertView.h"
#import "FillrAutofillInputAccessoryView.h"
#import "NSData+Base64Fillr.h"
#import "FillrToolbarPopup.h"
#import "SDKBundleManager.h"
#import "Strings.h"

#define SYSTEM_VERSION_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define kFillrEnabled (@"FillrEnabled")
#define kFillrInvisible (@"FillrToolbarInvisible")
#define kMobileWidgetEtag (@"FillrMobileWidgetEtag")
#define kMobileWidgetLastModified (@"FillrMobileWidgetLastModified")
#define kFillrSDKVersion (@"2.0")

@interface Fillr () {
    NSString *browserName;
    NSString *toolbarBrowserName;
    
    CGRect keyboardFrame;
    FillrAutofillInputAccessoryView *accessoryView;
    BOOL hasShownAccessoryView;
    NSString *currentDomain;
    int fieldFocusCount;
    
    UIView *webView;
    NSString *devKey;
    NSString *secretKey;
    NSString *urlScheme;
    
    NSDate *widgetLastUpdatedTime;
    
    NSMutableArray *disabledDomains;
}

@end

@implementation Fillr

@synthesize enabled = _enabled;
@synthesize visible = _visible;

#pragma mark Public API

static Fillr *sharedInstance;

+ (Fillr *)sharedInstance {
    if (!sharedInstance) {
        if (!sharedInstance) {
            sharedInstance = [[Fillr alloc] init];
            sharedInstance.overlayInputAccessoryView = NO;
        }
    }
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        [self addObservers];
        
        // Kick off widget update as soon as instance updated
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            @autoreleasepool {
                NSHTTPURLResponse *response = nil;
                NSError *error = nil;
                NSData *data = [self downloadWidgetData:&response error:&error];
                [self resolveWidgetToStringWithData:data downloadResponse:response error:error];
            }
        });
    }
    return self;
}

- (void)installFillr {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fillrStateChanged:currentWebView:)]) {
        [self.delegate fillrStateChanged:FillrStateDownloadingApp currentWebView:webView];
    }
    
    // Redirect to app store
    NSString *iTunesLink = @"https://itunes.apple.com/us/app/apple-store/id971588428?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

- (void)showDownloadDialog {
    if (![self hasFillrInstalled]) {
        FillrAlertView *anAlert = [[FillrAlertView alloc] initWithTitle:nil
                                                                message:kString_Install_Slogan
                                                               delegate:nil
                                                      cancelButtonTitle:kString_Cancel
                                                      otherButtonTitles:kString_Install_Now, nil];
        
        anAlert.clickedButtonBlock = ^(NSInteger buttonIndex){
            if (buttonIndex == 1) {
                [self installFillr];
            }
        };
        
        [anAlert show];
    }
}

- (void)trackWebview:(UIView *)webViewToTrack {
    webView = webViewToTrack;
    hasShownAccessoryView = NO;
    currentDomain = nil;
    fieldFocusCount = 0;
}

- (BOOL)hasWebview {
    return webView != nil;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_enabled forKey:kFillrEnabled];
    [defaults synchronize];
}

- (BOOL)enabled
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _enabled = [defaults boolForKey:kFillrEnabled];
    return _enabled;
}

- (void)setVisible:(BOOL)visible {
    _visible = visible;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:!_visible forKey:kFillrInvisible];
    [defaults synchronize];
}

- (BOOL)visible
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _visible = ![defaults boolForKey:kFillrInvisible];
    return _visible;
}

- (void)initialiseWithDevKey:(NSString *)devKeyToSet secretKey:(NSString *)secretKeyToSet andUrlScheme:(NSString *)urlSchemeToSet {
    devKey = devKeyToSet;
    secretKey = secretKeyToSet;
    urlScheme = urlSchemeToSet;
}

- (IntegratedBrowser)integratedBrowser {
    if ([devKey isEqualToString:@"c4a8852ce67427a97330388659e0f2b5"]) {
        return IntegratedBrowser_FoxBrowser;
    } else if ([devKey isEqualToString:@"1ed4e880b0600a65bfbe8f001cf026a0"]) {
        return IntegratedBrowser_Ebates;
    }
    return IntegratedBrowser_Default;
}

- (void)setBrowserName:(NSString *)browserNameToSet toolbarBrowserName:(NSString *)toolbarBrowserNameToSet {
    browserName = browserNameToSet;
    toolbarBrowserName = toolbarBrowserNameToSet;
}

- (BOOL)canHandleOpenURL:(NSURL *)url {
    return [[url absoluteString] hasPrefix:urlScheme ? urlScheme : @"fillrbrowser"] || (self.fillProvider && [self.fillProvider canHandleOpenURL:url]);
}

- (void)handleOpenURL:(NSURL *)url {
    if ([[url absoluteString] rangeOfString:@"fillform"].location != NSNotFound) {
        NSDictionary *parameters = [self parserQueryStringsForURL:[url absoluteString]];
        if ([parameters objectForKey:@"fields"] && [parameters objectForKey:@"payload"]) {
            NSString *fields64 = [parameters objectForKey:@"fields"];
            NSString *fields = [[NSString alloc] initWithData:[NSData dataFromBase64UrlString:fields64] encoding:NSUTF8StringEncoding];
            
            NSString *payload64 = [parameters objectForKey:@"payload"];
            NSString *payload = [[NSString alloc] initWithData:[NSData dataFromBase64UrlString:payload64] encoding:NSUTF8StringEncoding];
            
            [[Fillr sharedInstance] fillFormWithFields:fields andPayload:payload];
            [webView endEditing:YES];
        }
    } else if (self.fillProvider && [self.fillProvider canHandleOpenURL:url]) {
        [self.fillProvider handleOpenURL:url];
    }
}

- (void)cancel {
    if (self.fillProvider) {
        [self.fillProvider cancel];
    }
}

- (void)handleWebViewDidStartLoad {
    if (self.fillProvider) {
        [self.fillProvider handleStartLoadNewPage];
    }
}

- (void)handleWebViewDidFinishLoad {
    // Track web view focus event
    [self evaluateJavaScript:@"function attachFocusListener() { if (window.FillrFieldFocusEvent != undefined) return; console.log('Assigning Field Focussed'); window.FillrFieldFocusEvent = function(e) { console.log('Field Focussed!'); window.location.href = 'fillr:focus'; }; document.addEventListener('focus', window.FillrFieldFocusEvent, true);window.FillrFieldBlurEvent = function(e) { console.log('Field Blurred!'); window.location.href = 'fillr:blur'; }; document.addEventListener('blur', window.FillrFieldBlurEvent, true);};attachFocusListener();window.addEventListener('load', attachFocusListener);"];
}

- (BOOL)canHandleWebViewRequest:(NSURLRequest *)request {
    return [[request.URL absoluteString] hasPrefix:@"fillr:"];
}

- (void)handleWebViewRequest:(NSURLRequest *)request {
    if ([[request.URL absoluteString] hasPrefix:@"fillr:focus"]) {
        fieldFocusCount++;
    }
    
    if ([[request.URL absoluteString] hasPrefix:@"fillr:focus"] || [[request.URL absoluteString] hasPrefix:@"fillr:blur"]) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            @autoreleasepool {
                // Use local widget first
                NSString *widgetStringValue = [self loadLocalWidget];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // Inject javascript and request fields, values
                    NSString *fieldsString = [self evaluateJavaScript:@"window.PopWidgetInterface.getFields()"];
                    bool widgetInjected = fieldsString != nil && fieldsString.length > 0;
                    if (!widgetInjected) {
                        [self evaluateJavaScript:widgetStringValue];
                        fieldsString = [self evaluateJavaScript:@"window.PopWidgetInterface.getFields()"];
                    }
                    NSString *valuesString = [self evaluateJavaScript:@"window.PopWidgetInterface.getValues()"];
                    [self startCaptureValueProcess:fieldsString values:valuesString];
                });
            }
        });
    }
}

#pragma mark Package Only Methods

- (void)startFillProcess:(NSString *)fieldsString
{
    BOOL hasResult = false;
    
    BOOL hasFillrInstalled = [self hasFillrInstalled];
    if (fieldsString && [fieldsString isKindOfClass:[NSString class]] && fieldsString.length > 0) {
        if (hasFillrInstalled) {
            [self createFillrRequestWithFields:fieldsString];
        } else if (self.fillProvider) {
            NSData *objectData = [fieldsString dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *result = [[NSJSONSerialization JSONObjectWithData:objectData
                                                                           options:NSJSONReadingMutableContainers
                                                                             error:nil] mutableCopy];
            
            [result setObject:urlScheme ? urlScheme : @"fillrbrowser" forKey:@"returnAppDomain"];
            // Pass through sdkversion and dev key so these can be used in analytics Trello #339
            [result setObject:kFillrSDKVersion forKey:@"sdkversion"];
            [result setObject:devKey forKey:@"devkey"];
            
            objectData = [NSJSONSerialization dataWithJSONObject:result
                                            options:NSJSONWritingPrettyPrinted
                                                           error:nil];
            NSString *mappingMetaData = [[NSString alloc] initWithData:objectData encoding:NSUTF8StringEncoding];
            
            [self.fillProvider fillForm:mappingMetaData];
        } else {
            hasResult = [self deferFillrRequestWithFields:fieldsString];
        }
    }
    
    if (!self.fillProvider && !hasFillrInstalled) {
        [self showFillrAlert:hasResult];
    }
}

- (void)startCaptureValueProcess:(NSString *)fieldsString values:(NSString *)valuesString
{
    if (fieldsString && [fieldsString isKindOfClass:[NSString class]]) {
        if (self.fillProvider) {
            NSData *objectData = [fieldsString dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *result = [[NSJSONSerialization JSONObjectWithData:objectData
                                                                           options:NSJSONReadingMutableContainers
                                                                             error:nil] mutableCopy];
            
            [result setObject:urlScheme ? urlScheme : @"fillrbrowser" forKey:@"returnAppDomain"];
            // Pass through sdkversion and dev key so these can be used in analytics Trello #339
            [result setObject:kFillrSDKVersion forKey:@"sdkversion"];
            [result setObject:devKey forKey:@"devkey"];
            
            objectData = [NSJSONSerialization dataWithJSONObject:result
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:nil];
            NSString *mappingMetaData = [[NSString alloc] initWithData:objectData encoding:NSUTF8StringEncoding];
            
            [self.fillProvider captureValues:mappingMetaData values:valuesString];
        }
    }
}

#pragma mark Private Methods

- (NSString *)getToolbarButtonText
{
    NSString *localizedAutofillText;
    if (self.isDolphin) {
        if (!self.fillProvider && ![self hasFillrInstalled]) {
            localizedAutofillText = kString_Install_Autofill_for_Dolphin;
        } else {
            localizedAutofillText = kString_Autofill_This_Form;
        }
    } else {
        if (!self.fillProvider && ![self hasFillrInstalled] && toolbarBrowserName) {
            localizedAutofillText = [NSString stringWithFormat:kString_Install_Autofill, toolbarBrowserName];
        } else {
            localizedAutofillText = kString_Use_Secure_Autofill;
        }
    }
    
    return localizedAutofillText;
}

- (void)initializeUIElements {
    
    NSString * toolbarText = [self getToolbarButtonText];
    
    if (!accessoryView) {
        CGRect toolbarFrame = CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 44.0f);
        accessoryView = [[FillrAutofillInputAccessoryView alloc] initWithFrame:toolbarFrame toolbarText:toolbarText isDolphin:self.isDolphin];
        
        if (self.toolbarIcon) {
            accessoryView.brandedToolbarIcon = self.toolbarIcon;
        }
        
        accessoryView.delegate = self;
        
    } else {
        [accessoryView setToolbarPromptText:toolbarText];
    }
}

- (BOOL)hasFillrInstalled {
    if (self.fillProvider && (self.integratedBrowser == IntegratedBrowser_FoxBrowser || self.integratedBrowser == IntegratedBrowser_Ebates)) {
        // If it has embedded sdk setup and it is fox browser or ebates, then we pretend fillr app is not installed
        return NO;
    } else {
        return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fillr://"]];
    }
}

- (BOOL)shouldUpdateWidget {
    // Update widget if last update more than 10 mins ago
    return !widgetLastUpdatedTime || -[widgetLastUpdatedTime timeIntervalSinceNow] > 600;
}

- (NSData *)downloadWidgetData:(NSHTTPURLResponse **)response error:(NSError **)error
{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://d2o8n2jotd2j7i.cloudfront.net/widget/ios/sdk/FillrWidget-iOS.js.gz"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0f];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults stringForKey:kMobileWidgetEtag]) {
        NSString *ETag = [defaults stringForKey:kMobileWidgetEtag];
        [urlRequest setValue:ETag forHTTPHeaderField:@"If-None-Match"];
    }
    if ([defaults stringForKey:kMobileWidgetLastModified]) {
        NSString *lastModified = [defaults stringForKey:kMobileWidgetLastModified];
        [urlRequest setValue:lastModified forHTTPHeaderField:@"If-Modified-Since"];
    }
    
    [urlRequest setHTTPMethod:@"GET"];
    
    return [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:response error:error];
}

- (NSString *)localWidgetFilePath {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *localWidgetFilePath = [documentsDirectory stringByAppendingPathComponent:@"UnwrappedMobileWidget"];
    return localWidgetFilePath;
}

- (NSString *)loadLocalWidget {
    NSString *localWidgetFileName = [self localWidgetFilePath];
    NSString *widgetStringValue;
    bool useLocalWidgetForTesting = true;
    if (!useLocalWidgetForTesting && [[NSFileManager defaultManager] fileExistsAtPath:localWidgetFileName]) {
        widgetStringValue = [NSString stringWithContentsOfFile:localWidgetFileName encoding:NSUTF8StringEncoding error: NULL];
    } else {
        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"FillrSDKBundle" withExtension:@"bundle"]];
        NSString *widgetPath = [bundle pathForResource:@"UnwrappedMobileWidget" ofType:@"js"];
        widgetStringValue = [NSString stringWithContentsOfFile:widgetPath encoding:NSUTF8StringEncoding error: NULL];
    }
    return widgetStringValue;
}

- (NSString *)resolveWidgetToStringWithData:(NSData *)data downloadResponse:(NSHTTPURLResponse *)response error:(NSError *)error
{
    NSString *localWidgetFileName = [self localWidgetFilePath];
    NSString *widgetStringValue;
    
    if (response && response.statusCode == 200 && data != nil && error == nil) {
        widgetLastUpdatedTime = [NSDate date];
        // If new, then save to local document directory
        widgetStringValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        // Get etag if save successfully
        if ([widgetStringValue writeToFile:localWidgetFileName atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
            NSDictionary *responseHeaders = [response allHeaderFields];
            NSString *ETag = [responseHeaders objectForKey:@"ETag"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:ETag forKey:kMobileWidgetEtag];
            NSString *lastModified = [responseHeaders objectForKey:@"LastModified"];
            [defaults setObject:lastModified forKey:kMobileWidgetLastModified];
            [defaults synchronize];
        }
    } else if (response && response.statusCode == 304) {
        widgetLastUpdatedTime = [NSDate date];
        widgetStringValue = [NSString stringWithContentsOfFile:localWidgetFileName encoding:NSUTF8StringEncoding error:nil];
    } else {
        widgetStringValue = [self loadLocalWidget];
    }

    return widgetStringValue;
}

- (void)autofillTapped:(id)sender {
    // Should not do anything if the sdk is disabled
    if ([self isDisabled]) {
        return;
    }
    
    // Delegate method
    if (self.delegate && [self.delegate respondsToSelector:@selector(onFillrToolbarClicked:)]) {
        [self.delegate onFillrToolbarClicked:[self hasFillrInstalled]];
    }
    
    if (self.cloudBrowserDelegate) {
        [self.cloudBrowserDelegate onFillButtonClicked:sender];
        return;
    }
    
    if (self.fillProvider) {
        [self.fillProvider onFillrToolbarClicked];
    }
    
    // Download latest widget sending synchronous request on an async queue
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        @autoreleasepool {
            // Use local widget first
            NSString *widgetStringValue = [self loadLocalWidget];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                // Inject javascript and request fields
                NSString *fieldsString = [self evaluateJavaScript:@"window.PopWidgetInterface.getFields()"];
                bool widgetInjected = fieldsString != nil && fieldsString.length > 0;
                if (!widgetInjected) {
                    [self evaluateJavaScript:widgetStringValue];
                    fieldsString = [self evaluateJavaScript:@"window.PopWidgetInterface.getFields()"];
                }
                [self startFillProcess:fieldsString];
            });
            
            // Then try to download latest widget from remote
            if ([self shouldUpdateWidget]) {
                NSHTTPURLResponse *response = nil;
                NSError *error = nil;
                NSData *data = [self downloadWidgetData:&response error:&error];
                [self resolveWidgetToStringWithData:data downloadResponse:response error:error];
            }
        }
    });
}

- (NSData *)fillrPayloadFromFieldsJson:(id)json
{
    NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *result = [[NSJSONSerialization JSONObjectWithData:objectData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil] mutableCopy];
    
    if ([result isKindOfClass:[NSDictionary class]]) {
        
        [result setObject:urlScheme ? urlScheme : @"fillrbrowser" forKey:@"returnAppDomain"];
        
        // Pass through sdkversion and dev key so these can be used in analytics Trello #339
        [result setObject:kFillrSDKVersion forKey:@"sdkversion"];
        [result setObject:devKey forKey:@"devkey"];
        [result setObject:secretKey forKey:@"secretkey"];
        
        NSError *error;
        return [NSJSONSerialization dataWithJSONObject:result
                                               options:NSJSONWritingPrettyPrinted
                                                 error:&error];
    }
    
    return nil;
}

- (BOOL)deferFillrRequestWithFields:(id)json
{
    NSData * jsonData = [self fillrPayloadFromFieldsJson:json];
    
    if (!jsonData) {
        return false;
    }
    
    UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
    appPasteBoard.persistent = YES;
    [appPasteBoard setData:jsonData forPasteboardType:@"com.fillr.browsersdk.metadata"];
    
    return true;
}

- (void)createFillrRequestWithFields:(id)json
{
    NSData *jsonData = [self fillrPayloadFromFieldsJson:json];
    
    if (!jsonData) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(fillrStateChanged:currentWebView:)]) {
        [self.delegate fillrStateChanged:FillrStateOpenApp currentWebView:webView];
    }
    
    NSString *result64 = [jsonData base64EncodedUrlString];
    NSString *urlString = [NSString stringWithFormat:@"fillr://mapping?metadata=%@&sdkversion=%@&devkey=%@", result64, kFillrSDKVersion, devKey];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)showFillrAlert:(BOOL)hasResult {
    BOOL hasFillrInstalled = [self hasFillrInstalled];
    
    NSString *alertTitle = nil;
    if (!self.isDolphin) {
        if (!self.fillProvider && !hasFillrInstalled && browserName) {
            alertTitle = [NSString stringWithFormat:kString_Autofill_By_Fillr, browserName];
        } else {
            alertTitle = kString_Secure_Autofill_By_Fillr;
        }
    }
    
    NSString *alertMessage = nil;
    if (self.isDolphin) {
        alertMessage = kString_Install_Description;
    } else {
        alertMessage = kString_Fillr_Introduction;
    }
    
    NSString *installButtonText = nil;
    NSString *cancelButtonText = nil;
    if (self.isDolphin) {
        installButtonText = kString_Install_Now;
        cancelButtonText = kString_Cancel;
    } else {
        if (!self.fillProvider && !hasFillrInstalled && browserName) {
            installButtonText = [NSString stringWithFormat:kString_Install_Fillr_Autofill_For, browserName];
        } else {
            installButtonText = kString_Install_Fillr;
        }
        cancelButtonText = kString_Not_Now;
    }
    
    FillrAlertView *anAlert = [[FillrAlertView alloc] initWithTitle:alertTitle
                                                            message:alertMessage
                                                           delegate:nil
                                                  cancelButtonTitle:installButtonText
                                                  otherButtonTitles:cancelButtonText, nil];
    
    anAlert.clickedButtonBlock = ^(NSInteger buttonIndex){
        if (buttonIndex == 0) {
            if (!hasResult) {
                // Paste return url
                UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
                appPasteBoard.persistent = YES;
                [appPasteBoard setData:[urlScheme dataUsingEncoding:NSUTF8StringEncoding] forPasteboardType:@"com.fillr.browsersdk.returndomain"];
            }
            
            [self installFillr];
        }
    };
    
    [anAlert show];
}


- (void)whatsthisTapped:(id)sender {
    UIWindow *theWindow = [[UIApplication sharedApplication] keyWindow];
    [theWindow endEditing:YES];
    
    [self showFillrAlert:false];
}

- (NSString *)evaluateJavaScript:(NSString *)javaScriptString {
    if ([WKWebView class] && [webView isKindOfClass:[WKWebView class]]) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block NSString *evaluateResult = nil;
        [(WKWebView *)webView evaluateJavaScript:javaScriptString completionHandler:^(id result, NSError *error) {
            if (!error) {
                evaluateResult = (NSString *)result;
            }
            dispatch_semaphore_signal(semaphore);
        }];
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        }
        //dispatch_release(semaphore);
        return evaluateResult;
    } else if ([webView isKindOfClass:[UIWebView class]]) {
        return [(UIWebView *)webView stringByEvaluatingJavaScriptFromString:javaScriptString];
    } else {
        return nil;
    }
}

- (NSDictionary *)parserQueryStringsForURL:(NSString *)urlString {
    NSString *queryString = @"";
    
    if ([urlString rangeOfString:@"?"].location != NSNotFound) {
        queryString = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:1];
    }
    
    NSArray *components = [queryString componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    for (NSString *component in components) {
        if ([component rangeOfString:@"="].location != NSNotFound) {
            NSArray *subcomponents = [component componentsSeparatedByString:@"="];
            [parameters setObject:[[subcomponents objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           forKey:[[[subcomponents objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lowercaseString]];
        }
    }
    
    return parameters;
}


- (void)fillFormWithFields:(NSString *)fields andPayload:(NSString *)payload {
    
    if (self.cloudBrowserDelegate) {
        [self.cloudBrowserDelegate onFillApproved:fields profileData:payload];
        return;
    }
    
    NSString *fillrFunctionWithParameters = [NSString stringWithFormat:@"window.PopWidgetInterface.populateWithMappings(JSON.parse('%@'), JSON.parse('%@'));", [self escapeJavascriptString:fields], [self escapeJavascriptString:payload]];
    [self evaluateJavaScript:fillrFunctionWithParameters];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(fillrStateChanged:currentWebView:)]) {
        [self.delegate fillrStateChanged:FillrStateFormFilled currentWebView:webView];
    }
}

- (NSString *)escapeJavascriptString:(NSString *)javascriptString {
    javascriptString = [javascriptString stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    javascriptString = [javascriptString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    javascriptString = [javascriptString stringByReplacingOccurrencesOfString:@"\\t" withString:@" "];
    javascriptString = [javascriptString stringByReplacingOccurrencesOfString:@"\\r" withString:@" "];
    javascriptString = [javascriptString stringByReplacingOccurrencesOfString:@"\\n" withString:@" "];
    return javascriptString;
}

- (void)disableForCurrentDomain {
    if (!disabledDomains) {
        disabledDomains = [NSMutableArray array];
    }
    
    NSString *newDomain = [self getCurrentDomain];
    if (newDomain) {
        for (NSString *disableDomain in disabledDomains) {
            if ([newDomain isEqualToString:disableDomain]) {
                return;
            }
        }
        [disabledDomains addObject:newDomain];
    }
    
    // If more than 3 times should prompt user that they can disable it in settings.
    if (disabledDomains.count > 0 && disabledDomains.count % 3 == 0) {
        FillrAlertView *anAlert = [[FillrAlertView alloc] initWithTitle:kString_Tip
                                                                message:kString_Disable_Autofill_Tip
                                                               delegate:nil
                                                      cancelButtonTitle:kString_Okay
                                                      otherButtonTitles:nil];
        [anAlert show];
    }
}

- (BOOL)isCurrentDomainDisabled {
    NSString *newDomain = [self getCurrentDomain];
    if (newDomain) {
        for (NSString *disableDomain in disabledDomains) {
            if ([newDomain isEqualToString:disableDomain]) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    // If user turned toolbar off by tapping dismiss button
    if ([self isDisabled]) {
        return;
    }
    
    if ([self isCurrentDomainDisabled]) {
        return;
    } else {
        if (disabledDomains) {
            [disabledDomains removeAllObjects];
        }
    }
    
    // If device OS lower then iOS 8
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        return;
    }
    
    BOOL hasFillrInstalled = [self hasFillrInstalled];
    // Do not display toolbar under horizontal if Fillr not installed
    if (!self.fillProvider && !hasFillrInstalled) {
        if (self.isDolphin && UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            return;
        }
    }
    
    if (webView) {
        if (![self hasFocus:webView]) {
            accessoryView.hidden = YES;
            return;
        }
        
        [self initializeUIElements];
        
        NSDictionary *info = [notification userInfo];
        [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
        
        UIView *keyboardAccessoryView;
        
        if (self.overlayInputAccessoryView) {
            keyboardAccessoryView = [self keyboardAccessoryView];
        }
        
        CGFloat accessoryViewHeight = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? 36.0f : 44.0f;
        if (self.overlayInputAccessoryView && keyboardAccessoryView) {
            accessoryView.frame = CGRectMake(keyboardAccessoryView.bounds.size.width / 4, 0.0f, keyboardAccessoryView.bounds.size.width / 2, accessoryViewHeight);
            accessoryView.backgroundColor = [UIColor clearColor];
            [keyboardAccessoryView addSubview:accessoryView];
        } else {
            UIWindow *theWindow = [[UIApplication sharedApplication] keyWindow];
            if ([self checkDomainChanged]) {
                accessoryView.frame = CGRectMake(0.0f, theWindow.bounds.size.height, theWindow.bounds.size.width, accessoryView.frame.size.height);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    UIWindow *theWindow = [[UIApplication sharedApplication] keyWindow];
                    accessoryView.frame = CGRectMake(0.0f, theWindow.bounds.size.height - keyboardFrame.size.height, theWindow.bounds.size.width, accessoryViewHeight);
                    [theWindow addSubview:accessoryView];
                    [UIView animateWithDuration:0.8f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        accessoryView.frame = CGRectMake(0.0f, theWindow.bounds.size.height - keyboardFrame.size.height - accessoryViewHeight, theWindow.bounds.size.width, accessoryViewHeight);
                        [theWindow addSubview:accessoryView];
                    } completion:^(BOOL finished) {
                        
                    }];
                    [accessoryView animateToolbarIconAndText];
                });
            } else {
                accessoryView.frame = CGRectMake(0.0f, theWindow.bounds.size.height - keyboardFrame.size.height - accessoryViewHeight, theWindow.bounds.size.width, accessoryViewHeight);
                [theWindow addSubview:accessoryView];
                if (fieldFocusCount >= 3) {
                    fieldFocusCount = 0;
                    [accessoryView fadeToolbarIconAndText];
                }
            }
        }
        
        accessoryView.hidden = !self.visible;
        [accessoryView layoutToolbarElements:self.overlayInputAccessoryView fillrInstalled:self.fillProvider || hasFillrInstalled];
        
        // Delegate method
        if (self.delegate && [self.delegate respondsToSelector:@selector(onFillrToolbarVisibilityChanged:isFillrInstalled:)]) {
            [self.delegate onFillrToolbarVisibilityChanged:self.visible isFillrInstalled:hasFillrInstalled];
        }
        
        if (self.fillProvider) {
            [self.fillProvider onFillrToolbarShown];
        }
    }
}

- (NSString *)getCurrentDomain {
    NSString *newDomain = nil;
    if ([WKWebView class] && [webView isKindOfClass:[WKWebView class]]) {
        newDomain = [((WKWebView *)webView).URL host];
    } else if ([webView isKindOfClass:[UIWebView class]]) {
        newDomain = [((UIWebView *)webView).request.URL host];
    } else {
        newDomain = nil;
    }
    return newDomain;
}

- (BOOL)checkDomainChanged {
    NSString *newDomain = [self getCurrentDomain];
    
    if (newDomain) {
        NSString *oldDomain = currentDomain;
        currentDomain = newDomain;
        if (oldDomain) {
            return ![newDomain isEqualToString:oldDomain];
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

- (BOOL)hasFocus:(UIView *)view {
    if ([view isFirstResponder]) return YES;
    
    for (UIView *subView in [view subviews]) {
        if ([self hasFocus:subView]) {
            return YES;
        }
    }
    
    return NO;
}

- (UIView *)keyboardAccessoryView {
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if (![[testWindow class] isEqual : [UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    NSString *periHView = [NSString stringWithFormat:@"<%@%@%@", @"UI", @"Peripheral", @"HostView"];
    NSString *inputSCView = [NSString stringWithFormat:@"<%@%@%@%@", @"UI", @"Input", @"Set", @"ContainerView"];
    NSString *webFormAcc = [NSString stringWithFormat:@"<%@%@%@", @"UI", @"WebForm", @"Accessory"];
    // Locate UIWebFormView.
    for (UIView *possibleFormView in [keyboardWindow subviews]) {
        if ([[possibleFormView description] hasPrefix:periHView] || [[possibleFormView description] hasPrefix:inputSCView]) {
            for (UIView* peripheralView in possibleFormView.subviews) {
                for (UIView* peripheralView_sub in peripheralView.subviews) {
                    // the accessory bar
                    if ([[peripheralView_sub description] hasPrefix:webFormAcc]) {
                        return peripheralView_sub;
                    }
                }
            }
        }
    }
    return nil;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIWindow *theWindow = [[UIApplication sharedApplication] keyWindow];
    accessoryView.frame = CGRectMake(0.0f, theWindow.bounds.size.height, theWindow.bounds.size.width, accessoryView.frame.size.height);
    accessoryView.hidden = YES;
    
    // Delegate method
    if (self.delegate && [self.delegate respondsToSelector:@selector(onFillrToolbarVisibilityChanged:isFillrInstalled:)]) {
        [self.delegate onFillrToolbarVisibilityChanged:NO isFillrInstalled:[self hasFillrInstalled]];
    }
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)isDisabled
{
    return ![self enabled];
}

// Used for testing
- (FillrAutofillInputAccessoryView *)getAcccessoryView
{
    return accessoryView;
}

- (void)dealloc {
    [self removeObservers];
}

@end
