//
//  BaseTableViewCell.h
//  POP
//
//  Created by Alex Bin Zhao on 3/06/2016.
//  Copyright © 2016 POP TECH Pty. Ltd. All rights reserved.
//

#import "Field.h"

typedef enum {
    FillrCellStatusNormal = 0,
    FillrCellStatusEditing = 1,
    FillrCellStatusGroupEditing = 2,
    FillrCellStatusGrayedOut = 3
} FillrCellStatus;

@interface CommonTableViewCell : UITableViewCell

@property (assign, nonatomic) FillrCellStatus status;
@property (strong, nonatomic) Field *field;

@property (assign, nonatomic) BOOL hideTick;
@property (assign, nonatomic) BOOL hideEdit;
@property (strong, nonatomic) IBOutlet UIImageView *radioButtonImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *maskLabel;
@property (strong, nonatomic) IBOutlet UILabel *validationLabel;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet UILabel *changeLabel;
@property (strong, nonatomic) IBOutlet UILabel *saveToProfileLabel;
@property (strong, nonatomic) IBOutlet UITextField *valueField;
@property (strong, nonatomic) IBOutlet UIView *groupElementsView;
@property (strong, nonatomic) IBOutlet UIView *tickSeparator;
@property (strong, nonatomic) IBOutlet UIButton *tickButton;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIImageView *fieldImageView;
@property (strong, nonatomic) IBOutlet UIButton *pasteFromButton;
@property (strong, nonatomic) IBOutlet UIImageView *accessoryImageView;
@property (strong, nonatomic) IBOutlet UIImageView *changeArrowImageView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fieldImageLabelTopSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *valueFieldLeadingSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *valueFieldTopSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *changeLabelTopSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *changeArrowTopSpace;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomBorderLeadingSpace;

- (void)setTicked:(BOOL)ticked;
- (void)setSelectionState:(BOOL)selected;
- (void)setStatus:(FillrCellStatus)status;

@end
