//
//  DataElement.h
//  POP
//
//  Created by Alex Bin Zhao on 6/06/2016.
//  Copyright © 2016 POP TECH Pty. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataElement<NSObject>

- (id)node;
- (NSArray *)childNodes;
@property (nonatomic, assign) BOOL createNew;
- (NSUInteger)arrayIndex;
- (NSUInteger)arrayInternalIndex;

- (BOOL)isArrayObject;

- (NSString *)displayName;
- (NSString *)nodeName;
- (NSString *)parentNamespace;
- (NSString *)parentArrayObjectNamespace;
- (NSString *)schemaNamespace;
- (NSString *)objectNamespace;
- (NSString *)profileNamespace;
- (id)value;
- (BOOL)hasValue;

@end
