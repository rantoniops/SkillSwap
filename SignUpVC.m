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
    self.passwordTextField.secureTextEntry = YES;
    self.activityIndicator.hidesWhenStopped = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
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
