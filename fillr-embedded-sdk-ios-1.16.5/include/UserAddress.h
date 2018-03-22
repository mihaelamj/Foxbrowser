//
//  UserAddress.h
//  POP
//
//  Created by Alex Bin Zhao on 6/7/17.
//  Copyright © 2017 POP TECH Pty. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAddress : NSObject

@property (nonatomic, strong) NSString *poBox;
@property (nonatomic, strong) NSString *levelNumber;
@property (nonatomic, strong) NSString *unitNumber;
@property (nonatomic, strong) NSString *streetNumber;
@property (nonatomic, strong) NSString *streetName;
@property (nonatomic, strong) NSString *streetType;
@property (nonatomic, strong) NSString *quadrant;
@property (nonatomic, strong) NSString *suburb;
@property (nonatomic, strong) NSString *administrativeArea;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *buildingName;
@property (nonatomic, strong) NSString *companyName;

@end
