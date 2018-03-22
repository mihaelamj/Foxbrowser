//
//  FieldNode.h
//  PopAnything.com
//
//  Created by Anita Santoso on 12/10/12.
//  Copyright (c) 2012 POP TECH Pty. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TreeNode.h"

typedef enum {
    FieldTypeEnumerated,
    FieldTypeString,
    FieldTypeInteger,
    FieldTypeDate, /** day, month, year **/
    FieldTypeMonthYear, /** month and year **/
    FieldTypeTime,
    FieldTypeImage,
    FieldTypeEmail, /** basically text field with email keyboard? **/
    FieldTypeURL
} FieldType;

typedef enum {
    NoHint,
    Numeric,
    Email
} KeyboardHint;

typedef enum {
    None,
    First,All
} KeyboardCap;

@interface Field : NSObject<TreeNode>

@property NSInteger index;
@property (nonatomic, strong) NSString *fieldName;
@property (nonatomic, strong) NSString *fieldNamespace;
@property (nonatomic, strong) NSString *fieldDisplayName;
@property (nonatomic, strong) NSString *fieldFullDisplayName;
@property (nonatomic, strong) NSString *fieldDescription;
@property (nonatomic, strong) NSString *fieldTypeString;
@property (nonatomic, assign) FieldType fieldType;
@property (nonatomic, assign) BOOL enumType;

@property (nonatomic, assign) BOOL isFieldOfArrayType;
@property (nonatomic, strong) NSString *parentArrayNamespace;
@property (nonatomic, assign) BOOL isPrimaryKey;
@property (nonatomic, assign) BOOL hasMask;
@property (nonatomic, assign) int maskLength;
@property (nonatomic, assign) BOOL hasMaxLength;
@property (nonatomic, assign) int maxLength;
@property (nonatomic, assign) BOOL dashboardStat;
@property (nonatomic, assign) BOOL incompletePrompt;
@property (nonatomic, assign) BOOL history;
@property (nonatomic, assign) BOOL hiddenInCategories;
@property (nonatomic, assign) int firstYear;
@property (nonatomic, strong) NSString *parentNamespace;

@property (nonatomic, assign) KeyboardHint keyboardType;
@property (nonatomic, strong) NSString *keyboardTypeString;

@property (nonatomic, assign) KeyboardCap  keyboardCap;
@property (nonatomic, strong) NSString *keyboardCapString;

- (FieldType) fieldType;
- (KeyboardHint)getKeyboardHintType;
- (KeyboardCap)getKeyboardCaps;

@end
