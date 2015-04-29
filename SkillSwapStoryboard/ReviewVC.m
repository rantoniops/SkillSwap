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
    self.reviewCourseLabel.text = [NSString stringWithFormat:@"how was %@ with %@?", [self.reviewCourse valueForKey:@"title"], self.reviewToReview.reviewed.username];
    self.reviewCourseLabel.numberOfLines = 0;
    self.reviewBodyTextField.text = @"";
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
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
    if (self.reviewToReview.reviewRating == nil)
    {
        [self showAlert];
    }
    else
    {
        [self saveTheReview];
    }
}


-(void)saveTheReview
{
    NSLog(@"RATING WAS %@", self.reviewToReview.reviewRating);
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
     

-(void)showAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Rating Missing" message:@"Please tap on a rating" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
    {

    }];

    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}








@end
