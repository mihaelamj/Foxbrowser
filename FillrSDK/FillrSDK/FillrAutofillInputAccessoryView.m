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

#import "FillrAutofillInputAccessoryView.h"
#import "Fillr.h"
#import "FillrAlertView.h"

#define kDismissButtonTappedTimes (@"DismissButtonTappedTimes")
#define kBarTextPadWidth (5.0f)

@interface FillrAutofillInputAccessoryView () {

    // UI Elements
    UIImageView *fillrIconView;
    UIButton *autofillButton;
    UIButton *dismissButton;
    UIView *breakLine;
    UIButton *whatsthisButton;
    
    CGFloat autofillTextWidth;

    BOOL alreadyTappedAutofill;
}
@end

@implementation FillrAutofillInputAccessoryView

@synthesize brandedToolbarIcon = _brandedToolbarIcon;
@synthesize toolbarPromptText = _toolbarPromptText;

- (id)initWithFrame:(CGRect)frame toolbarText:(NSString *)toolbarText isDolphin:(BOOL)isDolphin
{
    self = [self initWithFrame:frame];
    
    if (self) {
        self.isDolphinStyled = isDolphin;
        self.toolbarPromptText = toolbarText;
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

- (void)setToolbarPromptText:(NSString *)toolbarPromptText
{
    _toolbarPromptText = toolbarPromptText;
    [autofillButton setTitle:toolbarPromptText forState:UIControlStateNormal];
    
    UIFont * font = [UIFont systemFontOfSize:14.0f];
    
    // Ensure we resize the button any time the text changes
    if ([_toolbarPromptText respondsToSelector:@selector(sizeWithAttributes:)]) {
        autofillTextWidth = [_toolbarPromptText sizeWithAttributes:@{NSFontAttributeName:font}].width + kBarTextPadWidth;
    } else {
        autofillTextWidth = [_toolbarPromptText sizeWithFont:font].width + kBarTextPadWidth;
    }
    
    CGRect orig = autofillButton.frame;
    orig.size.width = autofillTextWidth;
}

- (void)setBrandedToolbarIcon:(UIImage *)brandedToolbarIcon
{
    _brandedToolbarIcon = brandedToolbarIcon;
}

- (UIImage *)brandedToolbarIcon
{
    if (_brandedToolbarIcon) {
        return _brandedToolbarIcon;
    }
    
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"FillrSDKBundle" withExtension:@"bundle"];
    if (bundleURL) {
        if (self.isDolphinStyled) {
            NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
            NSString *iconName = @"fillr_icon";
            return [UIImage imageWithContentsOfFile:[bundle pathForResource:iconName ofType:@"png"]];
        } else {
            NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
            NSString *iconName = @"fillr_sdk_icon";
            return [UIImage imageWithContentsOfFile:[bundle pathForResource:iconName ofType:@"png"]];
        }
    }
    return nil;
}

- (void)setup
{
#ifdef FillrApp
    self.backgroundColor = [Fillr sharedInstance].toolbarThemeColor ? [Fillr sharedInstance].toolbarThemeColor : [UIColor colorWithRed:0.94f green:0.95f blue:0.95f alpha:1.0f];
#else
    self.backgroundColor = [UIColor colorWithRed:0.9453f green:0.9453f blue:0.9453f alpha:1.0f];
#endif
    self.clipsToBounds = YES;
    
    UIImage *fillrIconImage = self.brandedToolbarIcon;
    
    autofillTextWidth = 138.0f;
    UIFont *textFont = [UIFont systemFontOfSize:14.0f];
    // Ensure we resize the button any time the text changes
    if ([self.toolbarPromptText respondsToSelector:@selector(sizeWithAttributes:)]) {
        autofillTextWidth = [self.toolbarPromptText sizeWithAttributes:@{NSFontAttributeName:textFont}].width + kBarTextPadWidth;
    } else {
        autofillTextWidth = [self.toolbarPromptText sizeWithFont:textFont].width + kBarTextPadWidth;
    }
    
    CGFloat leftMargin = 10.0f;
    if (self.buttonMiddleCentered) {
        leftMargin = (self.bounds.size.width - fillrIconView.frame.size.width - 3.0f - autofillTextWidth) / 2;
    }
    fillrIconView = [[UIImageView alloc] initWithFrame:CGRectMake(leftMargin, (self.bounds.size.height - fillrIconImage.size.height) / 2, fillrIconImage.size.width, fillrIconImage.size.height)];
    if (self.buttonMiddleCentered) {
        fillrIconView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    } else {
        fillrIconView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    fillrIconView.backgroundColor = [UIColor clearColor];
    fillrIconView.contentMode = UIViewContentModeCenter;
    fillrIconView.image = fillrIconImage;
    [self addSubview:fillrIconView];
    
    leftMargin = fillrIconView.frame.origin.x + fillrIconView.frame.size.width;
    autofillButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [autofillButton addTarget:self action:@selector(autofillTouchDown:) forControlEvents:UIControlEventTouchDown];
    [autofillButton addTarget:self action:@selector(autofillTapped:) forControlEvents:UIControlEventTouchUpInside];
    autofillButton.frame = CGRectMake(leftMargin, (self.frame.size.height - 24.0f) / 2, autofillTextWidth, 24.0f);
    if (self.buttonMiddleCentered) {
        autofillButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    } else {
        autofillButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    [autofillButton setBackgroundColor:[UIColor clearColor]];
    [autofillButton setTitle:self.toolbarPromptText forState:UIControlStateNormal];
    [autofillButton setTitleColor:[Fillr sharedInstance].toolbarTextColor ? [Fillr sharedInstance].toolbarTextColor : [UIColor blackColor] forState:UIControlStateNormal];
    [autofillButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateHighlighted];
    autofillButton.titleLabel.font = textFont;
    autofillButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [autofillButton.titleLabel sizeToFit];
    [self addSubview:autofillButton];
    
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"FillrSDKBundle" withExtension:@"bundle"]];
    UIImage *dismissIconImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"fillr_sdk_keyboard_arrow_down" ofType:@"png"]];
    dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dismissButton addTarget:self action:@selector(dismissTapped:) forControlEvents:UIControlEventTouchUpInside];
    dismissButton.frame = CGRectMake(self.frame.size.width - 42.0f, 0.0f, 42.0f, self.bounds.size.height);
    dismissButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    dismissButton.contentMode = UIViewContentModeCenter;
    [dismissButton setImage:dismissIconImage forState:UIControlStateNormal];
    [self addSubview:dismissButton];
    
    breakLine = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 43.0f, 8.0f, 1.0f, self.frame.size.height - 16.0f)];
    breakLine.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    breakLine.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    [self addSubview:breakLine];
    
    whatsthisButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [whatsthisButton addTarget:self action:@selector(autofillTapped:) forControlEvents:UIControlEventTouchUpInside];
    whatsthisButton.frame = CGRectMake(self.frame.size.width - 88.0f, (self.frame.size.height - 40.0f) / 2, 42.0f, 40.0f);
    whatsthisButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [whatsthisButton setTitle:@"?" forState:UIControlStateNormal];
    [whatsthisButton setTitleColor:[UIColor colorWithWhite:0.5f alpha:1.0f] forState:UIControlStateNormal];
    whatsthisButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self addSubview:whatsthisButton];
}

