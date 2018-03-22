//
//  FillViewController.h
//  SafariExtension
//
//  Created by Alex Bin Zhao on 5/12/2014.
//  Copyright (c) 2014 POP TECH Pty. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface FillViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *barView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinnerView;
@property (nonatomic, assign) BOOL isFromSignup;
@property (nonatomic, strong) NSArray *popArray;

- (void)processFieldsFromBrowser:(NSDictionary *)fields;
- (void)launchFillrApp;
- (NSArray *)checkMissingFields:(NSArray *)sourceArray;
- (void)postMappingRequestPerformance:(BOOL)filled payload: (NSDictionary *)payload;
- (NSMutableDictionary *)getUserProfile:(NSDictionary *)payload;
- (void)postMappingRequestFilledPerformance:(NSDictionary*)payload;
- (void)postMappingRequestCancelledPerformance;

- (UIView *)arraySelectionView;

- (IBAction)cancel;

@end
