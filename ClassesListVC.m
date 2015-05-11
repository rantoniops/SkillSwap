#import "ClassesListVC.h"
#import "SkillSwapStoryboard-Swift.h"
#import "UserProfileVC.h"
#import "TakeCourseVC.h"

@interface ClassesListVC ()  <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmendtedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSNumber *teachingOrTaking;
@property Course *courseToPass;

@end
@implementation ClassesListVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Courses";
    self.teachingOrTaking = @0;
//    NSLog(@"here are the teaching courses %@", self.teachingArray);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if ([self.teachingOrTaking isEqual: @0])
    {
        Course *course = self.teachingArray[indexPath.row];
        NSString *timeString = [NSDateFormatter localizedStringFromDate:[course valueForKey:@"time"] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        NSString *secondTimeString = [NSDateFormatter localizedStringFromDate:[course valueForKey:@"time"] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
        NSString *titleAndTime = [NSString stringWithFormat:@"%@ at %@ on %@", [course valueForKey:@"title"] , timeString, secondTimeString];
        cell.textLabel.text = titleAndTime;
        cell.detailTextLabel.text = [course valueForKey:@"address"];

    }
    else
    {
        Course *course = self.takingArray[indexPath.row];
        NSString *timeString = [NSDateFormatter localizedStringFromDate:[course valueForKey:@"time"] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        NSString *secondTimeString = [NSDateFormatter localizedStringFromDate:[course valueForKey:@"time"] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
        NSString *titleAndTime = [NSString stringWithFormat:@"%@ at %@ on %@", [course valueForKey:@"title"] , timeString, secondTimeString];
        cell.textLabel.text = titleAndTime;
        cell.detailTextLabel.text = [course valueForKey:@"address"];
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.teachingOrTaking isEqualToNumber:@0]) // followers
    {
        Course *selectedCourse = self.takingArray[indexPath.row];
        self.courseToPass = selectedCourse;
    }
    else // following
    {
        Course *selectedCourse = self.takingArray[indexPath.row];
        self.courseToPass = selectedCourse;
    }
    [self performSegueWithIdentifier:@"classListToTakeCourse" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TakeCourseVC *takeVC = segue.destinationViewController;
    takeVC.selectedCourse = self.courseToPass;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.teachingOrTaking isEqual: @0])
    {
        return self.teachingArray.count;
    }
    else
    {
        return self.takingArray.count;
    }
}



- (IBAction)segmentedControlPressed:(UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex == 0) // teaching
    {
        self.teachingOrTaking = @1; // switch to taking
        [self.tableView reloadData];
    }
    else
    {
        self.teachingOrTaking = @0; // switch to teaching
        [self.tableView reloadData];
    }
}



@end
