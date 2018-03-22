//
//  UserTelephoneNumber.h
//  POP
//
//  Created by Alex Bin Zhao on 6/7/17.
//  Copyright © 2017 POP TECH Pty. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserTelephoneNumber : NSObject

@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *areaCode;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *extension;

@end
