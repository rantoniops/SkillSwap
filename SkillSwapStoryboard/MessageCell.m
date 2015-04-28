//
//  MessageCell.m
//  SkillSwapStoryboard
//
//  Created by Thomas Gibbons on 4/27/15.
//  Copyright (c) 2015 antonioperez. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (void)awakeFromNib
{
    self.cellView.layer.cornerRadius = 15;
    CGRect newFrame = self.cellView.frame;
    newFrame.size.width = 200;
    newFrame.size.height = 50;
    self.cellView.layer.borderWidth = 3.0f;
    CGRect labelFrame = CGRectOffset(self.cellView.frame, 10, 0);
//    CGRect labelFram2 = self.label.frame;
    labelFrame.size.width = 175;
    labelFrame.size.height = 40;
    [self.cellView setFrame:newFrame];

    
    newFrame.size.width = labelFrame.size.width +25;
    newFrame.size.height = labelFrame.size.height +10;
    
    self.label = [[UILabel alloc]initWithFrame:labelFrame];
    self.label.numberOfLines=0;
    self.label.lineBreakMode= NSLineBreakByWordWrapping;
    self.label.backgroundColor = [UIColor clearColor];
    self.label.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    [self.cellView addSubview:self.label];
    
    

}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
