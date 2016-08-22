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


/************************************************/
@interface CurrentAnnotation : NSObject<MKAnnotation>

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end

/************************************************/
@interface XTYMapView : UIView

@property (nonatomic, readonly) MKMapView *mapView;
@property (nonatomic, readonly) CurrentAnnotation *currentAnnotation;

/**
 *  set annotation item list manually
 *
 *  @param arr XTYMapAnnotationItem item list
 */
- (void)setUpAnnotationItemList:(NSArray<XTYMapAnnotationItem *> *)arr;

/**
 *  delete annotation item list
 *
 *  @param arr XTYMapAnnotationItem item list
 */
- (void)deleteAnnotationItems:(NSArray<XTYMapAnnotationItem *> *)arr;

/**
 *  creat new annotation item list and add to MapView
 *
 *  @param arr XTYMapAnnotationItem item list
 */
- (void)addAnnotationItems:(NSArray<XTYMapAnnotationItem *> *)arr;

/**
 *  delete and add the new item list to annotation
 *
 *  @param arr the new annotation item list
 */
- (void)reloadAnnotationItems:(NSArray<XTYMapAnnotationItem *> *)arr;

/**
 *  delete all annotation item
 */
- (void)deleteAllAnnotationItems;

/**
 *  get annotation information with index
 *
 *  @param index the index in annotation item list
 *
 *  @return annotation information item
 */
- (id<MKAnnotation>)getAnnotationWithAnnIndex:(XTYMapAnnIndex)index;

/**
 *  get overlay information with index
 *
 *  @param index the index in annotation item list
 *
 *  @return overlay information item
 */
- (id<MKOverlay>)getOverlayWithAnnIndex:(XTYMapOverIndex)index;

/**
 *  set the annotation view with index selected status
 *
 *  @param index the index of annotation view
 */
- (void)selectAnnWithIndex:(XTYMapAnnIndex)index;

/**
 *  set the current annotation View selected status
 *
 *  @param animated with animation or not
 */
- (void)selectCurrentAnnAnimated:(BOOL)animated;

/**
 *  cancle the selected status of current annotation view
 *
 *  @param animated with animation or not
 */
- (void)deselectCurrentAnnAnimated:(BOOL)animated;

/**
 *  show all annotation view
 *
 *  @param animated with animation or not
 */
- (void)showAllAnnotationAnimated:(BOOL)animated;

/**
 *  set current annotation information
 *
 *  @param coordinate CLLocationCoordinate2D lat and lng
 */
- (void)setCurrentAnn:(CLLocationCoordinate2D)coordinate;

/**
 *  change the map center to specified coordinate
 *
 *  @param coordinate center coordinate
 */
- (void)changeMapViewCenterWith:(CLLocationCoordinate2D)coordinate;

/**
 *  change the map center to specified coordinate
 *
 *  @param coordinate center coordinate
 *  @param animated   set the tranform with animation or not
 */
- (void)changeMapViewCenterWith:(CLLocationCoordinate2D)coordinate andAnimated:(BOOL)animated;

/**
 *  change the map center to specified coordinate and scale to specified span
 *
 *  @param coordinate center coordinate
 *  @param delta      span parameter
 *  @param compel     set span automatic or use the specified span
 *  @param animated   set the tranform with animation or not
 */
- (void)changeMapViewCenterWith:(CLLocationCoordinate2D)coordinate andSpan:(CLLocationDegrees)delta andCompel:(BOOL)compel andAnimated:(BOOL)animated;

@end