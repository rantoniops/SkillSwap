#import "ReviewVC.h"
@interface ReviewVC () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textField;
@property NSString *placeHolderString;
@property NSNumber *givenRating;
@property (weak, nonatomic) IBOutlet UILabel *propmtTitleLabel;
@end
@implementation ReviewVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textField.delegate = self;
    self.textField.editable = YES;
    self.placeHolderString = [NSString stringWithFormat:@"%@ was very...", [self.reviewCourse valueForKey:@"title"]];
    self.textField.text = self.placeHolderString;
    self.textField.textColor = [UIColor lightGrayColor];
}



-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.textField.text = @"";
    self.textField.textColor = [UIColor blackColor];
}


- (IBAction)underWhelmingButtonTap:(UIButton *)sender
{
    self.givenRating = @0;
    [self saveTheReview];
}

- (IBAction)satisfactoryButtonTap:(UIButton *)sender
{
    self.givenRating = @1;
    [self saveTheReview];
}

- (IBAction)bestInClassButtonTap:(UIButton *)sender
{
    self.givenRating = @2;
    [self saveTheReview];
}

-(void)saveTheReview
{
    self.givenRating = self.givenRating;
    self.reviewToReview.reviewContent = self.textField.text;
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
