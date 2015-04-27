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
    self.classLabel.text = self.selectedReview.course.title;
    self.reviewContentLabel.text = self.selectedReview.reviewContent;
    self.reviewerLabel.text = self.selectedReview.reviewer.username;
}
















@end
