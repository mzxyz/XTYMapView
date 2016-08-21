//
//  CLLocation+XTYAddition.h
//  XTYMapView
//
//  Created by Michael on 16/8/21.
//  Copyright © 2016 Michael. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (XTYAddition)

+ (BOOL)isValidLatitude:(double)lat;
+ (BOOL)isValidLongitude:(double)lng;
- (BOOL)isValidCLLocation;

+ (CLLocation *)validLocationFromLat:(CLLocationDegrees)d_lat lng:(CLLocationDegrees)d_lng;
+ (CLLocation *)validLocationFromLatString:(NSString *)lat lngString:(NSString *)lng;

// 返回经纬度带NSWE方位，小数为1位的字符串形式
- (NSString *)coordinateStringVeryShort;
// 返回经纬度带NSWE方位，小数为3位的字符串形式
- (NSString *)coordinateString;
// 返回经纬度带NSWE方位，小数为6位的字符串形式
- (NSString *)fullCoordinateString;

@end