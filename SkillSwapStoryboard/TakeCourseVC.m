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
@property User *currentUser;
@property (strong, nonatomic) MPMoviePlayerController *videoController;
@end
@implementation TakeCourseVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUser = [User currentUser];
    if (self.selectedCourse.teacher == self.currentUser)
    {
        self.followButton.hidden = YES;
    }

    UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.courseImage addGestureRecognizer:photoTap];
    self.courseName.text = self.selectedCourse.title;
    self.courseAddress.text = self.selectedCourse.address;
    self.courseDesciption.text = self.selectedCourse.courseDescription;
    NSString *timeString = [NSDateFormatter localizedStringFromDate:self.selectedCourse.time dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    NSLog(@"%@", timeString);
    self.courseDuration.text = timeString;
    [self.teacherName setTitle:self.selectedCourse.teacher.username forState:UIControlStateNormal];
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



- (IBAction)nopeButtonTap:(UIButton *)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
    
}
- (IBAction)dismissButton:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];    
}

- (IBAction)followButtonTap:(UIButton *)sender
{
    User *currentUser = [User currentUser];
    PFRelation *friendRelation = [currentUser relationForKey:@"friends"];
    if ([self.followButton.titleLabel.text isEqualToString: @"Follow"]) {
        [friendRelation addObject:self.selectedCourse.teacher];
        [self.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 NSLog(@"friend saved");
                 NSLog(@"Here are my friends after adding %@" , [currentUser relationForKey:@"friends"]);
                 
             }
             else
             {
                 NSLog(@"add friend NOT saved");
             }
         }];

    }
    else
    {
        [friendRelation removeObject:self.selectedCourse.teacher];
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 NSLog(@"friend removed");
                 NSLog(@"Here are my friends after removing %@" , [currentUser relationForKey:@"friends"]);
             }
             else
             {
                 NSLog(@"remove friend NOT saved");
             }
         }];
    }


}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"messageTeacher"])
    {
        MessageConversationVC *messageVC = segue.destinationViewController;
        messageVC.otherUser = self.selectedCourse.teacher;
        messageVC.selectedCourse = self.selectedCourse;
        messageVC.origin = @"takeCourse";
    }
    else if ([segue.identifier isEqualToString:@"takeCourseToTeacherProfile"])
    {
        UserProfileVC *profileVC = segue.destinationViewController;
        profileVC.selectedUser = self.selectedCourse.teacher;
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
