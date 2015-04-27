#import "LoginVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface LoginVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
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


            [self performSegueWithIdentifier:@"loginToMap" sender:self];
        }
        else
        {
            NSLog(@"error logging in");
//            [self showAlert("There was an error with your login", error: returnedError!)];
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
