#import "MessageConversationVC.h"
@interface MessageConversationVC () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *messages;
@property Conversation *conversation;
@end
@implementation MessageConversationVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([self.origin isEqualToString:@"messages"])
    {
        NSLog(@"coming from messages, selected conversation found");
        self.conversation = self.selectedConversation;
        [self queryMessagesInExistingConversation];
    }
    else if ([self.origin isEqualToString:@"takeCourse"])
    {
        NSLog(@"coming from takeCourse, selected conversation NOT found");
    }






//    if (self.selectedConversation)
//    {
//        NSLog(@"selected conversation found");
//        self.conversation = self.selectedConversation;
//        [self queryMessagesInExistingConversation];
//    }
//    else
//    {
//        NSLog(@"selected conversation NOT found");
//    }


    
}

- (IBAction)onGoBackPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
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
    [textField resignFirstResponder];
    return true;
}

- (IBAction)onSendButtonPressed:(UIButton *)sender
{
    PFQuery *query = [Conversation query];
    [query whereKey:@"users" containsAllObjectsInArray:@[ [User currentUser], self.otherUser] ];
    [query whereKey:@"course" equalTo:self.selectedCourse];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error)
         {
             NSLog(@"error");
         }
         else
         {
             if (objects.count > 0)
             {
                 NSLog(@"Successfully retrieved %lu convos.", (unsigned long)objects.count);
                 self.conversation = objects.firstObject;
                 Message *newMessage = [Message new];
                 newMessage.messageBody = self.messageTextField.text;
                 newMessage.messageSender = [User currentUser];
                 newMessage.messageReceiver = self.otherUser;
                 newMessage.course = self.selectedCourse;
                 newMessage.conversation = self.conversation;
                 [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (succeeded)
                      {
                          NSLog(@"msg fron existing convo saved");



                          ///////////////////////////////// PUSH NOTICATION STUFF ////////////////////////////////


                          PFInstallation *installation = [PFInstallation currentInstallation];
                          //             [installation setObject:@YES forKey:@"scores"];
                          installation[@"senderUser"] = [User currentUser];
                          installation[@"receiverUser"] = self.otherUser;
                          [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                           {
                               if (succeeded)
                               {
                                   NSLog(@"installation saved");


                                   /////////////////////////////// NOW DO THIS ////////////////////////////////

                                   PFQuery *pushQuery = [PFInstallation query];
                                   [pushQuery whereKey:@"receiverUser" equalTo: self.otherUser];
                                   PFPush *push = [[PFPush alloc] init];
                                   [push setQuery:pushQuery];
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

                                   ////////////////////////////////////////////////////////////////////////////

                               }
                               else
                               {
                                   NSLog(@"installation error");
                               }
                           }];

                          ///////////////////////////////// PUSH NOTICATION STUFF ////////////////////////////////




                          [self queryMessagesInExistingConversation];
                      }
                      else
                      {
                          NSLog(@"msg from existing convo NOT saved");
                      }
                  }];
             }
             else
             {
                 NSLog(@"making new convo");
                 Conversation *newConversation = [Conversation new];
                 [newConversation addObject:[User currentUser] forKey:@"users"];
                 [newConversation addObject:self.otherUser forKey:@"users"];
                 newConversation.course = self.selectedCourse;
                 [newConversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (succeeded)
                      {
                          NSLog(@"conversation created");
                          Message *newMessage = [Message new];
                          newMessage.messageBody = self.messageTextField.text;
                          newMessage.messageSender = [User currentUser];
                          newMessage.messageReceiver = self.otherUser;
                          newMessage.course = self.selectedCourse;


                          self.conversation = newConversation;
                          newMessage.conversation = newConversation;
                          [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                           {
                               if (succeeded)
                               {
                                   NSLog(@"msg fron new convo saved");




                                   ///////////////////////////////// PUSH NOTICATION STUFF ////////////////////////////////


                                   PFInstallation *installation = [PFInstallation currentInstallation];
                                   //             [installation setObject:@YES forKey:@"scores"];
                                   installation[@"senderUser"] = [User currentUser];
                                   installation[@"receiverUser"] = self.otherUser;
                                   [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                    {
                                        if (succeeded)
                                        {
                                            NSLog(@"installation saved");


                                            /////////////////////////////// NOW DO THIS ////////////////////////////////

                                            PFQuery *pushQuery = [PFInstallation query];
                                            [pushQuery whereKey:@"receiverUser" equalTo: self.otherUser];
                                            PFPush *push = [[PFPush alloc] init];
                                            [push setQuery:pushQuery];
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
                                            
                                            ////////////////////////////////////////////////////////////////////////////
                                            
                                        }
                                        else
                                        {
                                            NSLog(@"installation error");
                                        }
                                    }];
                                   
                                   ///////////////////////////////// PUSH NOTICATION STUFF ////////////////////////////////




                                   [self queryMessagesInExistingConversation];
                               }
                               else
                               {
                                   NSLog(@"msg from new convo NOT saved");
                               }
                           }];
                      }
                      else
                      {
                          NSLog(@"error, conversation NOT created");
                      }
                  }];
             }
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
