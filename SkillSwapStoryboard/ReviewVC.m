#import "ReviewVC.h"
@interface ReviewVC () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textField;
@property NSString *placeHolderString;
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
    [self saveTheReview];
}

- (IBAction)satisfactoryButtonTap:(UIButton *)sender
{
    [self saveTheReview];
}

- (IBAction)bestInClassButtonTap:(UIButton *)sender
{
    [self saveTheReview];
}

-(void)saveTheReview
{
    self.reviewToReview.reviewContent = self.textField.text;
    [self.reviewToReview saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             self.reviewToReview.hasBeenReviewed = @1;
             NSLog(@"review with content saved");
         }
     }];
}
     


@end
