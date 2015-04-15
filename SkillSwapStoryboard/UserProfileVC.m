#import "UserProfileVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface UserProfileVC () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *rating;
@property (weak, nonatomic) IBOutlet UILabel *credits;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *skills;
@property (weak, nonatomic) IBOutlet UITableView *tableVIew;
@property (weak, nonatomic) IBOutlet UILabel *descriptionText;
@end
@implementation UserProfileVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    User *currentUser = [User currentUser];

    self.name.text = currentUser.username;
//    self.skills.text = currentUser.skills;

    


}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}






@end
