#import "SignUpVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface SignUpVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property NSNumber *keyboardUp;
@property NSNumber *viewIsUp;
@property NSDictionary *storedUserInfo;
@property NSNumber *userInfoCaptured;
@property CGRect negativeFrame;
@end
@implementation SignUpVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.emailTextField.delegate = self;

    self.nameTextField.secureTextEntry = YES;
    self.passwordTextField.secureTextEntry = YES;
    self.emailTextField.secureTextEntry = YES;

    self.activityIndicator.hidesWhenStopped = YES;
    self.keyboardUp = @0;
    self.viewIsUp = @0;
    self.userInfoCaptured = @0;

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.viewIsUp isEqual:@1])
    {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];

        CGRect kbFrame = [[self.storedUserInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        kbFrame = [self.view convertRect:kbFrame fromView:nil];
        CGRect negFrame = self.view.frame;
        negFrame.origin.y -= (kbFrame.size.height / 2) * (-1);
        [self animateControls:self.storedUserInfo withFrame:negFrame];
    }
    [textField resignFirstResponder];
    self.keyboardUp = @0;
    return true;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.keyboardUp = @1;
    if (textField == self.emailTextField)
    {
        if ([self.viewIsUp isEqual:@0])
        {
            if ([self.userInfoCaptured isEqual:@1])
            {
                CGRect kbFrame = [[self.storedUserInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
                kbFrame = [self.view convertRect:kbFrame fromView:nil];
                CGRect negFrame = self.view.frame;
                negFrame.origin.y += (kbFrame.size.height / 2) * (-1);
                [self animateControls:self.storedUserInfo withFrame:negFrame];
            }
            else
            {
                self.userInfoCaptured = @1;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
            }
        }
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}



////////////////////// MOVE UP KEYBOARD STUFF //////////////////////////

- (void)keyboardWillShow:(NSNotification*)notification
{
    [self moveControls:notification up:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    [self moveControls:notification up:NO];
}

- (void)moveControls:(NSNotification*)notification up:(BOOL)up
{
    NSDictionary* userInfo = [notification userInfo];
    self.storedUserInfo = userInfo;
    CGRect newFrame = [self getNewControlsFrame:userInfo up:up];
    [self animateControls:userInfo withFrame:newFrame];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    if ([self.viewIsUp isEqual:@1])
    {
        CGRect kbFrame = [[self.storedUserInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        kbFrame = [self.view convertRect:kbFrame fromView:nil];
        CGRect negFrame = self.view.frame;
        negFrame.origin.y -= (kbFrame.size.height / 2) * (-1);
        [self animateControls:self.storedUserInfo withFrame:negFrame];
        self.keyboardUp = @0;
    }
}

- (CGRect)getNewControlsFrame:(NSDictionary*)userInfo up:(BOOL)up
{
    CGRect kbFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbFrame = [self.view convertRect:kbFrame fromView:nil];
    CGRect newFrame = self.view.frame;
    newFrame.origin.y += (kbFrame.size.height / 2) * (up ? -1 : 1);
    return newFrame;
}

- (void)animateControls:(NSDictionary*)userInfo withFrame:(CGRect)newFrame
{
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.frame = newFrame;
    }
                     completion:^(BOOL finished){
                         if ([self.viewIsUp isEqual:@0])
                         {
                             self.viewIsUp = @1;
                         }
                         else
                         {
                             self.viewIsUp = @0;
                         }
                     }];
}


////////////////////// MOVE UP KEYBOARD STUFF //////////////////////////


-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
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
