    #import "MessagesVC.h"
#import "MessageConversationVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface MessagesVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *conversations;
@property Conversation *conversationToPass;
@property User *otherUserToPass;
@end
@implementation MessagesVC



- (void)viewDidLoad
{
    [super viewDidLoad];

}


-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [self queryConversations];
    self.navigationItem.title = @"Conversations";
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.conversationToPass = self.conversations[indexPath.row];

    for (User *user in self.conversationToPass.users)
    {
        if (user == [User currentUser])
        {
            NSLog(@"iteratedUser is current user");
        }
        else
        {
            self.otherUserToPass = user;
        }
    }

    [self performSegueWithIdentifier:@"messageConversation" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MessageConversationVC *messageConversationVC = segue.destinationViewController;
    messageConversationVC.selectedConversation = self.conversationToPass;
    messageConversationVC.otherUser = self.otherUserToPass;
    messageConversationVC.origin = @"messages";
}


-(void)queryConversations
{
    PFQuery *query = [Conversation query];
    [query whereKey:@"users" equalTo:[User currentUser]];
    [query includeKey:@"users"];
    [query includeKey:@"course"];
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
    PFQuery *query = [Message query];
    [query whereKey:@"conversation" equalTo: conversationToShow];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             NSLog(@"Successfully retrieved %lu messages.", (unsigned long)objects.count);
             Message *message = objects.firstObject;
             cell.textLabel.text = message.messageBody;
         }
         else
         {
             NSLog(@"Error: %@ %@", error, [error userInfo]);
         }
     }];
    for (User *user in conversationToShow.users)
    {
        if (user != [User currentUser])
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", user.username];
        }
    }
    return cell;
}

//- (void)keyboardWillShow:(NSNotification *)notification
//{
//    // move the view up so that the login button is 8 points above the keyboard
//    [self adjustScreenForKeyboard:notification target:self. offset:8.0f];
//}



@end
