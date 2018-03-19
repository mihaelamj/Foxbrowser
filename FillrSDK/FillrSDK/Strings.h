//
//  Strings.h
//  FillrSDK
//
//  Created by Alex Bin Zhao on 28/10/2016.
//  Copyright © 2016 Pop Tech Pty. Ltd. All rights reserved.
//

#define LocalizedString(stringValue) \
[[SDKBundleManager sdkBundle] localizedStringForKey:stringValue value:@"" table:nil]

#define kString_Done (LocalizedString(@"Done"))
#define kString_Cancel (LocalizedString(@"Cancel"))
#define kString_Secure_Autofill_By_Fillr (LocalizedString(@"Secure Autofill by Fillr"))
#define kString_Fillr_Introduction (LocalizedString(@"Fillr is the most secure & accurate autofill in the world and it’s free. Setup takes under a minute and you’ll be returned to this page."))
#define kString_Install_Slogan (LocalizedString(@"Install Fillr autofill and save me time"))
#define kString_Fill_Form_Manually (LocalizedString(@"Not now, I'd like to fill this form manually"))
#define kString_Use_Secure_Autofill (LocalizedString(@"Use Secure Autofill"))
#define kString_Autofill_This_Form (LocalizedString(@"Autofill This Form"))
#define kString_Install_Fillr (LocalizedString(@"Install Fillr"))
#define kString_Not_Now (LocalizedString(@"Not now"))
#define kString_Whats_this (LocalizedString(@"What's this"))
#define kString_Install_Autofill (LocalizedString(@"Install autofill for %@"))
#define kString_Autofill_By_Fillr (LocalizedString(@"%@ Autofill by Fillr"))
#define kString_Install_Fillr_Autofill_For (LocalizedString(@"Install Fillr, Autofill for %@"))

#define kString_Tip (LocalizedString(@"Tip"))
#define kString_Disable_Autofill_Tip (LocalizedString(@"You can disable the autofill toolbar in Settings"))
#define kString_Okay (LocalizedString(@"Okay"))

#define kString_Install_Autofill_for_Dolphin (LocalizedString(@"Install Autofill for Dolphin"))
#define kString_Install_Now (LocalizedString(@"Install Now"))
#define kString_Install_Description (LocalizedString(@"You are about to install the most accurate and secure autofill app Fillr. Continue?"))
