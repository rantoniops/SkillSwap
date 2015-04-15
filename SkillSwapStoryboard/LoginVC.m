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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view resignFirstResponder];
    return true;
}


- (IBAction)loginButtonPress:(UIButton *)sender
{
    [PFUser logInWithUsernameInBackground:self.nameTextField.text password:self.passwordTextField.text
    block:^(PFUser *user, NSError *error)
    {
        if (user)
        {
            [self dismissViewControllerAnimated:true completion:nil];
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

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (succeeded)
        {
            [self dismissViewControllerAnimated:true completion:nil];
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
