//
//  ProfileDetailsListView.h
//  POP
//
//  Created by Alex Bin Zhao on 1/06/2016.
//  Copyright © 2016 POP TECH Pty. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewCellFactory.h"
#import "DataElement.h"
#import "Field.h"
#import "ProfileDataSource.h"

@protocol ProfileDetailsListViewDelegate

- (UIView *)rootView;
- (UIView *)listViewHeader;
- (UIView *)listViewSectionHeader;
- (CGFloat)listViewSectionHeaderHeight;
- (CGFloat)listViewCellHeight;

- (id<TableViewCellFactory>)defaultTableViewCellFactory;
- (Heading *)listViewHeading;
- (NSArray *)elements;
- (NSString *)displayValueForElement:(id<DataElement>)element;
- (BOOL)hasValueForElement:(id<DataElement>)element;
- (BOOL)shouldShowAddNewButton;
- (BOOL)shouldShowDetailsArrow;
- (BOOL)isFillMode;
- (BOOL)isSelectionMode;
- (UIViewController *)containingController;
- (NSString *)fieldPlaceholderText:(id)node;

- (BOOL)isIndexTicked:(NSIndexPath *)indexPath;
- (BOOL)allowCopyArrayObject;
- (BOOL)allowChangeAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)allowEditAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)allowSelectAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)allowDeleteAtIndexPath:(NSIndexPath *)indexPath;

- (void)addNewObjectToArray;
- (void)removeObjectFromProfileArrayForRowIndex:(NSUInteger)rowIndex;
- (BOOL)shouldArrayObjectAtRowIndexBeDeleted:(NSUInteger)rowIndex;
- (void)editedElement:(id<DataElement>)element forField:(Field *)field atChildNodesPosition:(NSUInteger)childPosition newValue:(NSString *)newValue isBatchProcess:(BOOL)isBatchProcess;
- (void)persist;
- (void)selectedIndexPath:(NSIndexPath *)indexPath finishSelection:(BOOL)finishSelection;
- (void)showChildLevelOfProfileAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ProfileDetailsListView : UIView

@property (nonatomic, assign) id<ProfileDetailsListViewDelegate> delegate;
@property (nonatomic, assign) id<ProfileDataSource> dataSource;

- (id)initWithFrame:(CGRect)frame;
- (void)loadView;
- (void)reloadData;
- (void)addNewObjectToArray:(id)sender;
- (void)dismissKeyboardIfNecessary;
- (CGFloat) contentHeight;

@end
