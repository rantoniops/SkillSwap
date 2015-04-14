//
//  ListViewController.m
//  SkillSwapStoryboard
//
//  Created by Sha Zhu on 4/14/15.
//  Copyright (c) 2015 antonioperez. All rights reserved.
//

#import "CourseListVC.h"

@interface CourseListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *courseListTableView;

@end

@implementation CourseListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
