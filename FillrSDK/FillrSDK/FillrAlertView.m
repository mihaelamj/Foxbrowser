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

#import "FillrAlertView.h"


@implementation FillrAlertView


- (void) show
{
    self.delegate = self;
    [super show];
}


- (void) willPresentAlertView:(UIAlertView *)alertView
{
    if( self.willPresentBlock != nil ) {
        self.willPresentBlock();
    }
}


- (void) didPresentAlertView:(UIAlertView *)alertView
{
    if( self.didPresentBlock != nil ) {
        self.didPresentBlock();
    }
}


- (void) alertViewCancel:(UIAlertView *)alertView
{
    if( self.didCancelBlock != nil ) {
        self.didCancelBlock();
    }
}


- (void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( self.clickedButtonBlock != nil ) {
        self.clickedButtonBlock(buttonIndex);
    }
}


- (void) alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( self.willDismissBlock != nil ) {
        self.willDismissBlock(buttonIndex);
    }
}


- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( self.didDismissBlock != nil ) {
        self.didDismissBlock(buttonIndex);
    }
}


@end
