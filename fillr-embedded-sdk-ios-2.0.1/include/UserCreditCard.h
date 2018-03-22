//
//  UserCreditCard.h
//  POP
//
//  Created by Alex Bin Zhao on 6/7/17.
//  Copyright © 2017 POP TECH Pty. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserCreditCard : NSObject

@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *expiry;
@property (nonatomic, strong) NSString *ccv;
@property (nonatomic, strong) NSString *nameOnCard;

@end
