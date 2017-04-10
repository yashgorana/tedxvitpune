//
//  QRScannerViewController.m
//  TEDxVITPune
//
//  Created by Yash Gorana on 14/01/16.
//  Copyright © 2016 Yash Gorana. All rights reserved.
//

#import "QRScannerViewController.h"
#import "QRCodeReaderViewController.h"
#import "QRCodeReader.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"

@interface QRScannerViewController ()

@property (nonatomic, assign) BOOL qrScanned;

@end

@implementation QRScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar.topItem
     setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavbar"]]];
    
    self.qrScanned = false;
    
    self.greetLabel.text = @"";
    self.detailLabel.text = @"";
    self.lastScan = @"";
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    if(self.qrScanned) {
        self.qrScanned = false;
    }
    else {
        self.greetLabel.text = @"";
        self.detailLabel.text = @"";
        self.lastScan = @"";
    }
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

#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    // convert base64 encoded NSString to base64 decoded NSData
    NSData *QRDecodedData = [[NSData alloc] initWithBase64EncodedString:result options:0];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!QRDecodedData) {
        NSLog(@"Fatal Error : Not Base64 data.");
        self.greetLabel.text = @"";
        self.detailLabel.text = result;// @"Invalid QR Code.";
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    // Convert base64 decoded NSData to NSJSONSerialization
    NSError *JSONParseError = nil;
    id jsonObject = [NSJSONSerialization
                     JSONObjectWithData:QRDecodedData
                     options:0
                     error:&JSONParseError];
    
    if(JSONParseError) {
        NSLog(@"Fatal Error : Not JSON data.");
        self.greetLabel.text = @"";
        self.detailLabel.text = @"Invalid TEDxVITPune QR Code.";
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    if(![jsonObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Fatal Error : Not NSDictionary data.");
        self.greetLabel.text = @"";
        self.detailLabel.text = @"Invalid data structure parsed from QR Code.";
        return;
    }
    
    NSDictionary *jsonResult = jsonObject;
    NSString *appID =[jsonResult objectForKey:@"id"];
    if([self.lastScan isEqualToString:appID]) {
        // already scanned
        return;
    }
    
    NSString *name = [jsonResult objectForKey:@"name"];
    NSString *surname = [jsonResult objectForKey:@"surname"];
    NSInteger scanType = self.scanType.selectedSegmentIndex;
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"Asia/India"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:tz];
    NSString* timestamp = [dateFormatter stringFromDate:now];
    NSInteger scanCount = [appDelegate
                           getScanCountForTEDxID:appID
                           forScanType:scanType];

    if (scanCount < 0) {
        [self.navigationController popViewControllerAnimated:YES];
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Error"
                                              message: @"An error occured while querying scan count"
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        self.detailLabel.text = @"Error";
    }
    else if (scanCount == 0) {
        // first scan for type
        self.greetLabel.text = [NSString stringWithFormat:@"%@ %@", name, surname];
        self.lastScan = appID;
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:jsonResult forKey:@"JSONData"];
        
        if([appDelegate enterDataWithAttendeeInfo:jsonResult timestamp:timestamp scanType:scanType] == 0) {
            AudioServicesPlayAlertSound(1103);
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ScanSuccessNotification"
             object:self
             userInfo:dictionary];
            
            self.detailLabel.text = [NSString stringWithFormat:@"TEDx Application ID : %@", appID];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Error"
                                                  message: @"Could not add to scan entry to DB"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            self.detailLabel.text = @"Error";
        }
        appID = nil;
    }
    else if (scanCount > 0) {
        // too many scans for type
        [self.navigationController popViewControllerAnimated:YES];
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Error"
                                              message:[NSString
                                                       stringWithFormat:@"QR code of %@ %@ has been already scanned for '%@'",
                                                       name, surname, [self.scanType titleForSegmentAtIndex:self.scanType.selectedSegmentIndex]]
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        self.detailLabel.text = @"Scanned more than one time";
    }
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    NSLog(@"Cancelled");
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)changeScanButtonText:(UISegmentedControl *)sender {
    NSString *title = @"Scan QR for ";
    title = [title stringByAppendingString:[sender titleForSegmentAtIndex:sender.selectedSegmentIndex]];
    
    [self.scanButton setTitle:title forState:UIControlStateNormal];
    self.lastScan = NULL;
    
    self.greetLabel.text = @"";
    self.detailLabel.text = @"";
    self.lastScan = @"";
}

#pragma mark - IBActions

- (IBAction)scanACode:(UIButton *)sender {
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        static QRCodeReaderViewController *qrCodeReaderViewController = nil;
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            qrCodeReaderViewController = [QRCodeReaderViewController
                                          readerWithCancelButtonTitle:nil
                                          codeReader:reader
                                          startScanningAtLoad:YES
                                          showSwitchCameraButton:NO
                                          showTorchButton:NO];
        });
        qrCodeReaderViewController.delegate = self;
        qrCodeReaderViewController.navigationItem.title = @"Scan QR Code";
        
        [qrCodeReaderViewController setCompletionWithBlock:^(NSString *resultAsString) {
            self.qrScanned = true;
        }];
        
        [self.navigationController pushViewController:qrCodeReaderViewController animated:YES];
    }
    else {
        self.greetLabel.text = @"";
        self.detailLabel.text = @"Can't scan QR Code on this device.";
        sender.enabled = false;
    }
}
@end
