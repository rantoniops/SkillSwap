#import "ReviewVC.h"
@interface ReviewVC () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *reviewBodyTextField;
@property NSString *placeHolderString;
@property (weak, nonatomic) IBOutlet UILabel *reviewCourseLabel;
@property (weak, nonatomic) IBOutlet UIButton *badButton;
@property (weak, nonatomic) IBOutlet UIButton *okayButton;
@property (weak, nonatomic) IBOutlet UIButton *greatButton;
@end
@implementation ReviewVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.reviewBodyTextField.delegate = self;
    self.reviewBodyTextField.editable = YES;
    self.placeHolderString = [NSString stringWithFormat:@"how was %@ ?", [self.reviewCourse valueForKey:@"title"]];
    self.reviewCourseLabel.text = self.placeHolderString;
    self.reviewBodyTextField.text = @"";
}



-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.reviewBodyTextField.text = @"";
    self.reviewBodyTextField.textColor = [UIColor blackColor];
}

- (IBAction)badButtonPressed:(UIButton *)sender
{
    self.reviewToReview.reviewRating = @0;
    self.badButton.tintColor = [UIColor greenColor];
    self.okayButton.enabled = NO;
    self.greatButton.enabled = NO;
}

- (IBAction)okayButtonPressed:(UIButton *)sender
{
    self.reviewToReview.reviewRating = @1;
    self.okayButton.tintColor = [UIColor greenColor];
    self.badButton.enabled = NO;
    self.greatButton.enabled = NO;
}

- (IBAction)greatButtonPressed:(UIButton *)sender
{
    self.reviewToReview.reviewRating = @2;
    self.greatButton.tintColor = [UIColor greenColor];
    self.badButton.enabled = NO;
    self.okayButton.enabled = NO;
}


- (IBAction)submitReviewButtonPressed:(UIButton *)sender
{
    [self saveTheReview];
}


-(void)saveTheReview
{
    self.reviewToReview.reviewContent = self.reviewBodyTextField.text;
    self.reviewToReview.hasBeenReviewed = @1;
    [self.reviewToReview saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             NSLog(@"review with content saved");
             [self dismissViewControllerAnimated:true completion:nil];
         }
     }];
}
     






@end
