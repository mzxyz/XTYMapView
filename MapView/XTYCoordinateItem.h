//
//  XTYCoordinateItem.h
//  XTYMapView
//
//  Created by Michael on 16/8/21.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/*************** coordinate item *****************/
@interface XTYCoordinateItem : NSObject

@property (nonatomic, assign) CLLocationDegrees lat;
@property (nonatomic, assign) CLLocationDegrees lng;

@end


/*************** list item *****************/
@interface XTYCoordinateListItem : NSObject

@property (nonatomic, strong) NSArray<XTYCoordinateItem *> * itemList;

@end