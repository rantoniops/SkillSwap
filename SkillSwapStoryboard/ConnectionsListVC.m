#import "ConnectionsListVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface ConnectionsListVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSNumber *followersOrFollowing;
@end

@implementation ConnectionsListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.followersOrFollowing = @0;
}

- (IBAction)followingButtonPressed:(UIButton *)sender
{
    self.followersOrFollowing = @1;
    [self.tableView reloadData];

}

- (IBAction)followerButtonPressed:(UIButton *)sender
{
    self.followersOrFollowing = @0;
    [self.tableView reloadData];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if ([self.followersOrFollowing isEqual: @0])
    {
        Follow *followerForRow = self.followersArray[indexPath.row];
        User *user = [followerForRow objectForKey:@"from"];
        cell.textLabel.text = [user valueForKey:@"username"];
//        cell.detailTextLabel.text = ;
    }
    else
    {
        Follow *followingForRow = self.followingArray[indexPath.row];
        User *user = [followingForRow objectForKey:@"to"];
        
        cell.textLabel.text = [user valueForKey:@"username"];
//        cell.detailTextLabel.text = ;
    }
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.followersOrFollowing isEqual: @0])
    {
        return self.followersArray.count;
    }
    else
    {
        return self.followingArray.count;
    }
}


@end
