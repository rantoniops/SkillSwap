#import "TakeCourseVC.h"
#import "MessageConversationVC.h"
@interface TakeCourseVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *courseImage;
@property (weak, nonatomic) IBOutlet UILabel *teacherName;
@property (weak, nonatomic) IBOutlet UILabel *courseRating;
@property (weak, nonatomic) IBOutlet UILabel *courseName;
@property (weak, nonatomic) IBOutlet UILabel *courseCredit;
@property (weak, nonatomic) IBOutlet UILabel *courseDesciption;
@property (weak, nonatomic) IBOutlet UILabel *courseDuration;
@property (weak, nonatomic) IBOutlet UILabel *courseAddress;
@property (weak, nonatomic) IBOutlet UITableView *courseTableView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property User *currentUser;



@end
@implementation TakeCourseVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUser = [User currentUser];
    if (self.selectedCourse.teacher == self.currentUser) {
        self.followButton.hidden = YES;
    }
    
    
    self.courseName.text = self.selectedCourse.title;
    self.courseAddress.text = self.selectedCourse.address;
    self.courseDesciption.text = self.selectedCourse.courseDescription;
    NSString *timeString = [NSDateFormatter localizedStringFromDate:self.selectedCourse.time dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    NSLog(@"%@", timeString);
    self.courseDuration.text = timeString;
    self.teacherName.text = self.selectedCourse.teacher.username;
    [self.selectedCourse.courseMedia getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            self.courseImage.image = image;
            NSLog(@"pause here");
            // image can now be set on a UIImageView

        }
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}


- (IBAction)takeClass:(UIButton *)sender
{
    NSLog(@"Here are the current users credits: %@" , [[User currentUser]valueForKey:@"credits"]);
    int creditCount = [[[User currentUser]valueForKey:@"credits"] intValue];
    
//    if (creditCount < 1)
//    {
//        [self denyAlert];
//    }
//    else
//    {
        [self confirmAlert];
//    }
}

-(void)denyAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Insufficient Credits" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler: nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}


-(void)confirmAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm sign up" message:@"The poster will be sent a notification"preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmClass = [UIAlertAction actionWithTitle:@"Confirm Class" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
    {
        User *currentUser = [User currentUser];
        PFRelation *relation = [currentUser relationForKey:@"courses"];
        [relation addObject: self.selectedCourse];
        [self exchangeCredits];
        [self.selectedCourse.teacher saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
         }];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 // IF WE TRY TO SET AND GET CREDITS WITH DOT NOTATION THE APP WILL CRASH SAYING UNRECOGNIZED SELECTOR SENT TO INSTANCE, IF WE CHANGE IT TO VALUEFORKEY AND SETVALUEFORKEY IT WORKS FINE. THIS IS WEIRD
                 NSLog(@"course saved");
                 NSLog(@"%@", self.selectedCourse.teacher);
             }
             else
             {
                 NSLog(@"course NOT saved");
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
-(void)exchangeCredits
{
    int newCreditCount = [[self.currentUser valueForKey:@"credits"] intValue] -1;
    int teacherNewCreditCount = [[self.selectedCourse.teacher valueForKey:@"credits"] intValue]+1;
    NSNumber *teacherCreditCount = [NSNumber numberWithInt:teacherNewCreditCount];
    NSNumber *creditCount = [NSNumber numberWithInt:newCreditCount];
    NSNumber *manyCredits = [NSNumber numberWithInt:3];
    [self.selectedCourse.teacher setValue:manyCredits forKey:@"credits"];
    [self.currentUser setValue:creditCount forKey:@"credits"];
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
    }
}



@end
