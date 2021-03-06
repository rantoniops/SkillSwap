#import "UserProfileVC.h"
#import "SkillSwapStoryboard-Swift.h"
#import "LoginVC.h"
#import "TakeCourseVC.h"
#import "ConnectionsListVC.h"
#import "ShowReviewVC.h"
#import "MessageConversationVC.h"
#import "ClassesListVC.h"

@interface UserProfileVC () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *rating;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *skills;
@property (weak, nonatomic) IBOutlet UITableView *tableVIew;
@property (weak, nonatomic) IBOutlet UILabel *descriptionText;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property PFFile *userImageFile;
@property Course *courseAtRow;
@property User *userAtRow;
@property NSArray *coursesArray;
@property NSArray *teachingArray;
@property NSArray *takingArray;
@property NSArray *followersArray;
@property NSArray *followingArray;
@property NSArray *skillsArray;
@property NSArray *reviewsArray;
@property UIImage *chosenImage;
@property NSData *smallImageData;
@property User *selectedTeacher;
@property NSNumber *tableViewNumber;
@property Review *reviewAtRow;
@property NSArray *followingObjectsToBeDeleted;
@property (weak, nonatomic) IBOutlet UIButton *classButton;
@property (weak, nonatomic) IBOutlet UIButton *skillButton;
@property (weak, nonatomic) IBOutlet UIButton *reviewButton;
@property (weak, nonatomic) IBOutlet UIButton *friendsButton;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@end
@implementation UserProfileVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Profile";
    self.tableViewNumber = @1;
    [self.classButton setTintColor:[UIColor orangeColor]];
    [self.skillButton setTintColor:[UIColor orangeColor]];
    [self.reviewButton setTintColor:[UIColor orangeColor]];
    [self.friendsButton setTintColor:[UIColor orangeColor]];
}

- (IBAction)skillsButtonPressed:(UIButton *)sender
{
    self.tableViewNumber = @2;
    [self.classButton setTintColor:[UIColor orangeColor]];
    [self.skillButton setTintColor:[UIColor blueColor]];
    [self.reviewButton setTintColor:[UIColor orangeColor]];
    [self.friendsButton setTintColor:[UIColor orangeColor]];
    [self.tableVIew reloadData];
}

- (IBAction)reviewsButtonPressed:(UIButton *)sender
{
    self.tableViewNumber = @3;
    [self.classButton setTintColor:[UIColor orangeColor]];
    [self.skillButton setTintColor:[UIColor orangeColor]];
    [self.reviewButton setTintColor:[UIColor blueColor]];
    [self.friendsButton setTintColor:[UIColor orangeColor]];
    [self.tableVIew reloadData];
}

- (IBAction)classesButtonPressed:(UIButton *)sender
{
    
    //perform segue
    [self performSegueWithIdentifier:@"showClasses" sender:self];

//    self.tableViewNumber = @1;
//    [self.classButton setTintColor:[UIColor blueColor]];
//    [self.skillButton setTintColor:[UIColor orangeColor]];
//    [self.reviewButton setTintColor:[UIColor orangeColor]];
//    [self.friendsButton setTintColor:[UIColor orangeColor]];
//    [self.tableVIew reloadData];
}

- (IBAction)friendsButtonPressed:(UIButton *)sender
{
    //perform segue
}

- (IBAction)reportButtonPressed:(UIButton *)sender
{
    [self reportAlert];
}

- (IBAction)followButtonPressed:(UIButton *)sender
{
    User *currentUser = [User currentUser];
    if ([self.followButton.titleLabel.text isEqualToString:@"Follow"])
    {
        Follow *follow = [Follow new];
        [follow setObject:currentUser forKey:@"from"];
        [follow setObject:self.selectedUser forKey:@"to"];
        [follow setObject:[NSDate date] forKey:@"friendTime"];
        [follow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 NSLog(@"friend saved");
                 [self.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
             }
         }];
        
    }
    else
    {
        for (Follow *follow in self.followingObjectsToBeDeleted)
        {
            [follow deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if (error == nil)
                 {
                     NSLog(@"%@ has been deleted", self.followingObjectsToBeDeleted);
                     [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
                     
                 }
             }];
        }
    }
}





