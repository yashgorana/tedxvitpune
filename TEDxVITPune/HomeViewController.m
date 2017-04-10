//
//  HomeViewController.m
//  TEDxVITPune
//
//  Created by Yash Gorana on 13/01/16.
//  Copyright © 2016 Yash Gorana. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "HomeViewController.h"
#import "AppDelegate.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    [self.navigationController.navigationBar.topItem setTitleView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"LogoNavbar"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logScannedData:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate logData];

}

- (IBAction)resetCoreData:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Confirm"
                                          message:@"Type 'tedxvitpune' to confirm. Application will exit once data is reset."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.secureTextEntry = YES;
     }];
    
    UIAlertAction *reset = [UIAlertAction
                               actionWithTitle:@"Bye data :("
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *login = alertController.textFields.firstObject;
                                   if([login.text isEqualToString:@"tedxvitpune"]) {
                                       AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                       [appDelegate resetCoreData];
                                       NSLog(@"coredata was reset");
                                   } else {
                                       AudioServicesPlayAlertSound(1103);
                                       NSLog(@"invalid password");
                                   }
                               }];
    
    [alertController addAction:reset];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (IBAction)resetQRScanCount:(id)sender {
}

- (IBAction)addQRScanCount:(id)sender {
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
