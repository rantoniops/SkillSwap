#import "MessageConversationVC.h"
@interface MessageConversationVC () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *messages;
@property Conversation *conversation;
@property int conversationGotUsed;
@end
@implementation MessageConversationVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.conversationGotUsed = 0;
}


-(void)viewWillAppear:(BOOL)animated
{
    if ([self.origin isEqualToString:@"messages"])
    {
        NSLog(@"coming from messages, selected conversation found");
        self.conversation = self.selectedConversation;
        [self queryMessagesInExistingConversation];
    }
    else if ([self.origin isEqualToString:@"takeCourse"]) // SOMEONE IS MESSAGING A TEACHER
    {
        NSLog(@"coming from takeCourse, creating new conversation, we'll trash it in viewwilldissappear if no messaging occurs");
        Conversation *newConversation = [Conversation new];
        [newConversation addObject:[User currentUser] forKey:@"users"];
        [newConversation addObject:self.otherUser forKey:@"users"]; // OTHER USER HERE IS THE TEACHER
        newConversation.course = self.selectedCourse;
        self.conversation = newConversation;
        [newConversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 NSLog(@"conversation created");
             }
             else
             {
                 NSLog(@"error, conversation NOT created");
             }
         }];
    }
}


-(void)queryMessagesInExistingConversation
{
    PFQuery *query = [Message query];
    NSLog(@"querying for messages in existing convo");
    [query whereKey:@"conversation" equalTo:self.conversation];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             if (objects.count > 0)
             {
                 self.conversationGotUsed = 1;
             }

             NSLog(@"Successfully retrieved %lu messages.", (unsigned long)objects.count);
             self.messages = objects;
             [self.tableView reloadData];
         }
         else
         {
             NSLog(@"Error: %@ %@", error, [error userInfo]);
         }
     }];
}




- (IBAction)onSendButtonPressed:(UIButton *)sender
{
    self.conversationGotUsed = 1;
    Message *newMessage = [Message new];
    newMessage.messageBody = self.messageTextField.text;
    newMessage.messageSender = [User currentUser];
    newMessage.messageReceiver = self.otherUser; // THIS WILL DEPEND ON THE ORIGIN
    newMessage.course = self.conversation.course;
    newMessage.conversation = self.conversation;
    [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             NSLog(@"msg fron new convo saved");

             /////////////////// PUSH NOTIFICATIONS /////////////////////

             // Find users
             PFQuery *userQuery = [User query];
             [userQuery whereKey:@"objectId" equalTo:self.otherUser.objectId];
             // Find devices associated with these users
             PFQuery *pushQuery = [PFInstallation query];
             [pushQuery whereKey:@"user" matchesQuery:userQuery];
             // Send push notification to query
             PFPush *push = [[PFPush alloc] init];
             [push setQuery:pushQuery]; // Set our Installation query
             [push setMessage: self.messageTextField.text];
             [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (succeeded)
                  {
                      NSLog(@"push success");
                  }
                  else
                  {
                      NSLog(@"push error");
                  }
              }];

             /////////////////// PUSH NOTIFICATIONS END /////////////////

             
             [self queryMessagesInExistingConversation];

         }
         else
         {
             NSLog(@"msg from new convo NOT saved");
         }
     }];

}





-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"view will dissappear");
    if (self.conversationGotUsed == 1)
    {
        NSLog(@"conversation got used, will not get deleted");
    }
    else
    {
        NSLog(@"conversation didnt get used, will get deleted");
        [self.conversation deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 NSLog(@"conversation deleted");
             }
             else
             {
                 NSLog(@"error, conversation NOT deleted");
             }
         }];
    }
}















// other methods //


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

- (IBAction)onGoBackPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    Message *messageToShow = self.messages[indexPath.row];
    cell.textLabel.text = messageToShow.messageBody;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", messageToShow.messageSender.username];
    return cell;
}




@end
