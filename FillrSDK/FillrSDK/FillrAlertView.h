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

@import Foundation;
@import UIKit;


typedef void (^WillPresentBlock)(void);
typedef void (^DidPresentBlock)(void);
typedef void (^DidCancelBlock)(void);
typedef void (^ClickedButtonBlock)(NSInteger);
typedef void (^WillDismissBlock)(NSInteger);
typedef void (^DidDismissBlock)(NSInteger);


@interface FillrAlertView : UIAlertView <UIAlertViewDelegate>

@property (nonatomic, copy) WillPresentBlock willPresentBlock;
@property (nonatomic, copy) DidPresentBlock didPresentBlock;
@property (nonatomic, copy) DidCancelBlock didCancelBlock;
@property (nonatomic, copy) ClickedButtonBlock clickedButtonBlock;
@property (nonatomic, copy) WillDismissBlock willDismissBlock;
@property (nonatomic, copy) DidDismissBlock didDismissBlock;

@end
