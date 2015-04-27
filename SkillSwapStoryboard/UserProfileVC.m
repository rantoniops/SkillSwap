#import "UserProfileVC.h"
#import "SkillSwapStoryboard-Swift.h"
#import "LoginVC.h"
#import "TakeCourseVC.h"
#import "ConnectionsListVC.h"
@interface UserProfileVC () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *rating;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *skills;
@property (weak, nonatomic) IBOutlet UITableView *tableVIew;
@property (weak, nonatomic) IBOutlet UILabel *descriptionText;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property PFFile *userImageFile;
@property Course *courseAtRow;
@property User *userAtRow;
@property NSArray *coursesArray;
@property NSArray *followersArray;
@property NSArray *followingArray;
@property NSArray *skillsArray;
@property NSArray *reviewsArray;
@property UIImage *chosenImage;
@property NSData *smallImageData;
@property User *selectedTeacher;
@property NSNumber *tableViewNumber;

@end
@implementation UserProfileVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableViewNumber = @3;
}

- (IBAction)skillsButtonPressed:(UIButton *)sender
{
    self.tableViewNumber = @1;
    [self.tableVIew reloadData];
}

- (IBAction)reviewsButtonPressed:(UIButton *)sender
{
    self.tableViewNumber = @2;
    [self.tableVIew reloadData];
    
}

- (IBAction)classesButtonPressed:(UIButton *)sender
{
    self.tableViewNumber = @3;
    [self.tableVIew reloadData];
}

- (IBAction)friendsButtonPressed:(UIButton *)sender
{
    //perform segue
}


- (IBAction)followButtonPressed:(UIButton *)sender
{
    
}



