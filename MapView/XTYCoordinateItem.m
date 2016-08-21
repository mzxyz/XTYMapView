//
//  XTYCoordinateItem.m
//  XTYMapView
//
//  Created by Michael on 16/8/21.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "XTYCoordinateItem.h"

@implementation XTYCoordinateItem

@end

@implementation XTYCoordinateListItem

- (CLLocationCoordinate2D)coordinate2D
{
    return CLLocationCoordinate2DMake([self.lat doubleValue], [self.lng doubleValue]);
}

@end