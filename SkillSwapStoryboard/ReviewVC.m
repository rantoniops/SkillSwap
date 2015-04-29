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
    self.placeHolderString = [NSString stringWithFormat:@"how was %@ with %@?", [self.reviewCourse valueForKey:@"title"], self.reviewToReview.reviewed.username];
    self.reviewCourseLabel.text = self.placeHolderString;
    self.reviewCourseLabel.numberOfLines = 0;
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
             [self calculateUserRating:self.reviewToReview.reviewed];
             [self dismissViewControllerAnimated:true completion:nil];
         }
     }];
}
     


-(void)calculateUserRating:(User *)user
{
    PFQuery *reviewsQuery = [Review query];
    [reviewsQuery includeKey:@"reviewed"];
    [reviewsQuery includeKey:@"reviewer"];
    [reviewsQuery includeKey:@"course"];
    [reviewsQuery whereKey:@"reviewed" equalTo:user];
    [reviewsQuery whereKey:@"hasBeenReviewed" equalTo:@1];
    [reviewsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             NSLog(@"found %lu reviews for the user" , (unsigned long)objects.count);
             NSArray *reviewsArray = [NSArray arrayWithArray:objects];
             int reviewsSum = 0;
             for (Review *review in reviewsArray)
             {
                 reviewsSum += [review.reviewRating intValue];
                 NSLog(@"review rating is %@", review.reviewRating);
             }
             if (reviewsArray.count == 0)
             {
                 // dont do anything, since dividing by zero will crash the app
             }
             else
             {
                 int reviewsAverage = (reviewsSum / reviewsArray.count);
                 NSNumber *average = @(reviewsAverage);
                 user.rating = average;
                 [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (succeeded)
                      {
                          NSLog(@"user's new rating saved");
                      }
                  }];
             }
         }
         else
         {
             NSLog(@"error finding reviews");
         }
     }];
}







@end
