//
//  XTYMapView.h
//  XTYMapView
//
//  Created by Michael on 16/8/21.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/Mapkit.h>
#import "XTYMapAnnotationItem.h"

typedef NSInteger XTYMapAnnIndex;
typedef NSInteger XTYMapOverIndex;

@interface CurrentAnnotation : NSObject<MKAnnotation>

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end

@interface XTYMapView : UIView

@property (nonatomic, readonly) MKMapView *mapView;

@property (nonatomic, readonly) CurrentAnnotation *currentAnnotation;

- (void)setUpAnnotationItemList:(NSArray<XTYMapAnnotationItem *> *)arr;
- (void)deleteAnnotationItems:(NSArray<XTYMapAnnotationItem *> *)arr;
- (void)addAnnotationItems:(NSArray<XTYMapAnnotationItem *> *)arr;
- (void)reloadAnnotationItems:(NSArray<XTYMapAnnotationItem *> *)arr;

- (void)deleteAllAnnotationItems;

- (id<MKAnnotation>)getAnnotationWithAnnIndex:(XTYMapAnnIndex)index;
- (id<MKOverlay>)getOverlayWithAnnIndex:(XTYMapOverIndex)index;


- (void)selectAnnWithIndex:(XTYMapAnnIndex)index;
- (void)selectCurrentAnnAnimated:(BOOL)animated;
- (void)deselectCurrentAnnAnimated:(BOOL)animated;

- (void)showAllAnnotationAnimated:(BOOL)animated;
- (void)showCenterWithCoordinates:(CLLocationCoordinate2D *)coordinates andCount:(NSInteger)count animated:(BOOL)animated;
- (void)showAllAnnotationWithEdage:(UIEdgeInsets)inset animated:(BOOL)animated;

- (void)setCurrentAnn:(CLLocationCoordinate2D)coordinate;

- (void)setCurrentAnnItem:(XTYMapAnnotationItem *)item;

/** change the map center*/
- (void)changeMapViewCenterWith:(CLLocationCoordinate2D)coordinate;
- (void)changeMapViewCenterWith:(CLLocationCoordinate2D)coordinate andSpan:(CLLocationDegrees)delta andCompel:(BOOL)compel andAnimated:(BOOL)animated;
- (void)changeMapViewCenterWith:(CLLocationCoordinate2D)coordinate andAnimated:(BOOL)animated;

@end