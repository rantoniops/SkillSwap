#import "TakeCourseVC.h"
#import "UserProfileVC.h"
#import "MessageConversationVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
@interface TakeCourseVC ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *courseImage;
@property (weak, nonatomic) IBOutlet UIButton *teacherName;
@property (weak, nonatomic) IBOutlet UILabel *courseRating;
@property (weak, nonatomic) IBOutlet UILabel *courseName;
@property (weak, nonatomic) IBOutlet UILabel *courseDesciption;
@property (weak, nonatomic) IBOutlet UILabel *courseDuration;
@property (weak, nonatomic) IBOutlet UILabel *courseAddress;
@property (weak, nonatomic) IBOutlet UITableView *courseTableView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property NSArray *teacherReviews;
@property User *currentUser;
@property (strong, nonatomic) MPMoviePlayerController *videoController;
@property (weak, nonatomic) IBOutlet UIButton *takeClassButton;
@property (weak, nonatomic) IBOutlet UIButton *messageTeacherButton;
@property NSArray *followingObjectsToBeDeleted;
@end
@implementation TakeCourseVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUser = [User currentUser];
    [self.takeClassButton setTitle:@"Join" forState:UIControlStateNormal];
    if (self.selectedTeacher == self.currentUser)
    {
        self.followButton.hidden = YES;
        self.messageTeacherButton.hidden = YES;
        self.takeClassButton.hidden = YES;
    }
    self.navigationItem.title = @"Class";

    self.courseName.text = [self.selectedCourse valueForKey:@"title"];
    self.courseAddress.text = [self.selectedCourse valueForKey:@"address"];
    self.courseDesciption.text = [self.selectedCourse valueForKey:@"coursedescription"];
    NSString *timeString = [NSDateFormatter localizedStringFromDate:[self.selectedCourse valueForKey:@"time"] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    NSLog(@"%@", timeString);
    self.courseDuration.text = timeString;
    [self.teacherName setTitle:self.selectedTeacher.username forState:UIControlStateNormal];
    [[self.selectedCourse valueForKey:@"courseMedia"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
    {
        if (!error)
        {
            UIImage *image = [UIImage imageWithData:data];
            self.courseImage.image = image;
        }
    }];
}

- (IBAction)onTeacherNameButtonTapped:(UIButton *)sender
{
   
    
    
    [self performSegueWithIdentifier:@"takeCourseToTeacherProfile" sender:self];
}


- (IBAction)onTakeClassButtonPressed:(UIButton *)sender
{
    if ([self.takeClassButton.titleLabel.text isEqualToString:@"Join"])
    {
        [self confirmAlert];
    }
    else
    {
        [self onCancelButtonTap];
    }
    
}


-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    if ([self.selectedCourse valueForKey:@"teacher"] == self.currentUser)
    {
        self.followButton.hidden = YES;
        self.takeClassButton.hidden = YES;
        self.messageTeacherButton.hidden = YES;
    }
    NSDate *now = [NSDate date];
    NSLog(@" %@ course time, %@ now ",  [self.selectedCourse valueForKey:@"time"], now);
    if ([[self.selectedCourse valueForKey:@"time"] earlierDate: now] == [self.selectedCourse valueForKey:@"time"])
    {
        self.takeClassButton.hidden = YES;
        NSLog(@" course is earlier");
    }
    [self doIfollowThisGuy];
    [self amItakingThisCourse];
    [self calculateUserRating:self.selectedTeacher];
}

-(void)amItakingThisCourse
{
    PFUser *currentUser = [User currentUser];
    PFRelation *relation = [currentUser relationForKey:@"courses"];
    PFQuery *relationQuery = relation.query;
    [relationQuery includeKey:@"courses"];
    [relationQuery whereKey:@"courses" equalTo: self.selectedCourse];
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (objects.count > 0)
         {
             [self.takeClassButton setTitle:@"No longer attend" forState:UIControlStateNormal];
             self.takeClassButton.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.5];
         }
         else
         {
             [self.takeClassButton setTitle:@"Join" forState:UIControlStateNormal];
         }
     }];
}


-(void)doIfollowThisGuy
{
    PFQuery *followerCheck = [Follow query];
    [followerCheck whereKey:@"from" equalTo:[PFUser currentUser]];
    [followerCheck whereKey:@"to" equalTo:self.selectedTeacher];
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

-(void)onCancelButtonTap
{
    User *currentUser = [User currentUser];
    NSLog(@"here are the current users courses now %@", [currentUser valueForKey:@"courses"]);
    PFRelation *relation = [currentUser relationForKey:@"courses"];
    [relation removeObject: self.selectedCourse];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             NSLog(@"class was deleted and saved");
             [self.navigationController popViewControllerAnimated:true];
             NSLog(@"here are the current users courses now %@", [currentUser valueForKey:@"courses"]);
             [self.takeClassButton setTitle:@"Join" forState:UIControlStateNormal];
         }
         else
         {
             NSLog(@"class was NOT deleted");
         }
     }];
}

