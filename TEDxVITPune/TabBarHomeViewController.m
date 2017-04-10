//
//  TabBarHomeViewController.m
//  TEDxVITPune
//
//  Created by Yash Gorana on 14/01/16.
//  Copyright © 2016 Yash Gorana. All rights reserved.
//

#import "TabBarHomeViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface TabBarHomeViewController ()

@end

@implementation TabBarHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar.topItem setTitleView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"LogoNavbar"]]];
    
    [[self tabBar] setTintColor:UIColorFromRGB(0xe62b1e)];
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

@end