-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [self queryForUserInfo];
    [self queryForFriends];
//    self.followButton.hidden = YES;
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
        [self doIfollowThisGuy];
        self.profileImage.userInteractionEnabled = NO;
//        self.followButton.hidden = NO;
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


-(void)calculateUserRating:(User *)user
{
    PFQuery *reviewsQuery = [Review query];
    [reviewsQuery includeKey:@"reviewed"];
    [reviewsQuery includeKey:@"reviewer"];
    [reviewsQuery includeKey:@"course"];
    [reviewsQuery whereKey:@"reviewed" equalTo:user];
    [reviewsQuery whereKey:@"hasBeenReviewed" equalTo:@1];
    [reviewsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             NSLog(@"found %lu reviews for the user" , (unsigned long)objects.count);
             self.reviewsArray = objects;
             float reviewsSum = 0;
             for (Review *review in self.reviewsArray)
             {
                 reviewsSum += [review.reviewRating intValue];
                 NSLog(@"review rating is %@", review.reviewRating);
             }
             if (self.reviewsArray.count == 0)
             {
                 self.rating.text = @"0 ratings";
                 // dont do anything, since dividing by zero will crash the app
             }
             else
             {
                 float reviewsAverage = (reviewsSum / self.reviewsArray.count);
                 float fiveScaleAverage = reviewsAverage * 2.5;
                 NSNumber *average = @(fiveScaleAverage);
//                 user.rating = average;
                 self.rating.text = [NSString stringWithFormat:@"Rating %@", average];
             }
         }
         else
         {
             NSLog(@"error finding reviews");
         }
     }];
}




