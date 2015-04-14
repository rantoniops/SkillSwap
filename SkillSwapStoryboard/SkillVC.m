//
//  SkillViewController.m
//  SkillSwapStoryboard
//
//  Created by Sha Zhu on 4/14/15.
//  Copyright (c) 2015 antonioperez. All rights reserved.
//

#import "SkillVC.h"

@interface SkillVC ()<UITableViewDataSource,UITableViewDelegate>

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

@implementation SkillVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)takeClass:(UIButton *)sender {
}

- (IBAction)nopeButtonTap:(UIButton *)sender {
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

@end
