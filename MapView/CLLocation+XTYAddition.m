//
//  CLLocation+XTYAddition.m
//  XTYMapView
//
//  Created by Michael on 16/8/21.
//  Copyright © 2016 Michael. All rights reserved.
//

#import "CLLocation+XTYAddition.h"

@implementation CLLocation (XTYAddition)

+ (BOOL)isValidLongitude:(double)lng
{
    if(isnan(lng)) return NO;
    if(lng < -180 || lng > 180) return NO;
    return YES;
}

+ (BOOL)isValidLatitude:(double)lat
{
    if(isnan(lat)) return NO;
    if(lat < -90 || lat > 90) return NO;
    return YES;
}

- (BOOL)isValidCLLocation
{
    return [[self class] isValidLatitude:self.coordinate.latitude] && [[self class] isValidLongitude:self.coordinate.longitude];
}

+ (CLLocation *)validLocationFromLat:(CLLocationDegrees)d_lat lng:(CLLocationDegrees)d_lng
{
    if (d_lat != 0 && [self isValidLatitude:d_lat] && d_lng != 0 &&[self isValidLongitude:d_lng])
    {
        CLLocation *l = [[CLLocation alloc] initWithLatitude:d_lat longitude:d_lng];
        return l;
    }
    
    return nil;
}

+ (CLLocation *)validLocationFromLatString:(NSString *)lat lngString:(NSString *)lng
{
    if (lat.length == 0 || lng.length == 0) return nil;
    
    double d_lat = [lat floatValue];
    double d_lng = [lng floatValue];
    
    if ([self isValidLatitude:d_lat] && [self isValidLongitude:d_lng])
    {
        CLLocation *l = [[CLLocation alloc] initWithLatitude:d_lat longitude:d_lng];
        return l;
    }
    
    return nil;
}

- (NSString *)coordinateStringVeryShort
{
    CLLocationCoordinate2D coorl = self.coordinate;
    NSString *coordinateString = [NSString stringWithFormat:@"%@%.1f°, %@%.1f°",
                                  (coorl.latitude < 0 ? @"S" : @"N"), fabs(coorl.latitude),
                                  (coorl.longitude < 0 ? @"W" : @"E"), fabs(coorl.longitude)];
    return coordinateString;
}

- (NSString *)coordinateString
{
    CLLocationCoordinate2D coorl = self.coordinate;
    NSString *coordinateString = [NSString stringWithFormat:@"%@%.3f°, %@%.3f°",
                                  (coorl.latitude < 0 ? @"S" : @"N"), fabs(coorl.latitude),
                                  (coorl.longitude < 0 ? @"W" : @"E"), fabs(coorl.longitude)];
    return coordinateString;
}

- (NSString *)fullCoordinateString
{
    CLLocationCoordinate2D coorl = self.coordinate;
    NSString *coordinateString = [NSString stringWithFormat:@"%@%.6f°, %@%.6f°",
                                  (coorl.latitude < 0 ? @"S" : @"N"), fabs(coorl.latitude),
                                  (coorl.longitude < 0 ? @"W" : @"E"), fabs(coorl.longitude)];
    return coordinateString;
}

@end