//
//  TreeNode.h
//  PopAnything.com
//
//  Created by Anita Santoso on 16/11/12.
//  Copyright (c) 2012 POP TECH Pty. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TreeNode
//@required
@optional

- (void)addNode:(id<TreeNode>)object;
- (NSArray*)nodes;
- (BOOL)hasNodes;
- (id)findNode:(id<TreeNode>)object;

- (NSString*)description;
- (NSString*)displayName;
- (NSString*)name;
- (NSString*)nodeNamespace;
@end