-(void)calculateUserRating:(User *)user
{
    PFQuery *reviewsQuery = [Review query];
    [reviewsQuery includeKey:@"reviewed"];
    [reviewsQuery includeKey:@"reviewer"];
    [reviewsQuery whereKey:@"reviewed" equalTo:user];
    [reviewsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             NSLog(@"found %lu reviews for the user" , (unsigned long)objects.count);
             self.reviewsArray = objects;
             int reviewsSum = 0;
             for (Review *review in self.reviewsArray)
             {
                 reviewsSum = reviewsSum + [review.reviewRating intValue];
             }
             if (self.reviewsArray.count == 0)
             {
                 // dont do anything, since dividing by zero will crash the app
             }
             else
             {
                 int reviewsAverage = (reviewsSum / self.reviewsArray.count);
                 NSNumber *average = @(reviewsAverage);
                 self.rating.text = [NSString stringWithFormat:@"Rating %@", average];
             }

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
    [self queryForFriends];
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
        PFRelation *relationSkills = [self.selectedUser relationForKey:@"skills"];
        PFQuery *relationSkillsQuery = relationSkills.query;
        [relationSkillsQuery findObjectsInBackgroundWithBlock:^(NSArray *skills, NSError *error)
         {
             if (error == nil)
             {
                 self.skillsArray = skills;
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
        PFRelation *relationSkills = [currentUser relationForKey:@"skills"];
        PFQuery *relationSkillsQuery = relationSkills.query;
        [relationSkillsQuery findObjectsInBackgroundWithBlock:^(NSArray *skills, NSError *error)
         {
             if (error == nil)
             {
                 self.skillsArray = skills;
                 [self.tableVIew reloadData];
             }
         }];
    }

}

-(void)queryForFriends
{
    if (self.selectedUser)
    {
        PFQuery *followerQuery = [Follow query];
        [followerQuery whereKey:@"to" equalTo:self.selectedUser];
        [followerQuery includeKey:@"to"];
        [followerQuery includeKey:@"from"];
        [followerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 self.followersArray = objects;
                 NSLog(@"should not be followed i don't think %@", objects);
                 
             }
             if (error)
             {
                 NSLog(@"there was an error %@", error.localizedDescription);
             }
         }];
        PFQuery *followingQuery = [Follow query];
        [followingQuery includeKey:@"from"];
        [followingQuery includeKey:@"to"];
        [followingQuery whereKey:@"from" equalTo:self.selectedUser];
        [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 self.followingArray = objects;
                 NSLog(@"should be following someone %@", objects);
             }
         }];
    }
    else
    {
        User *currentUser = [User currentUser];
        //followers
        PFQuery *followerQuery = [Follow query];
        [followerQuery whereKey:@"to" equalTo:currentUser];
        [followerQuery includeKey:@"to"];
        [followerQuery includeKey:@"from"];
        [followerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 self.followersArray = objects;
                 NSLog(@"should not be followed i don't think %@", objects);
                 
             }
         }];
        
        //following
        PFQuery *followingQuery = [Follow query];
        [followingQuery includeKey:@"from"];
        [followingQuery includeKey:@"to"];
        [followingQuery whereKey:@"from" equalTo:currentUser];
        [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 self.followingArray = objects;
                 NSLog(@"should be following someone %@", objects);
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
    if ([self.tableViewNumber  isEqual: @1])
    {
        Skill *skill = self.skillsArray[indexPath.row];
        cell.textLabel.text = [skill valueForKey:@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Since %@", [skill valueForKey:@"createdAt"]];
    }
    else if ([self.tableViewNumber isEqual: @2])
    {
        Review *review = self.reviewsArray[indexPath.row];
        cell.detailTextLabel.text = [review valueForKey:@"reviewContent"];
        User *reviewer = [review objectForKey:@"reviewer"];
        NSLog(@" here is the reviewrer username %@", reviewer);
        NSString *commentTime = [NSDateFormatter localizedStringFromDate:[reviewer valueForKey:@"createdAt"] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
        NSString *cellText = [NSString stringWithFormat:@"%@ - %@", [reviewer valueForKey:@"username"],commentTime];
        cell.textLabel.text = cellText;

    }
    else
    {
        Course *course = self.coursesArray[indexPath.row];
        NSString *timeString = [NSDateFormatter localizedStringFromDate:[course valueForKey:@"time"] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        NSString *titleAndTime = [NSString stringWithFormat:@"%@ at %@", [course valueForKey:@"title"] , timeString];
        cell.textLabel.text = titleAndTime;
        cell.detailTextLabel.text = [course valueForKey:@"address"];
    }

    return cell;
}


-(void)followButtonTap
{
    //needs to be changed so we are looking at another users profile
    User *selectedUser = [User currentUser];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    self.userAtRow = self.friendsArray[indexPath.row];
    if ([self.tableViewNumber isEqual:@1])
    {
        NSLog(@"no transition");
        [tableView deselectRowAtIndexPath:indexPath animated:true];
    }
    if ([self.tableViewNumber isEqual:@2])
    {
        [tableView deselectRowAtIndexPath:indexPath animated:true];
    }
    if ([self.tableViewNumber isEqual:@3])
    {
        self.courseAtRow = self.coursesArray[indexPath.row];
        [self performSegueWithIdentifier:@"showCourse" sender:self];
    }
  
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showCourse"])
    {
        TakeCourseVC *takeCourseVC = segue.destinationViewController;
        takeCourseVC.selectedCourse = self.courseAtRow;
//        takeCourseVC.selectedTeacher = self.selectedTeacher;
        takeCourseVC.selectedTeacher = self.courseAtRow.teacher;
    }
    else //take to friends VC
    {
        ConnectionsListVC *friendsVC = segue.destinationViewController;
        friendsVC.followersArray = self.followersArray;
        friendsVC.followingArray = self.followingArray;
        NSLog(@"Here are you followers %@, and here who is you are following %@", self.followersArray, self.followingArray);
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.tableViewNumber  isEqual: @1])
    {
        return self.skillsArray.count;
    }
    else if ([self.tableViewNumber  isEqual: @2])
    {
        return self.reviewsArray.count;
    }
    else
    {
        return self.coursesArray.count;
    }
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
