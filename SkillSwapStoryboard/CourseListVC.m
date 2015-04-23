#import "CourseListVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface CourseListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *courseListTableView;
@end
@implementation CourseListVC
- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    Course *course = self.courses[indexPath.row];
    cell.textLabel.text = course.title;
    cell.detailTextLabel.text = course.address;
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.courses.count;
}




@end
