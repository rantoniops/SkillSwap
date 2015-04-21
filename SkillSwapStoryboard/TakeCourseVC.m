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
@end
@implementation TakeCourseVC
- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [self confirmAlert];
}

-(void)confirmAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm sign up" message:@"The poster will be sent a notification"preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmClass = [UIAlertAction actionWithTitle:@"Confirm Class" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
    {
        User *currentUser = [User currentUser];
        PFRelation *relation = [currentUser relationForKey:@"courses"];
        [relation addObject: self.selectedCourse];
//        self.selectedCourse.students = [User currentUser];
//        currentUser.course = self.selectedCourse;
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 // IF WE TRY TO SET AND GET CREDITS WITH DOT NOTATION THE APP WILL CRASH SAYING UNRECOGNIZED SELECTOR SENT TO INSTANCE, IF WE CHANGE IT TO VALUEFORKEY AND SETVALUEFORKEY IT WORKS FINE. THIS IS WEIRD
                 int newCreditCount = [[currentUser valueForKey:@"credits"] intValue] -1;
                 NSNumber *creditCount = [NSNumber numberWithInt:newCreditCount];
                 [currentUser setValue:creditCount forKey:@"credits"];
                 NSLog(@"course saved");
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
//        NSLog(@"selected teacher is %@", self.selectedCourse.teacher);
        messageVC.selectedCourse = self.selectedCourse;
    }
}



@end
