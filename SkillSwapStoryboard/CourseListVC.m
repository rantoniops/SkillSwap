#import "CourseListVC.h"
#import "TakeCourseVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface CourseListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *courseListTableView;
@property Course *courseAtRow;
@end
@implementation CourseListVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Classes List";
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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.courseAtRow = self.courses[indexPath.row];
    [self performSegueWithIdentifier:@"listToCourse" sender:self];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TakeCourseVC *takeCourseVC = segue.destinationViewController;
    takeCourseVC.selectedCourse = self.courseAtRow;
    takeCourseVC.selectedTeacher = [self.courseAtRow objectForKey: @"teacher"];
}



@end
