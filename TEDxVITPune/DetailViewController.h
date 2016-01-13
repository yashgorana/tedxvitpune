//
//  DetailViewController.h
//  TEDxVITPune
//
//  Created by Yash Gorana on 13/01/16.
//  Copyright © 2016 Yash Gorana. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

