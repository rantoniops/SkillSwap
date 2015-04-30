#import "LoginVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface LoginVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
@implementation LoginVC
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

- (IBAction)loginButtonPress:(UIButton *)sender
{
    [self.activityIndicator startAnimating];
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
                     [self.activityIndicator stopAnimating];
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
            [self.activityIndicator stopAnimating];
            [self showAlert];
        }
    }];
}


            
-(void)showAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"There was an Error" message:@"Please try again" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            self.nameTextField.text = @"";
            self.passwordTextField.text = @"";
        }];
    
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}













@end
