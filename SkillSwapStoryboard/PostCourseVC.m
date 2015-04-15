#import "PostCourseVC.h"
#import "SkillSwapStoryboard-Swift.h"
@interface PostCourseVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *classTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *classDescriptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *classTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *classAddressTextField;
@property (weak, nonatomic) IBOutlet UIImageView *classPhotoImageView;
@property (weak, nonatomic) IBOutlet UITextField *classSkillTextField;
@end
@implementation PostCourseVC



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.classAddressTextField.text = self.selectedAddress;
}


- (IBAction)onPostButtonPressed:(UIButton *)sender
{
    Skill *skill = [Skill new];
    skill.name = self.classSkillTextField.text;
    skill.owner = [User currentUser];
    [skill saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             NSLog(@"skill saved");

             Course *course = [Course new];
             course.title = self.classTitleTextField.text;
             course.courseDescription = self.classDescriptionTextField.text;
             course.time = self.classTimeTextField.text;
             course.address = self.classAddressTextField.text;
             //    course.coursePhoto = something
             course.teacher = [User currentUser];
             course.skillTaught = skill;
//             course.latitude = self.selectedLatitude;
//             course.longitude = self.selectedLongitude;
             [course saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (succeeded)
                  {
                      NSLog(@"course saved");
                  }
                  else
                  {
                      NSLog(@"course NOT saved");
                      
                  }
              }];
         }
         else
         {
             NSLog(@"skill NOT saved");
         }
     }];
    [self dismissViewControllerAnimated:true completion:nil];




}




- (IBAction)onXButtonPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}







@end
