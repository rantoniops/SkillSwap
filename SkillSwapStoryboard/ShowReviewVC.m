#import "ShowReviewVC.h"
@interface ShowReviewVC ()
@property (weak, nonatomic) IBOutlet UILabel *classLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewerLabel;
@end
@implementation ShowReviewVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Review";
    
    
    self.classLabel.text = [NSString stringWithFormat:@"Class : %@", self.selectedReview.course.title];
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:128 blue:255 alpha:0.8];
    
    self.reviewContentLabel.text = self.selectedReview.reviewContent;
    self.reviewerLabel.text = [NSString stringWithFormat:@"Reviewer : %@" , self.selectedReview.reviewer.username];
}
















@end
