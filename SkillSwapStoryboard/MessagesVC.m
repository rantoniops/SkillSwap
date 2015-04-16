#import "MessagesVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface MessagesVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *messages;
@end
@implementation MessagesVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}


-(void)viewWillAppear:(BOOL)animated
{
    [self queryMessages];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"messageConversation" sender:self.view];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"postClass"])
//    {
//        PostCourseVC *postVC = segue.destinationViewController;
//        CLLocation *locationToPass = [[CLLocation alloc]initWithLatitude:self.anotherAnnotation.coordinate.latitude longitude:self.anotherAnnotation.coordinate.longitude];
//        postVC.selectedAddress = self.formattedAdress;
//        postVC.courseLocation = locationToPass;
//    }
//
//}


-(void)queryMessages
{
    PFQuery *query = [Message query];
    [query whereKey:@"messageSender" equalTo:[User currentUser]];
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
