//
//  DetailViewController.h
//  XTYMapView
//
//  Created by Michael on 16/8/21.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