-(void)confirmAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm sign up" message:@"The poster will be sent a notification"preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmClass = [UIAlertAction actionWithTitle:@"Confirm Class" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
    {
        User *currentUser = [User currentUser];
        PFRelation *relation = [currentUser relationForKey:@"courses"];
        [relation addObject: self.selectedCourse];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 NSLog(@"current user saved");
                 [self.navigationController popViewControllerAnimated:true];
             }
             else
             {
                 NSLog(@"current user NOT saved");
             }
         }];


        // CREATING EMTPY REVIEW FOR TEACHER TO RATE STUDENT LATER
        Review *emptyTeacherToStudentReview = [Review new];
        emptyTeacherToStudentReview.reviewer = [self.selectedCourse objectForKey:@"teacher"];
        emptyTeacherToStudentReview.reviewed = [User currentUser];
        emptyTeacherToStudentReview.hasBeenReviewed = @0;
        emptyTeacherToStudentReview.course = self.selectedCourse;
        [emptyTeacherToStudentReview saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 NSLog(@"review for teacher to rate student saved");
             }
             else
             {
                 NSLog(@"review for teacher to rate student NOT saved");
             }
         }];



        // CREATING EMPTY REVIEW FOR STUDENT TO RATE TEACHER LATER
        Review *emptyStudentToTeacherReview = [Review new];
        emptyStudentToTeacherReview.reviewer = [User currentUser];
        emptyStudentToTeacherReview.reviewed = [self.selectedCourse objectForKey:@"teacher"];
        emptyStudentToTeacherReview.hasBeenReviewed = @0;
        emptyStudentToTeacherReview.course = self.selectedCourse;
        [emptyStudentToTeacherReview saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 NSLog(@"review for student to rate teacher saved");
             }
             else
             {
                 NSLog(@"review for student to rate teacher NOT saved");
             }
         }];


    }];


    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
       
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:confirmClass];
    [self presentViewController:alert animated:true completion:nil];
    
}


//-(void)queryForteacherReviews
//{
//    PFQuery *reviewsQuery = [Review query];
//    [reviewsQuery includeKey:@"reviewer"];
//    [reviewsQuery includeKey:@"reviewed"];
//    [reviewsQuery whereKey:@"reviewed" equalTo:self.selectedTeacher];
//    [reviewsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//     {
//         if (error == nil)
//         {
//             if (objects.count > 0)
//             {
//                 if (self.selectedTeacher.rating == nil)
//                 {
//                     self.courseRating.text = @"0 ratings.";
//                 }
//                 else
//                 {
//                     self.courseRating.text = [NSString stringWithFormat:@"Rating %@", self.selectedTeacher.rating ];
//                 }
//                 self.teacherReviews = objects;
//                 [self.courseTableView reloadData];
//             }
//             else
//             {
//                 self.courseRating.text = @"0 ratings.";
//             }
//         }
//     }];
//}


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
             self.teacherReviews = objects;
             int reviewsSum = 0;
             for (Review *review in self.teacherReviews)
             {
                 reviewsSum += [review.reviewRating intValue];
                 NSLog(@"review rating is %@", review.reviewRating);
             }
             if (self.teacherReviews.count == 0)
             {
                 self.courseRating.text = @"0 ratings";
                 // dont do anything, since dividing by zero will crash the app
             }
             else
             {
                 int reviewsAverage = (reviewsSum / self.teacherReviews.count);
                 NSNumber *average = @(reviewsAverage);
                 self.courseRating.text = [NSString stringWithFormat:@"Rating %@", average];
             }
         }
         else
         {
             NSLog(@"error finding reviews");
         }
     }];
}



- (IBAction)dismissButton:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];    
}

- (IBAction)followButtonTap:(UIButton *)sender
{
    [self onCancelButtonTap];
    User *currentUser = [User currentUser];
    if ([self.followButton.titleLabel.text isEqualToString:@"Follow"])
    {
        Follow *follow = [Follow new];
        [follow setObject:currentUser forKey:@"from"];
        [follow setObject:self.selectedTeacher forKey:@"to"];
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    Review *review = self.teacherReviews[indexPath.row];

    NSString *timeString = [NSDateFormatter localizedStringFromDate:review.updatedAt dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];

    NSString *reviewerString = [NSString stringWithFormat:@"%@ on %@", review.reviewer.username, timeString];
    cell.detailTextLabel.text = reviewerString;
//    cell.detailTextLabel.text = review.reviewer.username;

    cell.textLabel.text = [review valueForKey:@"reviewContent"];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.teacherReviews.count;
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"messageTeacher"])
    {
        MessageConversationVC *messageVC = segue.destinationViewController;
        messageVC.otherUser = self.selectedTeacher;
        messageVC.selectedCourse = self.selectedCourse;
        messageVC.origin = @"takeCourse";
    }
    else if ([segue.identifier isEqualToString:@"takeCourseToTeacherProfile"])
    {
        UserProfileVC *profileVC = segue.destinationViewController;
        profileVC.selectedUser = self.selectedTeacher;
    }
}


-(void)playCourseVideo
{
    self.videoController = [[MPMoviePlayerController alloc] init];
    [self.videoController.view setFrame:CGRectMake (0, 0, 320, 460)];
    [self.view addSubview:self.videoController.view];
    [self.videoController play];
}




@end
