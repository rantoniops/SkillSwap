#import "SignUpVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface SignUpVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property NSNumber *keyboardUp;
@property NSDictionary *storedUserInfo;
@property CGRect negativeFrame;
@end
@implementation SignUpVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.secureTextEntry = YES;
    self.activityIndicator.hidesWhenStopped = YES;
    self.keyboardUp = @0;
    


//    NSLog(@"WIDTH SIZE IS %f", self.view.frame.size.width);
//    NSLog(@"HEIGHT SIZE IS %f", self.view.frame.size.height);

//    if (self.view.frame.size.height == 480.000000)
//    {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
//    }


}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [textField resignFirstResponder];
    return true;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"DID BEGIN");
    if (textField == self.emailTextField)
    {
        NSLog(@"EMAIL");

        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];


//        if ([self.keyboardUp isEqual: @0])
//        {
//            NSLog(@"EMAIL EQUAL @0");
//            self.keyboardUp = @1;
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
//        }

    }
    else if (textField == self.nameTextField)
    {
        NSLog(@"NAME");

        if ([self.keyboardUp isEqual:@1]) // if keyboard is up
        {

            NSLog(@"NAME INSIDE");

            CGRect kbFrame = [[self.storedUserInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
            kbFrame = [self.view convertRect:kbFrame fromView:nil];
            CGRect negFrame = self.view.frame;
            negFrame.origin.y += (kbFrame.size.height / 2) * (-1);

            [self animateControls:self.storedUserInfo withFrame:negFrame];

            self.keyboardUp = @0;
        }

    }
    else if (textField == self.passwordTextField)
    {
        NSLog(@"PASSWORD");
        if ([self.keyboardUp isEqual:@1]) // if keyboard is up
        {
            NSLog(@"PASSWORD INSIDE");

            CGRect kbFrame = [[self.storedUserInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
            kbFrame = [self.view convertRect:kbFrame fromView:nil];
            CGRect negFrame = self.view.frame;
            negFrame.origin.y += (kbFrame.size.height / 2) * (-1);

            [self animateControls:self.storedUserInfo withFrame:negFrame];

            self.keyboardUp = @0;
        }
    }
}



////////////////////// MOVE UP KEYBOARD STUFF //////////////////////////

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSLog(@"WILL SHOW CALLED");
    [self moveControls:notification up:YES];
    self.keyboardUp = @1;
    NSLog(@"WILL KEY %@", self.keyboardUp);
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    NSLog(@"HIDE CALLED");
    [self moveControls:notification up:NO];
    self.keyboardUp = @0;
    NSLog(@"HIDE KEY %@", self.keyboardUp);

}

- (void)moveControls:(NSNotification*)notification up:(BOOL)up
{
    NSDictionary* userInfo = [notification userInfo];

    self.storedUserInfo = userInfo;

    CGRect newFrame = [self getNewControlsFrame:userInfo up:up];
    [self animateControls:userInfo withFrame:newFrame];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (CGRect)getNewControlsFrame:(NSDictionary*)userInfo up:(BOOL)up
{
    CGRect kbFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    NSLog(@"PREV kbFRAME IS %@", NSStringFromCGRect(kbFrame));
    kbFrame = [self.view convertRect:kbFrame fromView:nil];
    NSLog(@"NEXT kbFRAME IS %@", NSStringFromCGRect(kbFrame));
    CGRect newFrame = self.view.frame;
    NSLog(@"NEW FRAME IS %@", NSStringFromCGRect(newFrame));
    newFrame.origin.y += (kbFrame.size.height / 2) * (up ? -1 : 1);
    NSLog(@"NEW FRAME ORIG IS %f", newFrame.origin.y);
    return newFrame;
}

- (void)animateControls:(NSDictionary*)userInfo withFrame:(CGRect)newFrame
{
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.frame = newFrame;
    }
                     completion:^(BOOL finished){

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
