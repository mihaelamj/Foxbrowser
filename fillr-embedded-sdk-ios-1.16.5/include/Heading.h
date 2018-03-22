//
//  Heading.h
//  PopAnything.com
//
//  Created by Anita Santoso on 16/11/12.
//  Copyright (c) 2012 POP TECH Pty. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TreeNode.h"

@interface Heading : NSObject<TreeNode>

@property (nonatomic, assign) BOOL isArrayType;
@property (nonatomic, assign) BOOL isMutableKeyArray;
@property (nonatomic, assign) BOOL isObjectInArray;
@property (nonatomic, assign) BOOL isFieldOfArrayType;// For combined field
@property (nonatomic, strong) NSString *primaryKeyNamespace;
@property (nonatomic, strong) NSString *parentArrayNamespace;// For combined field
@property (nonatomic, strong) NSString *headingNamespace;
@property (nonatomic, strong) NSNumber *fieldCount;
@property (nonatomic, strong) NSString *headingName;
@property (nonatomic, strong) NSString *headingDescription;
@property (nonatomic, strong) NSString *headingDisplayName;
@property (nonatomic, strong) NSString *headingFullDisplayName;
@property (nonatomic, strong) NSString *parentNamespace;
@property (nonatomic, assign) BOOL dashboardStat;
@property (nonatomic, assign) BOOL incompletePrompt;
@property (nonatomic, assign) BOOL history;
@property (nonatomic, assign) BOOL hiddenInCategories;
@property (nonatomic, assign) int firstYear;

@end
