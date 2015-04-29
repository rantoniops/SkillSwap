#import "SignUpVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface SignUpVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
@implementation SignUpVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.emailTextField.delegate = self;
    self.passwordTextField.secureTextEntry = YES;
    self.activityIndicator.hidesWhenStopped = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];

//    self.view.frame.size = 
}


//////////////////////// MOVE UP KEYBOARD STUFF //////////////////////////
//
//- (void)keyboardWillShow:(NSNotification*)notification
//{
//    [self moveControls:notification up:YES];
//}
//
//- (void)keyboardWillBeHidden:(NSNotification*)notification
//{
//    [self moveControls:notification up:NO];
//}
//
//- (void)moveControls:(NSNotification*)notification up:(BOOL)up
//{
//    NSDictionary* userInfo = [notification userInfo];
//    CGRect newFrame = [self getNewControlsFrame:userInfo up:up];
//    [self animateControls:userInfo withFrame:newFrame];
//}
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self.view endEditing:YES];
//}
//
//- (CGRect)getNewControlsFrame:(NSDictionary*)userInfo up:(BOOL)up
//{
//    CGRect kbFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    kbFrame = [self.view convertRect:kbFrame fromView:nil];
//    CGRect newFrame = self.view.frame;
//    newFrame.origin.y += kbFrame.size.height * (up ? -1 : 1);
//    return newFrame;
//}
//
//- (void)animateControls:(NSDictionary*)userInfo withFrame:(CGRect)newFrame
//{
//    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    //    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
//    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        self.view.frame = newFrame;
//    }
//                     completion:^(BOOL finished){}];
//}
//
//
//////////////////////// MOVE UP KEYBOARD STUFF //////////////////////////


-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

- (IBAction)alreadyButtonPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)signUpButtonPress:(UIButton *)sender
{
    [self.activityIndicator startAnimating];
    User *user = [User new];
    user.username = self.nameTextField.text;
    user.password = self.passwordTextField.text;
    user.email = self.emailTextField.text;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             NSLog(@"setting current user to the installation from the signup");

             // push notifications
             [[PFInstallation currentInstallation] setObject:[User currentUser] forKey:@"user"];
             [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (succeeded)
                  {
                      NSLog(@"installation saved");
                      [self.activityIndicator stopAnimating];
                  }
                  else
                  {
                      NSLog(@"error, installation NOT saved");
                  }
              }];

             [self performSegueWithIdentifier:@"signupToMap" sender:self];
         }
         else
         {
             NSLog(@"error signing up");
         }
     }];
}






//-(void)showAlert(NSString *)message error(NSError *)
//{
//    let alert = UIAlertController(title: message, message: error.localizedDescription, preferredStyle: .Alert)
//    let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
//    alert.addAction(okAction)
//    presentViewController(alert, animated: true, completion: nil)
//}




@end
