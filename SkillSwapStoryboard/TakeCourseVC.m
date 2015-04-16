#import "TakeCourseVC.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface TakeCourseVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *courseImage;
@property (weak, nonatomic) IBOutlet UILabel *teacherName;
@property (weak, nonatomic) IBOutlet UILabel *courseRating;
@property (weak, nonatomic) IBOutlet UILabel *courseName;
@property (weak, nonatomic) IBOutlet UILabel *courseCredit;
@property (weak, nonatomic) IBOutlet UILabel *courseDesciption;
@property (weak, nonatomic) IBOutlet UILabel *courseDuration;
@property (weak, nonatomic) IBOutlet UILabel *courseAddress;
@property (weak, nonatomic) IBOutlet UITableView *courseTableView;
@end

@implementation TakeCourseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.courseName.text = self.selectedCourse.title;
    self.courseAddress.text = self.selectedCourse.address;
    self.courseDesciption.text = self.selectedCourse.courseDescription;
    self.courseDuration.text = self.selectedCourse.time;
    self.teacherName.text = self.selectedCourse.teacher.username;
    [self.selectedCourse.coursePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            self.courseImage.image = image;
            NSLog(@"pause here");
            // image can now be set on a UIImageView
            
            ////to do - add image to mkpointAnnotation
            ////experiment with video
        }
    }];
}



- (IBAction)takeClass:(UIButton *)sender {
}

- (IBAction)nopeButtonTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
    
}
- (IBAction)dismissButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];    
}




-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

@end
