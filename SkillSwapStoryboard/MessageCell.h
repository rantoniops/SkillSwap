//
//  MessageCell.h
//  SkillSwapStoryboard
//
//  Created by Thomas Gibbons on 4/27/15.
//  Copyright (c) 2015 antonioperez. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *cellViewTwo;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myMessageConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yourMessageConstraint;



@end
