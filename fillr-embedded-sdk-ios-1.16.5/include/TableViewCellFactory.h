//
//  TableViewCellFactory.h
//  POP
//
//  Created by Alex Bin Zhao on 3/06/2016.
//  Copyright © 2016 POP TECH Pty. Ltd. All rights reserved.
//

#import "CommonTableViewCell.h"

@protocol TableViewCellFactory<NSObject>

- (CommonTableViewCell *)createNewTableViewCell;

@end
