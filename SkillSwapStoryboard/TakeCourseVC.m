#import "TakeCourseVC.h"
#import "UserProfileVC.h"
#import "MessageConversationVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
@interface TakeCourseVC ()<UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *courseImage;
@property (weak, nonatomic) IBOutlet UIButton *teacherName;
@property (weak, nonatomic) IBOutlet UILabel *courseRating;
@property (weak, nonatomic) IBOutlet UILabel *courseName;
@property (weak, nonatomic) IBOutlet UILabel *courseDesciption;
@property (weak, nonatomic) IBOutlet UILabel *courseDuration;
@property (weak, nonatomic) IBOutlet UILabel *courseAddress;
@property (weak, nonatomic) IBOutlet UITableView *courseTableView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property NSArray *courseReviews;
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
    NSLog(@"selected course teacher is %@", self.selectedTeacher.username);
    if (self.selectedTeacher == self.currentUser)
    {
        self.followButton.hidden = YES;
        self.messageTeacherButton.hidden = YES;
        self.takeClassButton.hidden = YES;
    }
    self.courseName.text = self.selectedCourse.title;
    self.courseAddress.text = self.selectedCourse.address;
    self.courseDesciption.text = self.selectedCourse.courseDescription;
    NSString *timeString = [NSDateFormatter localizedStringFromDate:self.selectedCourse.time dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    NSLog(@"%@", timeString);
    self.courseDuration.text = timeString;
    [self.teacherName setTitle:self.selectedTeacher.username forState:UIControlStateNormal];
    [self.selectedCourse.courseMedia getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
    {
        if (!error)
        {
            UIImage *image = [UIImage imageWithData:data];
            self.courseImage.image = image;
            NSLog(@"pause here");
            // image can now be set on a UIImageView

        }
    }];
}

- (IBAction)onTeacherNameButtonTapped:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"takeCourseToTeacherProfile" sender:self];
}


- (IBAction)onTakeClassButtonPressed:(UIButton *)sender
{
    [self confirmAlert];
}


-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    if (self.selectedCourse.teacher == self.currentUser)
    {
        self.followButton.hidden = YES;
        self.takeClassButton.hidden = YES;
        self.messageTeacherButton.hidden = YES;
        
    }
    [self doIfollowThisGuy];
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
                 [self dismissViewControllerAnimated:true completion:nil];
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


-(void)queryForCourseReviews
{
    PFQuery *reviewsQuery = [Review query];
    [reviewsQuery whereKey:@"course" equalTo:self.selectedCourse];
    [reviewsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             self.courseReviews = objects;
             
         }
     }];
}


- (IBAction)dismissButton:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];    
}

- (IBAction)followButtonTap:(UIButton *)sender
{
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
    Review *review = self.courseReviews[indexPath.row];
    NSString *reviewerString = [NSString stringWithFormat:@"%@",[review valueForKey:@"reviewer"]];
    cell.detailTextLabel.text = reviewerString;
    cell.textLabel.text = [review valueForKey:@"reviewContent"];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.courseReviews.count;
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
    
//    [self.videoController setContentURL:self.videoURL];
    [self.videoController.view setFrame:CGRectMake (0, 0, 320, 460)];
    [self.view addSubview:self.videoController.view];
    
    [self.videoController play];
}




@end
