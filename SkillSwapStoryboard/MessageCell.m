#import "MessageCell.h"
@implementation MessageCell
- (void)awakeFromNib
{
    self.cellViewTwo.layer.cornerRadius = 10;
    self.cellViewTwo.layer.borderWidth = 3.0f;

    
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    

}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
