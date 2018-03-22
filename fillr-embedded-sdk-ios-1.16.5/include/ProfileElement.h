//
//  GroupHeading.h
//  POP
//
//  Created by Alex Bin Zhao on 28/01/2015.
//  Copyright (c) 2015 POP TECH Pty. Ltd. All rights reserved.
//

#import "Field.h"
#import "DataElement.h"
#import "ProfileDataSource.h"

@protocol ProfileDataSource;

@interface ProfileElement : NSObject<DataElement>

@property (nonatomic, strong) id node;
@property (nonatomic, assign) BOOL createNew;
@property (nonatomic, assign) NSUInteger arrayIndex;
@property (nonatomic, assign) NSUInteger arrayInternalIndex;

- (id)initWithProfileDataSource:(id<ProfileDataSource>)dataSource;

- (BOOL)isArrayObject;

- (NSString *)displayName;
- (NSString *)nodeName;
- (NSString *)parentNamespace;
- (NSString *)parentArrayObjectNamespace;
- (NSString *)schemaNamespace;
- (NSString *)objectNamespace;
- (NSString *)profileNamespace;
- (id)value;

@end
