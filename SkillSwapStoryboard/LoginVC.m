#import "LoginVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface LoginVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
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
}

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
