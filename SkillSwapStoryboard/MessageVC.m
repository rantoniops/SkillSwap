//
//  MessageVC.m
//  SkillSwapStoryboard
//
//  Created by Sha Zhu on 4/14/15.
//  Copyright (c) 2015 antonioperez. All rights reserved.
//

#import "MessageVC.h"

@interface MessageVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButtonPress;

@end

@implementation MessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
