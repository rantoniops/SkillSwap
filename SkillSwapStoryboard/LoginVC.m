//
//  LoginViewController.m
//  SkillSwapStoryboard
//
//  Created by Sha Zhu on 4/14/15.
//  Copyright (c) 2015 antonioperez. All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)loginButtonPress:(UIButton *)sender {
}

- (IBAction)signUpButtonPress:(UIButton *)sender {
}

@end
