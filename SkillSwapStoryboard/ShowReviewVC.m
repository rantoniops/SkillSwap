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
    self.classLabel.text = [NSString stringWithFormat:@"How was class %@ with %@ ?", [theCourse valueForKey:@"title"] , self.selectedReview.reviewer.username];
    self.classLabel.numberOfLines = 0;
    self.reviewContentLabel.text = self.selectedReview.reviewContent;
    self.reviewContentLabel.numberOfLines = 0;
    self.reviewerLabel.text = [NSString stringWithFormat:@"Reviewer : %@" , self.selectedReview.reviewer.username];
}
















@end
