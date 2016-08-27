//
//  DemoAnnotationView.h
//  XTYMapViewDemo
//
//  Created by Michael on 16/8/27.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "DemoAnnotationItem.h"

@interface DemoAnnotation : NSObject<MKAnnotation>

@property (nonatomic, strong) DemoAnnotationItem *info;

@end

@interface DemoAnnotationView : MKAnnotationView
@end