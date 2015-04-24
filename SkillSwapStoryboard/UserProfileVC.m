#import "UserProfileVC.h"
#import "SkillSwapStoryboard-Swift.h"
#import "LoginVC.h"
#import "TakeCourseVC.h"
@interface UserProfileVC () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *rating;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *skills;
@property (weak, nonatomic) IBOutlet UITableView *tableVIew;
@property (weak, nonatomic) IBOutlet UILabel *descriptionText;
@property PFFile *userImageFile;
@property Course *courseAtRow;
@property NSArray *coursesArray;
@property UIImage *chosenImage;
@property NSData *smallImageData;
@property User *selectedTeacher;
@end
@implementation UserProfileVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadProfilePicwithImage:[UIImage imageNamed:@"emptyProfile"]];
}


-(void)calculateUserRating:(User *)user
{
    PFQuery *reviewsQuery = [Review query];
    [reviewsQuery includeKey:@"reviewed"];
    [reviewsQuery whereKey:@"reviewed" equalTo:user];
    [reviewsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             NSLog(@"found %lu reviews for the user" , (unsigned long)objects.count);
             NSArray *reviews = objects;
             int reviewsSum = 0;
             for (Review *review in reviews)
             {
                 reviewsSum = reviewsSum + [review.reviewRating intValue];
             }
             int reviewsAverage = (reviewsSum / reviews.count);
             NSNumber *average = @(reviewsAverage);
             self.rating.text = [NSString stringWithFormat:@"Rating %@", average];
         }
         else
         {
             NSLog(@"error finding reviews");
         }
     }];
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


-(void)loadProfilePicwithImage:(UIImage *)image
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
    if (self.selectedUser) // IF COMING FROM TAKECOURSEVC AND WANNA SHOW THE TEACHERS PROFILE
    {
        [self calculateUserRating:self.selectedUser];

        PFRelation *relation = [self.selectedUser relationForKey:@"courses"];
        PFQuery *relationQuery = relation.query;
        [relationQuery orderByAscending:@"createdAt"];
        [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 self.coursesArray = objects;
                 [self.tableVIew reloadData];
                 self.name.text = self.selectedUser.username;
                 self.userImageFile = [self.selectedUser valueForKey:@"profilePic"];
                 [self.userImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                  {
                      if (!error)
                      {
                          UIImage *image = [UIImage imageWithData:data];
                          [self loadProfilePicwithImage:image];
                          NSLog(@"we have the image");
                      }
                  }];
             }
         }];
    }
    else // current user clicked on the profile button and wants to see his own profile
    {
        [self calculateUserRating:[User currentUser]];
        
        User *currentUser = [User currentUser];
        PFRelation *relation = [currentUser relationForKey:@"courses"];
        PFQuery *relationQuery = relation.query;
        [relationQuery orderByAscending:@"createdAt"];
        [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 self.coursesArray = objects;
                 [self.tableVIew reloadData];
                 self.name.text = currentUser.username;
                 self.userImageFile = [currentUser valueForKey:@"profilePic"];
                 NSLog(@"image file is %@", self.userImageFile);
                 [self.userImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                  {
                      if (!error)
                      {
                          UIImage *image = [UIImage imageWithData:data];
                          [self loadProfilePicwithImage:image];
                          NSLog(@"we have the image");
                      }
                  }];
             }
         }];
    }

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
//    cell.detailTextLabel.text = course.address;
    cell.detailTextLabel.text = [course valueForKey:@"address"];
//    NSString *timeString = [NSDateFormatter localizedStringFromDate:course.time dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    NSString *timeString = [NSDateFormatter localizedStringFromDate:[course valueForKey:@"time"] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
//    NSString *titleAndTime = [NSString stringWithFormat:@"%@ at %@", course.title, timeString];
    NSString *titleAndTime = [NSString stringWithFormat:@"%@ at %@", [course valueForKey:@"title"] , timeString];
    cell.textLabel.text = titleAndTime;
    return cell;
}


-(void)followButtonTap
{
    //needs to be changed so we are looking at another users profile
    User *selectedUser = [User currentUser];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell tapped");
    self.courseAtRow = (Course *)self.coursesArray[indexPath.row];

//    User *teacher = [self.courseAtRow objectForKey:@"teacher"];
    User *teacher = self.courseAtRow.teacher;

    [teacher fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
    {
        if (error == nil)
        {
            if (object)
            {
                NSLog(@"fetched the teacher object %@" , object);
                self.selectedTeacher = (User *)object;
                NSLog(@"course teacher is %@", self.selectedTeacher.username);
                [self performSegueWithIdentifier:@"showCourse" sender:self];
            }
            else
            {
                NSLog(@"teacher object not found");
            }
        }
        else
        {
            NSLog(@"error, didnt fetch the object");
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showCourse"])
    {
        NSLog(@"going to show course");
        TakeCourseVC *takeCourseVC = segue.destinationViewController;
        NSLog(@"selected course is %@", self.courseAtRow);
        takeCourseVC.selectedCourse = self.courseAtRow;
        takeCourseVC.selectedTeacher = self.selectedTeacher;
        NSLog(@"no crash here");
    }
    
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
