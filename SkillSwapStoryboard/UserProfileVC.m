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
@property User *userAtRow;
@property NSArray *coursesArray;
@property NSArray *friendsArray;
@property UIImage *chosenImage;
@property NSData *smallImageData;
@property User *selectedTeacher;
@end
@implementation UserProfileVC
- (void)viewDidLoad
{
    [super viewDidLoad];
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
    if (self.selectedUser)
    {
        self.profileImage.userInteractionEnabled = NO;
    }
    else
    {
    self.profileImage.userInteractionEnabled = YES;
    }
    UIImage *profileImage = image;
    self.profileImage.image = profileImage;
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
        [relationQuery includeKey:@"teacher"];
        [relationQuery whereKey:@"teacher" equalTo: self.selectedUser];
        [relationQuery orderByAscending:@"createdAt"];
        [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 self.coursesArray = objects;
                 [self.tableVIew reloadData];
                 self.name.text = self.selectedUser.username;
                 self.userImageFile = [self.selectedUser valueForKey:@"profilePic"];
                 NSLog(@"image file is %@", self.userImageFile);
                 if (self.userImageFile == NULL)
                 {
                     [self loadProfilePicwithImage:[UIImage imageNamed:@"emptyProfile"]];
                     
                 }
                 else
                 {
                     [self.userImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                      {
                          if (!error)
                          {
                              UIImage *image = [UIImage imageWithData:data];
                              [self loadProfilePicwithImage:image];
                          }
                      }];
                 }
             }
        }];
        PFRelation *relationFriends = [self.selectedUser relationForKey:@"friends"];
        PFQuery *relationFriendsQuery = relationFriends.query;
        [relationFriendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 self.friendsArray = objects;
                 [self.tableVIew reloadData];
             }
         }];
    }
    else // current user clicked on the profile button and wants to see his own profile
    {
        [self calculateUserRating:[User currentUser]];
        
        User *currentUser = [User currentUser];
        PFRelation *relation = [currentUser relationForKey:@"courses"];
        PFQuery *relationQuery = relation.query;
        [relationQuery includeKey:@"teacher"];
        [relationQuery orderByAscending:@"createdAt"];
        [relationQuery whereKey:@"teacher" equalTo:currentUser];
        [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 self.coursesArray = objects;
                 [self.tableVIew reloadData];
                 self.name.text = currentUser.username;
                 self.userImageFile = [currentUser valueForKey:@"profilePic"];
                 NSLog(@"image file is %@", self.userImageFile);
                 if (self.userImageFile == NULL)
                 {
                     [self loadProfilePicwithImage:[UIImage imageNamed:@"emptyProfile"]];

                 }
                 else
                 {
                     [self.userImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                      {
                          if (!error)
                          {
                                  UIImage *image = [UIImage imageWithData:data];
                                  [self loadProfilePicwithImage:image];
                          }
                          }];

                 }
             }
         }];
        PFRelation *relationFriends = [currentUser relationForKey:@"friends"];
        PFQuery *relationFriendsQuery = relationFriends.query;
        [relationFriendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
              if (error == nil)
              {
                  self.friendsArray = objects;
                  [self.tableVIew reloadData];
              }
        }];
        
    }

}






-(void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSLog(@"successful Tap");
    
    NSLog(@"Here is my list of friends %@", self.friendsArray);
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
//    self.profileImage.image = self.chosenImage;
    self.smallImageData = UIImageJPEGRepresentation(self.chosenImage, 0.5);
    [picker dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"image should be ready to save");
    [self saveImage];
    [self loadProfilePicwithImage:self.chosenImage];
    
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
//    Course *course = self.coursesArray[indexPath.row];
    User *user = self.friendsArray[indexPath.row];
    
    cell.textLabel.text = [user valueForKey:@"username"];
//    cell.detailTextLabel.text = [course valueForKey:@"address"];
//    NSString *timeString = [NSDateFormatter localizedStringFromDate:[course valueForKey:@"time"] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
//    NSString *titleAndTime = [NSString stringWithFormat:@"%@ at %@", [course valueForKey:@"title"] , timeString];
//    cell.textLabel.text = titleAndTime;
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
    self.userAtRow = self.friendsArray[indexPath.row];
//    self.courseAtRow = self.coursesArray[indexPath.row];
    [self performSegueWithIdentifier:@"showCourse" sender:self];
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
//    return self.coursesArray.count;
    return self.friendsArray.count;
}


- (IBAction)backButtonTap:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
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
