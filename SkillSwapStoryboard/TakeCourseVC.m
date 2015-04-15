#import "TakeCourseVC.h"
#import "SkillSwapStoryboard-Swift.h"


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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self queryForCourseInfo];
    
    
}



-(void)queryForCourseInfo
{
    PFQuery *courseQuery = [PFQuery queryWithClassName:@"Course"];
    [courseQuery whereKey:@"address" containsString:self.selectedAddress];
    [courseQuery getFirstObjectInBackgroundWithBlock: ^(PFObject *course, NSError *error)
     {
         self.courseName.text = course[@"title"];
         self.courseAddress.text = course[@"address"];
         self.courseDesciption.text = course[@"description"];
         self.courseDuration.text = course[@"time"];
//         self.teacherName.text = course[@"teacher"] must be added and teacher is still just a pointer
         
     }];

}

- (IBAction)takeClass:(UIButton *)sender {
}

- (IBAction)nopeButtonTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
    
}
- (IBAction)dismissButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];    
}




-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

@end
