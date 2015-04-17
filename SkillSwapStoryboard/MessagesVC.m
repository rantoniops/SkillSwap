#import "MessagesVC.h"
#import "MessageConversationVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface MessagesVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *messages;
@property NSArray *conversations;
@end
@implementation MessagesVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}


-(void)viewWillAppear:(BOOL)animated
{
    [self queryConversations];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"messageConversation" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSLog(@"going to prepare for segue");
}


//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    MessageConversationVC *messageConversationVC = segue.destinationViewController;
////    messageConversationVC.selectedConversation = 
//}


-(void)queryConversations
{
    PFQuery *query = [Conversation query];
    [query whereKey:@"users" equalTo:[User currentUser]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             NSLog(@"Successfully retrieved %lu conversations.", (unsigned long)objects.count);
             self.conversations = objects;
             [self.tableView reloadData];
         }
         else
         {
             NSLog(@"Error: %@ %@", error, [error userInfo]);
         }
     }];
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resignFirstResponder];
    return true;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.conversations.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    Conversation *conversationToShow = self.conversations[indexPath.row];

    cell.textLabel.text = @"last message will show here";


    for (User *user in conversationToShow.users)
    {
        if (user == [User currentUser])
        {
            NSLog(@"not him");
        }
        else
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", user.username];
        }
    }


    return cell;
}


@end
