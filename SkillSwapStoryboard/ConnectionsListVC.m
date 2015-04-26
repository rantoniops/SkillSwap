#import "ConnectionsListVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface ConnectionsListVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ConnectionsListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)followingButtonPressed:(UIButton *)sender
{

}

- (IBAction)followerButtonPressed:(UIButton *)sender
{

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
