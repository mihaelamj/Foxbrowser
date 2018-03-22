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

#import <UIKit/UIKit.h>

@protocol FillrAutofillEbatesCoachmarkDelegate <NSObject>

- (void)coachmarkTapped:(id)sender;
- (void)dismissCoachmark;
- (void)backgroundTapped; //Required if the user taps on the screen to the right of the toolbar

@end

@interface FillrAutofillEbatesCoachmarkView : UIView

@property (weak) id <FillrAutofillEbatesCoachmarkDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
@end