- (void)animateToolbarIconAndText {
    fillrIconView.alpha = 0.0f;
    fillrIconView.transform = CGAffineTransformMakeTranslation(-fillrIconView.frame.size.width, 0.0f);
    autofillButton.alpha = 0.0f;
    autofillButton.transform = CGAffineTransformMakeTranslation(0.0f, fillrIconView.frame.size.width / 10);
    [UIView animateWithDuration:0.8f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        fillrIconView.alpha = 1.0f;
        fillrIconView.transform = CGAffineTransformIdentity;
        autofillButton.alpha = 1.0f;
        autofillButton.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)fadeToolbarIconAndText {
    fillrIconView.alpha = 1.0f;
    autofillButton.alpha = 1.0f;
    [UIView animateWithDuration:1.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        fillrIconView.alpha = 0.0f;
        autofillButton.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fillrIconView.alpha = 1.0f;
            autofillButton.alpha = 1.0f;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)autofillTouchDown:(id)sender {
    fillrIconView.alpha = 0.6f;
}

- (void)autofillTapped:(id)sender {
    if (!alreadyTappedAutofill) {
        alreadyTappedAutofill = YES;
        
        fillrIconView.alpha = 1.0f;
        [self.delegate autofillTapped:sender];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        alreadyTappedAutofill = NO;
    });
}

- (void)dismissTapped:(id)sender {
    // Dismiss the bar
    self.hidden = YES;
    
    if (self.isDolphinStyled) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger tappedTimes = [defaults integerForKey:kDismissButtonTappedTimes];
        tappedTimes++;
        [defaults setInteger:tappedTimes forKey:kDismissButtonTappedTimes];
        
        // Pop up the 4th time
        if (tappedTimes > 0 && tappedTimes % 4 == 0) {
            // Delegate method
            if ([Fillr sharedInstance].delegate && [[Fillr sharedInstance].delegate respondsToSelector:@selector(onFillrDismissThresholdExceeded)]) {
                [[Fillr sharedInstance].delegate onFillrDismissThresholdExceeded];
            }
        }
    } else {
        [[Fillr sharedInstance] disableForCurrentDomain];
    }
    
    if ([Fillr sharedInstance].fillProvider) {
        [[Fillr sharedInstance].fillProvider onFillrToolbarDismiss];
    }
    
    // Notify delegate method
    if ([Fillr sharedInstance].delegate && [[Fillr sharedInstance].delegate respondsToSelector:@selector(onFillrToolbarVisibilityChanged:isFillrInstalled:)]) {
        [[Fillr sharedInstance].delegate onFillrToolbarVisibilityChanged:NO isFillrInstalled:[[Fillr sharedInstance] hasFillrInstalled]];
    }
}

