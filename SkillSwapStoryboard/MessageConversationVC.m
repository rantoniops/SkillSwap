#import "MessageConversationVC.h"
@interface MessageConversationVC () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *messages;
@property NSArray *conversation;
@end
@implementation MessageConversationVC
- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.selectedConversation)
    {
        [self queryMessagesInExistingConversation];
//        [self.tableView reloadData];
    }
    else
    {
        //        PFQuery *teacherIsCurrentUser = [Conversation query];
        //        [teacherIsCurrentUser whereKey:@"teacher" equalTo:[User currentUser]];
        //        PFQuery *studentIsCurrentUser = [Conversation query];
        //        [studentIsCurrentUser whereKey:@"student" equalTo:[User currentUser]];
        //        PFQuery *query = [PFQuery orQueryWithSubqueries:@[teacherIsCurrentUser,studentIsCurrentUser]];
        //        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
        //        {
        //
        //        }];

    }
}


-(void)queryMessagesInExistingConversation
{
    PFQuery *query = [Message query];
    [query whereKey:@"conversation" equalTo:self.conversation];
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




//-(void)queryMessages
//{
//    PFQuery *query = [Message query];
//    [query whereKey:@"messageSender" equalTo:[User currentUser]];
//    [query whereKey:@"messageReceiver" equalTo:self.selectedTeacher];
//    [query whereKey:@"course" equalTo:self.selectedCourse];
//    [query orderByDescending:@"createdAt"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//     {
//         if (!error)
//         {
//             NSLog(@"Successfully retrieved %lu messages.", (unsigned long)objects.count);
//             self.messages = objects;
//             [self.tableView reloadData];
//         }
//         else
//         {
//             NSLog(@"Error: %@ %@", error, [error userInfo]);
//         }
//     }];
//}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resignFirstResponder];
    return true;
}

- (IBAction)onSendButtonPressed:(UIButton *)sender
{
    PFQuery *query = [Conversation query];
    [query whereKey:@"users" containsAllObjectsInArray:@[ [User currentUser], self.selectedTeacher]];
    [query whereKey:@"course" equalTo:self.selectedCourse];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (objects)
         {
             NSLog(@"Successfully retrieved %lu convos.", (unsigned long)objects.count);
             self.conversation = objects;

             Message *newMessage = [Message new];
             newMessage.messageBody = self.messageTextField.text;
             newMessage.messageSender = [User currentUser];
             newMessage.messageReceiver = self.selectedTeacher;
             newMessage.course = self.selectedCourse;
             newMessage.conversation = self.conversation;
             [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (succeeded)
                  {
                      NSLog(@"msg saved");

                      [self queryMessagesInExistingConversation];
                  }
                  else
                  {
                      NSLog(@"msg NOT saved");
                  }
              }];


         }
         else
         {
             NSLog(@"conversation not found, let's create one");


             Conversation *newConversation = [Conversation new];
             //        newConversation.student = [User currentUser];
             //        newConversation.teacher = self.selectedTeacher;

             [newConversation addObject:[User currentUser] forKey:@"users"];
             [newConversation addObject:self.selectedTeacher forKey:@"users"];

             newConversation.course = self.selectedCourse;
             [newConversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (succeeded)
                  {
                      NSLog(@"conversation created");


                      Message *newMessage = [Message new];
                      newMessage.messageBody = self.messageTextField.text;
                      newMessage.messageSender = [User currentUser];
                      newMessage.messageReceiver = self.selectedTeacher;
                      newMessage.course = self.selectedCourse;

                      self.conversation = newConversation;
//                      newMessage.conversation = newConversation;

                      [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                       {
                           if (succeeded)
                           {
                               NSLog(@"msg saved");
                               
                               [self queryMessagesInExistingConversation];
                           }
                           else
                           {
                               NSLog(@"msg NOT saved");
                           }
                       }];


                      
                  }
                  else
                  {
                      NSLog(@"msg NOT created");
                  }
              }];


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
