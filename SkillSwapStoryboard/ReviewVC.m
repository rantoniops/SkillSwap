//
//  ReviewVC.m
//  SkillSwapStoryboard
//
//  Created by Sha Zhu on 4/22/15.
//  Copyright (c) 2015 antonioperez. All rights reserved.
//

#import "ReviewVC.h"

@interface ReviewVC () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textField;
@property NSString *placeHolderString;

@end

@implementation ReviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textField.delegate = self;
    NSLog(@"here is the course I'm reviewing: %@", self.reviewCourse);
    self.textField.editable = YES;
    self.placeHolderString = @"We had an experience that was very...";
    self.textField.text = self.placeHolderString;
    self.textField.textColor = [UIColor lightGrayColor];
    
    // Do any additional setup after loading the view.
}



-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.textField.text = @"";
    self.textField.textColor = [UIColor blackColor];
}


- (IBAction)underWhelmingButtonTap:(UIButton *)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
    [self saveTheReview];
}

- (IBAction)satisfactoryButtonTap:(UIButton *)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
    [self saveTheReview];
}

- (IBAction)bestInClassButtonTap:(UIButton *)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
    [self saveTheReview];
}

-(void)saveTheReview
{
    Review *review = [Review new];
    review.reviewContent = self.textField.text;
    review.reviewed = self.reviewCourse.teacher;
    User *currentUser = [User currentUser];
    review.reviewer = currentUser;
//    currentUser.completedReview = true;

    [currentUser setValue:@1 forKey:@"completedReview"];
    [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             
             NSLog(@"review saved");
             [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  NSLog(@"%@", currentUser);
              }];
         }
     }];
}
     


@end
