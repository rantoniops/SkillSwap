#import "PostCourseVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface PostCourseVC () <UITextFieldDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *classTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *classDescriptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *classTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *classAddressTextField;
@property (weak, nonatomic) IBOutlet UIImageView *classPhotoImageView;
@property (weak, nonatomic) IBOutlet UITextField *classSkillTextField;
@property UIImage *chosenImage;
@property NSData *smallImageData;
@end
@implementation PostCourseVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.classTitleTextField.delegate = self;
    self.classTimeTextField.delegate = self;
    self.classAddressTextField.delegate = self;
    self.classSkillTextField.delegate = self;
    self.classDescriptionTextField.delegate = self;
    
    self.classAddressTextField.text = self.selectedAddress;
    UIImage *profileImage = [UIImage imageNamed:@"emptyProfile"];
    self.classPhotoImageView.image = profileImage;
    self.classPhotoImageView.frame = CGRectMake(0, 0, 250, 250);
    self.classPhotoImageView.layer.cornerRadius = self.classPhotoImageView.frame.size.width / 2;
    self.classPhotoImageView.layer.masksToBounds = YES;
    self.classPhotoImageView.layer.borderWidth = 1;
    UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.classPhotoImageView addGestureRecognizer:photoTap];

    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

-(void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSLog(@"successful Tap");
    [self showAlertOnViewController];
}

-(void)showAlertOnViewController
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose photo option" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"Use Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showTakePhotoView];
    }];
    UIAlertAction *pullLibrary = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showCameraPhotoView];
    }];
    
    UIAlertAction *takeMovie = [UIAlertAction actionWithTitle:@"Take a movie" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showMovieView];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        nil;
    }];
    
    [alert addAction:takePhoto];
    [alert addAction:pullLibrary];
    [alert addAction:takeMovie];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

-(void)showMovieView
{
    
}

-(void)showTakePhotoView
{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:true completion:NULL];
    
}

-(void)showCameraPhotoView
{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:true completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.chosenImage = info[UIImagePickerControllerOriginalImage];
    self.classPhotoImageView.image = self.chosenImage;
    self.smallImageData = UIImageJPEGRepresentation(self.chosenImage, 0.5);
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (IBAction)onPostButtonPressed:(UIButton *)sender
{
    // CREATING SKILL
    Skill *skill = [Skill new];
    skill.name = self.classSkillTextField.text;
    skill.owner = [User currentUser];
    [skill saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             NSLog(@"skill saved");

             // CREATING COURSE
             Course *course = [Course new];
             course.title = self.classTitleTextField.text;
             course.courseDescription = self.classDescriptionTextField.text;
             course.time = self.classTimeTextField.text;
             course.address = self.classAddressTextField.text;
             PFFile *imageFile = [PFFile fileWithData:self.smallImageData];
             course.coursePhoto = imageFile;
             course.teacher = [User currentUser];
             course.location = [PFGeoPoint geoPointWithLocation:self.courseLocation];
             PFRelation *relation = [course relationForKey:@"skillsTaught"];
             [relation addObject: skill];
             [course saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (succeeded)
                  {
                      NSLog(@"course saved");
                  }
                  else
                  {
                      NSLog(@"course NOT saved");
                  }
              }];
         }
         else
         {
             NSLog(@"skill NOT saved");
         }
     }];
    [self dismissViewControllerAnimated:true completion:nil];
}




- (IBAction)onXButtonPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}







@end
