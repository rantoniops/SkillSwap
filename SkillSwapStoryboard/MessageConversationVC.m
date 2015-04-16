#import "MessageConversationVC.h"
@interface MessageConversationVC () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *messages;
@end
@implementation MessageConversationVC
- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self queryMessages];
}

-(void)queryMessages
{
    PFQuery *query = [Message query];
    [query whereKey:@"messageSender" equalTo:[User currentUser]];
    [query whereKey:@"messageReceiver" equalTo:self.selectedTeacher];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resignFirstResponder];
    return true;
}

- (IBAction)onSendButtonPressed:(UIButton *)sender
{
    Message *newMessage = [Message new];
    newMessage.messageBody = self.messageTextField.text;
    newMessage.messageSender = [User currentUser];
    newMessage.messageReceiver = self.selectedTeacher;
    [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             NSLog(@"msg saved");
             [self queryMessages];
         }
         else
         {
             NSLog(@"msg NOT saved");
         }
     }];
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