- (void)layoutToolbarElements:(BOOL)overlayInputAccessoryView fillrInstalled:(bool)fillrInstalled {
    // Limit autofill text width
    if (autofillTextWidth > (whatsthisButton.hidden ? dismissButton.frame.origin.x : whatsthisButton.frame.origin.x) - (fillrIconView.frame.origin.x + fillrIconView.frame.size.width)) {
        autofillTextWidth = (whatsthisButton.hidden ? dismissButton.frame.origin.x : whatsthisButton.frame.origin.x) - (fillrIconView.frame.origin.x + fillrIconView.frame.size.width);
    }
    
    float leftMargin = 10.0f;
    // Position elements in middle if overlayInputAccessoryView
    if (overlayInputAccessoryView || self.buttonMiddleCentered) {
        if (self.bounds.size.width > fillrIconView.frame.size.width + 3.0f + autofillTextWidth || self.buttonMiddleCentered) {
            leftMargin = (self.bounds.size.width - fillrIconView.frame.size.width - 3.0f - autofillTextWidth) / 2;
        } else {
            leftMargin = 0.0f;
        }
    }
    
    fillrIconView.frame = CGRectMake(leftMargin, fillrIconView.frame.origin.y, fillrIconView.frame.size.width, fillrIconView.frame.size.height);
    
    leftMargin = fillrIconView.frame.origin.x + fillrIconView.frame.size.width + 3.0f;
    autofillButton.frame = CGRectMake(leftMargin, (self.frame.size.height - 24.0f) / 2, autofillTextWidth, 24.0f);
    
    if (fillrInstalled || self.isDolphinStyled) {
        whatsthisButton.hidden = YES;
    } else {
        if (overlayInputAccessoryView) {
            whatsthisButton.hidden = YES;
        } else {
            whatsthisButton.hidden = NO;
        }
    }
    
    if (overlayInputAccessoryView) {
        dismissButton.hidden = YES;
        breakLine.hidden = YES;
    } else {
        dismissButton.hidden = NO;
        breakLine.hidden = NO;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
