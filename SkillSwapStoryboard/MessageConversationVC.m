#import "MessageConversationVC.h"
#import "MessageCell.h"
@interface MessageConversationVC () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property NSArray *messages;
@property Conversation *conversation;
@property int conversationGotUsed;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
@implementation MessageConversationVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    // this resizes your cell to the content size and makes the text start from the top to down, not the center growing up and down
    self.activityIndicator.hidesWhenStopped = YES;
    self.view.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:1.9];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"messageReceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    self.sendButton.enabled = NO;

    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.sendButton.enabled = YES;
}



- (void)keyboardWillShow:(NSNotification*)notification
{
    [self moveControls:notification up:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    [self moveControls:notification up:NO];
}

- (void)moveControls:(NSNotification*)notification up:(BOOL)up
{
    NSDictionary* userInfo = [notification userInfo];
    CGRect newFrame = [self getNewControlsFrame:userInfo up:up];
    [self animateControls:userInfo withFrame:newFrame];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (CGRect)getNewControlsFrame:(NSDictionary*)userInfo up:(BOOL)up
{
    CGRect kbFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbFrame = [self.view convertRect:kbFrame fromView:nil];
    CGRect newFrame = self.view.frame;
    newFrame.origin.y += kbFrame.size.height * (up ? -1 : 1);
    return newFrame;
}

- (void)animateControls:(NSDictionary*)userInfo withFrame:(CGRect)newFrame
{
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                         self.view.frame = newFrame;
                     }
                     completion:^(BOOL finished){}];
}


// do i need to do this one?
-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [super dealloc];
}


- (void)handleNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"messageReceived"])
    {
        NSLog (@"Notification is successfully received!");
        [self queryMessagesInExistingConversation];
    }
}



-(void)viewWillAppear:(BOOL)animated
{
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    [self.tableView reloadData];
    [self.tableView layoutSubviews];
    [self.tableView reloadData];

    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = self.otherUser.username;
//    [self configureTableView];

    if ([self.origin isEqualToString:@"messages"])
    {
        NSLog(@"coming from messages, selected conversation found");
        self.conversation = self.selectedConversation;
        [self queryMessagesInExistingConversation];
    }
    else if ([self.origin isEqualToString:@"takeCourse"]) // SOMEONE IS MESSAGING A TEACHER
    {
        // CHECKING IF THERE'S ALREADY AN EXISTING CONVO BETWEEN THIS TEACHER, THIS USER ABOUT THIS COURSE
        PFQuery *query = [Conversation query];
        [query whereKey:@"course" equalTo:self.selectedCourse];
        [query whereKey:@"users" containsAllObjectsInArray: @[ [User currentUser] , self.otherUser ]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 if (objects.count > 0) // convo exists, we continue using the one that already exists
                 {
                     NSLog(@"there's an existing convo, we'll use that one");
                     self.conversation = objects.firstObject;
                     [self queryMessagesInExistingConversation];
                 }
                 else // convo doesn't exist, we create a new one and we'll trash it in viewwilldissappear if no messaging occurs
                 {
                     NSLog(@"no existing convos, we create a new one");
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
             else
             {
                 NSLog(@"Error searching for existing conversation: %@ %@", error, [error userInfo]);
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
             [self.tableView layoutSubviews];
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
    if ([self.messageTextField.text isEqualToString:@""])
    {
        
    }
    else
    {
        [self.activityIndicator startAnimating];

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
                 self.messageTextField.text = @"";

                 [self.tableView reloadData];
                 [self.tableView layoutSubviews];
                 [self.tableView reloadData];

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

                          [self.activityIndicator stopAnimating];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:@"newcellID"];
//    if (cell == nil)
//    {
//        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:nil];
//        cell = [nib objectAtIndex:0];
//    }
//    
//    Message *messageToShow = self.messages[indexPath.row];
//    
////    if (messageToShow.messageSender == [User currentUser])
////    {
////        cell.cellViewTwo.layer.borderColor = [UIColor blueColor].CGColor;
////        cell.cellViewTwo.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.4f];
////        
////        cell.titleLabel.textColor = [UIColor whiteColor];
////        CGSize customSize = [cell.titleLabel intrinsicContentSize];
////        NSLog(@"width: %f, height %f", customSize.width, customSize.height);
////        cell.cellViewTwo.frame = CGRectOffset(cell.cellViewTwo.frame, 120, 10);
////        cell.myMessageConstraint.constant = 150;
////    }
////    else
////    {
////        cell.cellViewTwo.layer.borderColor = [UIColor yellowColor].CGColor;
////        cell.cellViewTwo.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.2f];
////        cell.cellViewTwo.frame = CGRectOffset(cell.cellViewTwo.frame, 5, 10);
////        cell.yourMessageConstraint.constant = 150;
////    }
//    cell.titleLabel.text = messageToShow.messageBody;
//    cell.userInteractionEnabled = NO;
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//    return cell;
//}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    Message *messageToShow = self.messages[indexPath.row];
    cell.textLabel.text = messageToShow.messageBody;
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", messageToShow.messageSender.username];
    return cell;
}


//-(void)configureTableView
//{
//    self.tableView.backgroundColor = [UIColor whiteColor];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    self.tableView.estimatedRowHeight = 44.0;
//}

//    NSString *timeString = [NSDateFormatter localizedStringFromDate:messageToShow.createdAt dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"-%@ sent at %@", messageToShow.messageSender.username,timeString];
//








@end
