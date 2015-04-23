#import "LoginVC.h"
#import "SkillSwapStoryboard-Swift.h"

@interface LoginVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *logingButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UILabel *heading;

@property (weak, nonatomic) IBOutlet UIImageView *cloud1;
@property (weak, nonatomic) IBOutlet UIImageView *cloud2;
@property (weak, nonatomic) IBOutlet UIImageView *cloud3;
@property (weak, nonatomic) IBOutlet UIImageView *cloud4;

@end


@implementation LoginVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.passwordTextField.secureTextEntry = YES;

}

-(void)viewWillAppear:(BOOL)animated
{
    
    self.navigationController.navigationBarHidden = YES;
    NSLog(@"current user is %@", [User currentUser]);
    if ([User currentUser] != nil)
    {
        [self performSegueWithIdentifier:@"logIn" sender:self];
    }
    
    self.heading.alpha = 0;
    
    
//    [self moveTextFieldOffScreen:self.nameTextField];
//    [self moveTextFieldOffScreen:self.emailTextField];
//    [self moveTextFieldOffScreen:self.passwordTextField];
    
}

-(void) moveTextFieldOffScreen:(UITextField * )textField
{
    CGPoint nCenter = textField.center;
    nCenter.x -= 1000;
    textField.center = nCenter;
}

-(void) moveTextFieldInScreen:(UITextField *)textField
{
    CGPoint nCenter = textField.center;
    nCenter.x += self.view.bounds.size.width;
    textField.center = nCenter;
}

//-(void) animateCloud(UIImageView *)cloud
//{
//    double cloudSpeed = 20.0/(self.view.frame.size.width);
//    double viewHeight
//    double duration: NSTimeInterval = (view.frame.size.)
//}
//-(void)viewDidAppear:(BOOL)animated
//{
//    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        [self moveTextFieldInScreen:self.nameTextField];
//    } completion:nil];
//    
//    [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        [self moveTextFieldInScreen:self.passwordTextField];
//    } completion:nil];
//    
//    [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        [self moveTextFieldInScreen:self.emailTextField];
//    } completion:nil];
//}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}



- (IBAction)loginButtonPress:(UIButton *)sender
{
    [PFUser logInWithUsernameInBackground:self.nameTextField.text password:self.passwordTextField.text
    block:^(PFUser *user, NSError *error)
    {
        if (user)
        {
            NSLog(@"setting current user to the installation from the login");

            // push notifications
            [[PFInstallation currentInstallation] setObject:[User currentUser] forKey:@"user"];
            [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if (succeeded)
                 {
                     NSLog(@"installation saved");
                 }
                 else
                 {
                     NSLog(@"error, installation NOT saved");
                 }
             }];



            [self dismissViewControllerAnimated:true completion:nil];
            [self performSegueWithIdentifier:@"logIn" sender:self];
        } else
        {
//            [self showAlert("There was an error with your login", error: returnedError!)];
        }
    }];
}


- (IBAction)signUpButtonPress:(UIButton *)sender
{
    User *user = [User new];
    user.username = self.nameTextField.text;
    user.password = self.passwordTextField.text;
    user.email = self.emailTextField.text;
    user.credits = [NSNumber numberWithInt:1];

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
                 }
                 else
                 {
                     NSLog(@"error, installation NOT saved");
                 }
             }];

            [self dismissViewControllerAnimated:true completion:nil];
            [self performSegueWithIdentifier:@"logIn" sender:self];

        }
        else
        {
//            [self showAlert("There was an error with your sign up", error: returnedError!)];
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
