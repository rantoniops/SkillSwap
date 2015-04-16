#import "UserProfileVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface UserProfileVC () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *rating;
@property (weak, nonatomic) IBOutlet UILabel *credits;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *skills;
@property (weak, nonatomic) IBOutlet UITableView *tableVIew;
@property (weak, nonatomic) IBOutlet UILabel *descriptionText;


@property UIImage *chosenImage;
@property NSData *smallImageData;


@end
@implementation UserProfileVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self queryForUserInfo];
    
    self.profileImage.userInteractionEnabled = YES;
    UIImage *profileImage = [UIImage imageNamed:@"emptyProfile"];
    self.profileImage.image = profileImage;
    
    self.profileImage.frame = CGRectMake(0, 0, 250, 250);
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderWidth = 1;
    UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.profileImage addGestureRecognizer:photoTap];
}


-(void)queryForUserInfo
{
    User *currentUser = [User currentUser];
    PFRelation *relation = [currentUser relationForKey:@("courses")];
    [relation.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil) {
             NSLog(@"here are the course %@", objects);
             NSLog(@"%@", currentUser);
         }
     }];
    self.name.text = currentUser.username;
    //    self.skills.text = currentUser.skills;
}


-(void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSLog(@"successful Tap");
    [self showAlertOnViewController];
}


-(void)showAlertOnViewController
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose photo option" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"Take a Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showTakePhotoView];
    }];
    UIAlertAction *pullLibrary = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showCameraPhotoView];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        nil;
    }];
    
    [alert addAction:takePhoto];
    [alert addAction:pullLibrary];
    
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
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
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:picker animated:true completion:NULL];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.chosenImage = info[UIImagePickerControllerOriginalImage];
    self.profileImage.image = self.chosenImage;
    self.smallImageData = UIImageJPEGRepresentation(self.chosenImage, 0.5);
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self saveImage];
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}




- (IBAction)onSaveButtonPressed:(UIButton *)sender
{
    
}
-(void)saveImage
{
    User *userToSave = [User currentUser];
    PFFile *imageFile = [PFFile fileWithData:self.smallImageData];
    userToSave.profilePic = imageFile;
    [userToSave saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             NSLog(@"profile pic saved");
         }
         else
         {
             NSLog(@"profile pic NOT saved");
         }
     }];
    
    
}

@end
