//
//  UserDataAccessor.h
//  POP
//
//  Created by Alex Bin Zhao on 6/7/17.
//  Copyright © 2017 POP TECH Pty. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserCellPhoneNumber.h"
#import "UserTelephoneNumber.h"
#import "UserCreditCard.h"
#import "UserAddress.h"

@interface UserDataAccessor : NSObject

- (id)initWithProfileDataSource:(id)dataSource;
- (void)importFirstName:(NSString *)firstName;
- (void)importLastName:(NSString *)lastName;
- (void)importEmails:(NSArray *)emails;
- (void)importCellPhoneNumbers:(NSArray *)userCellPhoneNumbers;
- (void)importTelephoneNumbers:(NSArray *)userTelephoneNumbers;
- (void)importCreditCards:(NSArray *)creditCards;
- (void)importAddresses:(NSArray *)addresses;
- (void)importRawAddresses:(NSArray *)addresses;
- (void)importRawAddresses:(NSArray *)addresses completion:(void (^)(BOOL allSuccessful))completion;

@end
