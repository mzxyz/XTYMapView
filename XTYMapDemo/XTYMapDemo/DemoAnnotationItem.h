//
//  DemoAnnotationItem.h
//  XTYMapViewDemo
//
//  Created by Michael on 16/8/27.
//  Copyright © 2016年 Michael. All rights reserved.
//


#import "XTYModelItem.h"
#import <CoreLocation/CoreLocation.h>

@interface DemoAnnotationItem : XTYModelItem

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, assign) CLLocationDegrees lat;
@property (nonatomic, assign) CLLocationDegrees lng;

@end