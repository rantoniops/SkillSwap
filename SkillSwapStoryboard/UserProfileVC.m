#import "UserProfileVC.h"
#import "SkillSwapStoryboard-Swift.h"
#import "LoginVC.h"
@interface UserProfileVC () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *rating;
@property (weak, nonatomic) IBOutlet UILabel *credits;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *skills;
@property (weak, nonatomic) IBOutlet UITableView *tableVIew;
@property (weak, nonatomic) IBOutlet UILabel *descriptionText;
@property PFFile *userImageFile;

@property NSArray *coursesArray;


@property UIImage *chosenImage;
@property NSData *smallImageData;


@end
@implementation UserProfileVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadrofilePicwithImage:[UIImage imageNamed:@"emptyProfile"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [self queryForUserInfo];
}

- (IBAction)onLogoutButtonTapped:(UIBarButtonItem *)sender
{
    [User logOut];
    [self performSegueWithIdentifier:@"fromUserToLogin" sender:self];
}


-(void)loadrofilePicwithImage:(UIImage *)image
{
    
    self.profileImage.userInteractionEnabled = YES;
    UIImage *profileImage = image;
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
             self.coursesArray = [NSArray arrayWithArray:objects];
             [self.tableVIew reloadData];
             self.name.text = currentUser.username;
//             NSLog(@"%@", currentUser);
             self.userImageFile = [currentUser valueForKey:@"profilePic"];
             NSLog(@"image file is %@", self.userImageFile);
            [self.userImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                  {
                      if (!error)
                      {
                          UIImage *image = [UIImage imageWithData:data];
                          [self loadrofilePicwithImage:image];
                          NSLog(@"we have the image");
                      }
                  }];
             }
     }];
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
    NSLog(@"image should be ready to save");
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    Course *course = self.coursesArray[indexPath.row];
    NSLog(@"course address is %@", course.address);
    cell.detailTextLabel.text = course.address;
    NSString *timeString = [NSDateFormatter localizedStringFromDate:course.time dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    NSLog(@"timestring is %@", timeString);
    NSString *titleAndTime = [NSString stringWithFormat:@"%@ at %@", course.title, timeString];
    cell.textLabel.text = titleAndTime;
    
    
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.coursesArray.count;
}


- (IBAction)backButtonTap:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}

//- (IBAction)editButton:(id)sender
//{
//    [self saveImage];
//    if ([self.editAndDoneButton.title isEqualToString:@"Edit"])
//    {
//        self.editAndDoneButton.title = @"Done";
//    }
//    else
//    {
//        self.editAndDoneButton.title = @"Edit";
//    }
//}




- (IBAction)onSaveButtonPressed:(UIButton *)sender
{
        [self saveImage];
    
}
-(void)saveImage
{
    User *userToSave = [User currentUser];
    PFFile *imageFile = [PFFile fileWithData:self.smallImageData];
    [userToSave setValue:imageFile forKey:@"profilePic"];
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
