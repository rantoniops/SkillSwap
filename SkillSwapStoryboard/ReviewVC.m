//
//  ReviewVC.m
//  SkillSwapStoryboard
//
//  Created by Sha Zhu on 4/22/15.
//  Copyright (c) 2015 antonioperez. All rights reserved.
//

#import "ReviewVC.h"

@interface ReviewVC ()

@property (weak, nonatomic) IBOutlet UITextView *textField;


@end

@implementation ReviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)underWhelmingButtonTap:(UIButton *)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)satisfactoryButtonTap:(UIButton *)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)bestInClassButtonTap:(UIButton *)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}




@end
