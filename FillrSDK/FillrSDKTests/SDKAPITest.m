//
//  SDKAPITest.m
//  FillrSDK
//
//  Created by CTO on 29/02/2016.
//  Copyright © 2016 Pop Tech Pty. Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Fillr.h"
#import "FillrAutofillInputAccessoryView.h"

@interface PhotonFillrInterfaceMock : NSObject <FillrCloudBrowserDelegate>

- (void)onFillButtonClicked:(id)sender;
- (void)onFillApproved:(NSString *)mappings profileData:(NSString *)profileData;

@property bool fillButtonClickedCalled;
@property bool fillApprovedCalled;

@end

@implementation PhotonFillrInterfaceMock

- (void)onFillButtonClicked:(id)sender
{
    self.fillButtonClickedCalled = true;
}

- (void)onFillApproved:(NSString *)mappings profileData:(NSString *)profileData
{
    self.fillApprovedCalled = true;
}

@end


@interface Fillr (Testing)

- (NSData *) downloadWidgetData:(NSHTTPURLResponse **)response error:(NSError **)error;
- (void)fillFormWithFields:(NSString *)fields andPayload:(NSString *)payload;
- (FillrAutofillInputAccessoryView *)getAcccessoryView;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)initializeUIElements;

@end

@interface SDKAPITest : XCTestCase

@end

@implementation SDKAPITest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetWidget {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    Fillr * f = [Fillr sharedInstance];
    NSHTTPURLResponse * response = nil;
    NSError * error = nil;
    NSData * widget = [f downloadWidgetData:&response error:&error];
    NSLog(@"%@", widget);
    XCTAssertGreaterThan(widget.length, 0);
    XCTAssertNotNil(response);
}

- (void) testSetEnabled
{
    Fillr * f = [Fillr sharedInstance];
    [f setEnabled:true];
    XCTAssertTrue(f.enabled);
    XCTAssertTrue([f enabled]);
    [f setEnabled:false];
    XCTAssertFalse(f.enabled);
}

- (void) testCloudDelegate
{
    Fillr * f = [Fillr sharedInstance];
    [f setEnabled:true];
    PhotonFillrInterfaceMock * o = [[PhotonFillrInterfaceMock alloc] init];
    f.cloudBrowserDelegate = o;
    
    XCTAssertFalse(o.fillApprovedCalled);
    XCTAssertFalse(o.fillButtonClickedCalled);
    
    [f autofillTapped:nil];
    
    XCTAssertTrue(o.fillButtonClickedCalled);
    
    [f fillFormWithFields:nil andPayload:nil];
    
    XCTAssertTrue(o.fillApprovedCalled);
}

- (void) testToolBarImageGetter
{
    Fillr * f = [Fillr sharedInstance];
    [f trackWebview:[[UIView alloc] init]];
    [f initializeUIElements];
    FillrAutofillInputAccessoryView * fv = [f getAcccessoryView];
    
    NSLog(@"%@", fv.brandedToolbarIcon);
    XCTAssertNotNil(fv.brandedToolbarIcon);
    
    [f setToolbarIcon:nil];
    
    fv = [f getAcccessoryView];
    
    XCTAssertNotNil(fv.brandedToolbarIcon);
}

- (void)testFillrSDKDeepLink {
    Fillr * fillr = [Fillr sharedInstance];
    // Use ebates dev key for testing
    [fillr initialiseWithDevKey:@"1ed4e880b0600a65bfbe8f001cf026a0" secretKey:@"" andUrlScheme:@""];
    
    XCTAssertEqual(fillr.integratedBrowser, IntegratedBrowser_Ebates);
    XCTAssertFalse(fillr.hasFillrInstalled);
}

@end
