//
//  CLLocation+XTYAddition.h
//  XTYMapView
//
//  Created by Michael on 16/8/21.
//  Copyright © 2016 Michael. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (XTYAddition)

/**
 *  determine whether lat value is correct
 *
 *  @param lat -90 =< lat <= 90
 *
 *  @return YES or NO
 */
+ (BOOL)isValidLatitude:(double)lat;

/**
 *  determine whether lng value is correct
 *
 *  @param lng -180 =< lng <= 180
 *
 *  @return YES or NO
 */
+ (BOOL)isValidLongitude:(double)lng;

/**
 *  determine whether ther location value is correct
 *
 *  @return YES or NO
 */
- (BOOL)isValidCLLocation;

/**
 *  get CLLocation instance through location information
 *
 *  @param d_lat latitude value
 *  @param d_lng longitude value
 *
 *  @return CLLocation instance
 */
+ (CLLocation *)validLocationFromLat:(CLLocationDegrees)d_lat lng:(CLLocationDegrees)d_lng;

/**
 *  get CLLocation instance through location information with string format
 *
 *  @param lat latitude value with string format
 *  @param lng longitude value with string format
 *
 *  @return CLLocation instance
 */
+ (CLLocation *)validLocationFromLatString:(NSString *)lat lngString:(NSString *)lng;

/**
 *  format loacation information <N:north,S:South,W:west,E:east>
 *
 *  @return location information such as: N35.1°,W80°
 */
- (NSString *)coordinateStringVeryShort;

@end