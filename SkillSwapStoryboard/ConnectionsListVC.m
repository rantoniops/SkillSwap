#import "ConnectionsListVC.h"
#import "SkillSwapStoryboard-Swift.h"
#import "UserProfileVC.h"
@interface ConnectionsListVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSNumber *followersOrFollowing;
@property User *selectedConnection;
@end

@implementation ConnectionsListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.followersOrFollowing = @1;
}


- (IBAction)segmentedControl:(UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex == 0) // following
    {
        self.followersOrFollowing = @1;
        [self.tableView reloadData];
    }
    else
    {
        self.followersOrFollowing = @0; // followers
        [self.tableView reloadData];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.followersOrFollowing isEqualToNumber:@0]) // followers
    {
        Follow *followingUser = self.followersArray[indexPath.row];
        self.selectedConnection = followingUser.from;
    }
    else // following
    {
        Follow *followerUser = self.followingArray[indexPath.row];
        self.selectedConnection = followerUser.to;
    }
    [self performSegueWithIdentifier:@"connectionProfile" sender:self];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UserProfileVC *connectionVC = segue.destinationViewController;
    connectionVC.selectedUser = self.selectedConnection;
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
