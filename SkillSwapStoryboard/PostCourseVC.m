#import "PostCourseVC.h"
#import "SkillSwapStoryboard-Swift.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>

@import MediaPlayer;

@interface PostCourseVC () <UITextFieldDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *classTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *classDescriptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *classAddressTextField;
@property (weak, nonatomic) IBOutlet UIImageView *classPhotoImageView;
@property (weak, nonatomic) IBOutlet UITextField *classSkillTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property UIImage *chosenImage;
@property NSData *smallImageData;


@end
@implementation PostCourseVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.classTitleTextField.delegate = self;
    self.classAddressTextField.delegate = self;
    self.classSkillTextField.delegate = self;
    self.classDescriptionTextField.delegate = self;
    
    
    self.classAddressTextField.text = self.selectedAddress;
    UIImage *profileImage = [UIImage imageNamed:@"emptyProfile"];
    self.classPhotoImageView.image = profileImage;
    self.classPhotoImageView.frame = CGRectMake(0, 0, 250, 250);
    self.classPhotoImageView.layer.masksToBounds = YES;
    self.classPhotoImageView.layer.borderWidth = 1;
    UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.classPhotoImageView addGestureRecognizer:photoTap];

    
}

///to do figure out how to play an image somewhere and if we will need to save the thumbnail or can just creat a new one each time


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

-(void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSLog(@"successful Tap");
    [self showAlertOnViewController];
}

-(void)showAlertOnViewController
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose photo option" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"Take a Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showTakePhotoView];
    }];
    UIAlertAction *pullLibrary = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showCameraPhotoView];
    }];
    UIAlertAction *takeMovie = [UIAlertAction actionWithTitle:@"Take a movie" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showMovieView];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        nil;
    }];
    
    [alert addAction:takeMovie];
    [alert addAction:takePhoto];
    [alert addAction:pullLibrary];
   
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

-(void)showMovieView
{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    picker.videoMaximumDuration = 10;
    [self presentViewController:picker animated:true completion:NULL];
}

-(void)showTakePhotoView
{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:true completion:NULL];
    
}

-(void)showCameraPhotoView
{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:picker animated:true completion:NULL];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if (![mediaType isEqualToString:@"public.image"])
    {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        self.smallImageData = [NSData dataWithContentsOfURL:videoURL];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef oneRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
        self.classPhotoImageView.image = one;
        [picker dismissViewControllerAnimated:YES completion:NULL];
        
    }
    else
    {
        self.chosenImage = info[UIImagePickerControllerOriginalImage];
        self.classPhotoImageView.image = self.chosenImage;
        self.smallImageData = UIImageJPEGRepresentation(self.chosenImage, 0.5);
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
    
}



- (IBAction)onPostButtonPressed:(UIButton *)sender
{
    sender.enabled = NO;
    if (self.classAddressTextField.text == nil || self.classDescriptionTextField.text == nil || self.classTitleTextField.text == nil || [self.classPhotoImageView.image isEqual:[UIImage imageNamed:@"emptyProfile"]])
    {
        [self fillOutAllfields];
        NSLog(@"can't proceed");
    }
    else
    {
    // CREATING SKILL
    Skill *skill = [Skill new];
    skill.name = self.classSkillTextField.text;
//    skill.owner = [User currentUser]; // WE NEED TO SAVE SKILL ON THE CURRENT USER AS A RELATION
    [skill saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             self.items = [NSMutableArray arrayWithObjects:@"one", @"two", nil];

             NSLog(@"skill saved");

             // CREATING COURSE
             Course *course = [Course new];
             course.title = self.classTitleTextField.text;
             course.courseDescription = self.classDescriptionTextField.text;
             course.address = self.classAddressTextField.text;
             PFFile *imageFile = [PFFile fileWithData:self.smallImageData];
             course.courseMedia = imageFile;
             course.time = self.datePicker.date;
             course.teacher = [User currentUser];
             course.location = [PFGeoPoint geoPointWithLocation:self.courseLocation];
             PFRelation *relation = [course relationForKey:@"skillsTaught"];
             [relation addObject: skill];
             [course saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (succeeded)
                  {
                      NSLog(@"course saved");
                      User *currentUser = [User currentUser];
                      PFRelation *teacherRelation = [currentUser relationForKey:@"courses"];
                      [teacherRelation addObject: course];
                      [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                       {
                           if (succeeded)
                           {
                               NSLog(@"teacher relation saved");
                               [self.navigationController popViewControllerAnimated:YES];
                               [self.delegate didIcreateACourse:true];

                           }
                           else
                           {
                               NSLog(@"teacher relation NOT saved");
                           }
                       }];

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
}
}

-(void)fillOutAllfields
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please complete all fields" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}



- (IBAction)onXButtonPressed:(UIButton *)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];

    [self.delegate didIcreateACourse:false];
   
}







@end