-(void)queryForUserInfo
{
    if (self.selectedUser  &&  self.selectedUser != [User currentUser]) // IF COMING FROM TAKECOURSEVC AND WANNA SHOW THE TEACHERS PROFILE
    {
        [self calculateUserRating:self.selectedUser];

        PFQuery *coursesQuery = [Course query];
        [coursesQuery whereKey:@"teacher" equalTo:self.selectedUser];
        [coursesQuery orderByAscending:@"createdAt"];
        [coursesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 NSLog(@"selected user is %@", self.selectedUser);
                 

                 self.teachingArray= objects;
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
        PFRelation *coursesAsStudent = [self.selectedUser relationForKey:@"courses"];
        PFQuery *coursesAsStudentQuery = coursesAsStudent.query;
        [coursesAsStudentQuery whereKey:@"teacher" notEqualTo:self.selectedUser];
        [coursesAsStudentQuery findObjectsInBackgroundWithBlock:^(NSArray *courses, NSError *error)
         {
             if (error == nil)
             {
                 NSLog(@"here are the courses found %@", courses);
                 self.takingArray = courses;
                 [self.tableVIew reloadData];
             }
         }];
        
    }
    else // current user clicked on the profile button and wants to see his own profile
    {
        self.messageButton.hidden = YES;
        self.followButton.hidden = YES;
        self.reportButton.hidden = YES;

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
                 self.teachingArray = objects;
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
        PFRelation *coursesAsStudent = [currentUser relationForKey:@"courses"];
        PFQuery *coursesAsStudentQuery = coursesAsStudent.query;
        [coursesAsStudentQuery whereKey:@"teacher" notEqualTo:currentUser];
        [coursesAsStudentQuery findObjectsInBackgroundWithBlock:^(NSArray *courses, NSError *error)
         {
             if (error == nil)
             {
                 self.takingArray = courses;
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
    [self saveImage];
    [self loadProfilePicwithImage:self.chosenImage];
    
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if ([self.tableViewNumber  isEqual: @2]) // skills
    {
        Skill *skill = self.skillsArray[indexPath.row];
        cell.textLabel.text = [skill valueForKey:@"name"];
        NSString *timeString = [NSDateFormatter localizedStringFromDate:skill.createdAt dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Since %@", timeString];
    }
    else if ([self.tableViewNumber isEqual: @3]) // reviews
    {
        Review *review = self.reviewsArray[indexPath.row];
        cell.detailTextLabel.text = [review valueForKey:@"reviewContent"];
        User *reviewer = [review objectForKey:@"reviewer"];
        NSString *commentTime = [NSDateFormatter localizedStringFromDate:[reviewer valueForKey:@"createdAt"] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
        NSString *cellText = [NSString stringWithFormat:@"%@ - %@", [reviewer valueForKey:@"username"],commentTime];
        cell.textLabel.text = cellText;

    }
    else
    {
        Course *course = self.coursesArray[indexPath.row];
        NSString *timeString = [NSDateFormatter localizedStringFromDate:[course valueForKey:@"time"] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        NSString *secondTimeString = [NSDateFormatter localizedStringFromDate:[course valueForKey:@"time"] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
        NSString *titleAndTime = [NSString stringWithFormat:@"%@ at %@ on %@", [course valueForKey:@"title"] , timeString, secondTimeString];
        cell.textLabel.text = titleAndTime;
        cell.detailTextLabel.text = [course valueForKey:@"address"];
    }

    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.tableViewNumber isEqual:@2])
    {
        [tableView deselectRowAtIndexPath:indexPath animated:true];
    }
    else if ([self.tableViewNumber isEqual:@3])
    {
        self.reviewAtRow = self.reviewsArray[indexPath.row];
        [self performSegueWithIdentifier:@"reviews" sender:self];
    }
    else if ([self.tableViewNumber isEqual:@1])
    {
        self.courseAtRow = self.coursesArray[indexPath.row];
        [self performSegueWithIdentifier:@"showCourse" sender:self];
    }
  
}





-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"reviews"])
    {
        ShowReviewVC *showReviewVC = segue.destinationViewController;
        showReviewVC.selectedReview = self.reviewAtRow;
    }
    else if ([segue.identifier isEqualToString:@"showCourse"])
    {
        TakeCourseVC *takeCourseVC = segue.destinationViewController;
        takeCourseVC.selectedCourse = self.courseAtRow;
        takeCourseVC.selectedTeacher = [self.courseAtRow objectForKey:@"teacher"];
    }
    else if ([segue.identifier isEqualToString:@"connections"])
    {
        ConnectionsListVC *connectionsVC = segue.destinationViewController;
        connectionsVC.followersArray = self.followersArray;
        connectionsVC.followingArray = self.followingArray;
    }
    else if ([segue.identifier isEqualToString:@"profileToMessage"])
    {
        MessageConversationVC *messageVC = segue.destinationViewController;
        messageVC.otherUser = self.selectedUser;
        messageVC.origin = @"userProfile"; 
    }
    else if ([segue.identifier isEqual:@"showClasses"])
    {
        ClassesListVC *classesVC = segue.destinationViewController;
        classesVC.takingArray = self.takingArray;
        
        classesVC.teachingArray = self.teachingArray;
        
    }
}






-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.tableViewNumber  isEqual: @2])
    {
        return self.skillsArray.count;
    }
    else if ([self.tableViewNumber  isEqual: @3])
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

-(void)doIfollowThisGuy
{
    PFQuery *followerCheck = [Follow query];
    [followerCheck whereKey:@"from" equalTo:[PFUser currentUser]];
    [followerCheck whereKey:@"to" equalTo:self.selectedUser];
    [followerCheck findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (objects.count > 0)
         {
             [self.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
             self.followingObjectsToBeDeleted = objects;
         }
         else
         {
             [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
         }
     }];
}


-(void)reportAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report" message:@"Why do you want to report this user?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *sexuallyExplicitAction = [UIAlertAction actionWithTitle:@"Sexually explicit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                             {
                                                 Report *report = [Report new];
                                                 report.reporter = [User currentUser];
                                                 report.reported = self.selectedUser;
                                                 report.hasBeenTakenCareOf = @0;
                                                 report.reason = @"sexual";
                                                 [report saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                                  {
                                                      if (succeeded)
                                                      {
                                                          NSLog(@"sexually explicit report saved");
                                                          [PFCloud callFunctionInBackground:@"sendEmail"
                                                                             withParameters:@{ @"reporter" : report.reporter.username, @"reported" : report.reported.username, @"reason" : report.reason }
                                                                                      block:^(NSString *result, NSError *error) {
                                                                                          if (error == nil)
                                                                                          {
                                                                                              NSLog(@"email with report sent");
                                                                                          }
                                                                                          else
                                                                                          {
                                                                                              NSLog(@"error sending email with report");
                                                                                          }
                                                                                      }];
                                                          [self dismissViewControllerAnimated:YES completion:nil];
                                                      }
                                                      else
                                                      {
                                                          NSLog(@"sexual report NOT saved");
                                                      }
                                                  }];
                                             }];


    UIAlertAction *harrassmentHateSpeechAction = [UIAlertAction actionWithTitle:@"Harrasment or hate speech" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                  {
                                                      Report *report = [Report new];
                                                      report.reporter = [User currentUser];
                                                      report.reported = self.selectedUser;
                                                      report.hasBeenTakenCareOf = @0;
                                                      report.reason = @"hate";
                                                      [report saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                                       {
                                                           if (succeeded)
                                                           {
                                                               NSLog(@"hate report saved");
                                                               [PFCloud callFunctionInBackground:@"sendEmail"
                                                                                  withParameters:@{ @"reporter" : report.reporter.username, @"reported" : report.reported.username, @"course" : report.course.title, @"reason" : report.reason }
                                                                                           block:^(NSString *result, NSError *error) {
                                                                                               if (error == nil)
                                                                                               {
                                                                                                   NSLog(@"email with report sent");
                                                                                               }
                                                                                               else
                                                                                               {
                                                                                                   NSLog(@"error sending email with report");
                                                                                               }
                                                                                           }];
                                                               [self dismissViewControllerAnimated:YES completion:nil];
                                                           }
                                                           else
                                                           {
                                                               NSLog(@"hate report NOT saved");
                                                           }
                                                       }];
                                                  }];

    UIAlertAction *threateningAction = [UIAlertAction actionWithTitle:@"Threatening or violent" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                        {
                                            Report *report = [Report new];
                                            report.reporter = [User currentUser];
                                            report.reported = self.selectedUser;
                                            report.hasBeenTakenCareOf = @0;
                                            report.reason = @"threatening";
                                            [report saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                             {
                                                 if (succeeded)
                                                 {
                                                     NSLog(@"threatening report saved");
                                                     [PFCloud callFunctionInBackground:@"sendEmail"
                                                                        withParameters:@{ @"reporter" : report.reporter.username, @"reported" : report.reported.username, @"course" : report.course.title, @"reason" : report.reason }
                                                                                 block:^(NSString *result, NSError *error) {
                                                                                     if (error == nil)
                                                                                     {
                                                                                         NSLog(@"email with report sent");
                                                                                     }
                                                                                     else
                                                                                     {
                                                                                         NSLog(@"error sending email with report");
                                                                                     }
                                                                                 }];
                                                     [self dismissViewControllerAnimated:YES completion:nil];
                                                 }
                                                 else
                                                 {
                                                     NSLog(@"threatening report NOT saved");
                                                 }
                                             }];
                                        }];

    UIAlertAction *drugUseAction = [UIAlertAction actionWithTitle:@"Drug use" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                    {
                                        Report *report = [Report new];
                                        report.reporter = [User currentUser];
                                        report.reported = self.selectedUser;
                                        report.hasBeenTakenCareOf = @0;
                                        report.reason = @"drugs";
                                        [report saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                         {
                                             if (succeeded)
                                             {
                                                 NSLog(@"drug report saved");
                                                 [PFCloud callFunctionInBackground:@"sendEmail"
                                                                    withParameters:@{ @"reporter" : report.reporter.username, @"reported" : report.reported.username, @"reason" : report.reason }
                                                                             block:^(NSString *result, NSError *error) {
                                                                                 if (error == nil)
                                                                                 {
                                                                                     NSLog(@"email with report sent");
                                                                                 }
                                                                                 else
                                                                                 {
                                                                                     NSLog(@"error sending email with report");
                                                                                 }
                                                                             }];
                                                 [self dismissViewControllerAnimated:YES completion:nil];
                                             }
                                             else
                                             {
                                                 NSLog(@"drug report NOT saved");
                                             }
                                         }];
                                    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                   {
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                   }];

    [alert addAction:sexuallyExplicitAction];
    [alert addAction:harrassmentHateSpeechAction];
    [alert addAction:threateningAction];
    [alert addAction:drugUseAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}





@end
