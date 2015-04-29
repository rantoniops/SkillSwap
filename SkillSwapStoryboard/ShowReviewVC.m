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
    Course *theCourse = [self.selectedReview objectForKey:@"course"];
    User *reviewedUser = [theCourse objectForKey:@"reviewed"];
//    self.classLabel.text = [NSString stringWithFormat:@"Class : %@", self.selectedReview.course.title];
    self.classLabel.text = [NSString stringWithFormat:@"How was class %@ with %@ ?", [theCourse valueForKey:@"title"] , reviewedUser.username];
    self.reviewContentLabel.text = self.selectedReview.reviewContent;
    self.reviewContentLabel.numberOfLines = 0;
    self.reviewerLabel.text = [NSString stringWithFormat:@"Reviewer : %@" , self.selectedReview.reviewer.username];
}
















@end
