//
//  QRScannerViewController.h
//  TEDxVITPune
//
//  Created by Yash Gorana on 14/01/16.
//  Copyright © 2016 Yash Gorana. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCodeReaderDelegate.h"

@interface QRScannerViewController : UIViewController  <QRCodeReaderDelegate>


@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scanType;
@property (weak, nonatomic) IBOutlet UILabel *greetLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (nonatomic, copy) NSString *lastScan;

- (IBAction)scanACode:(UIButton *)sender;
@end
