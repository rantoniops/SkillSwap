#import "CourseListVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface CourseListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *courseListTableView;
@end
@implementation CourseListVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    Course *course = self.courses[indexPath.row];
    cell.textLabel.text = [course valueForKey:@"title"];
    cell.detailTextLabel.text = [course valueForKey:@"address"];
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.courses.count;
}




@end
