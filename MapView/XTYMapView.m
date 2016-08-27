//
//  XTYMapView.m
//  XTYMapView
//
//  Created by Michael on 16/8/21.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "XTYMapView.h"
#import "XTYCoordinateItem.h"
#import "CLLocation+XTYAddition.h"


/****************current annotation*************/
#pragma mark - currentAnnotation
@interface CurrentAnnotation ()

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@implementation CurrentAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self)
    {
        _coordinate = coordinate;
    }
    
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return _coordinate;
}

@end


/*******************Load Item********************/
@interface XTYMapViewAnnLoadItem : NSObject

@property (nonatomic, assign) BOOL isCalled;
@property (nonatomic, copy) void(^loadCallback)();

@end

@implementation XTYMapViewAnnLoadItem
@end


/*******************Map View********************/
@interface XTYMapView ()<MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *annotationArrs;
@property (nonatomic, strong) NSMutableArray *overlayArrs;
@property (nonatomic, strong) NSMutableArray *annotationItemsArr;
@property (nonatomic, strong) NSMutableArray *overlayItemsArr;

@property (nonatomic, strong) NSMutableArray *needCallLoadCallbacks;
@property (nonatomic, strong) NSMutableArray *needCallWillAddInMapViewCallbacks;

@property (nonatomic, assign) BOOL isLoop;
@property (nonatomic, assign) BOOL mapIsLoad;

@property (nonatomic, strong) CurrentAnnotation *currentAnnotation;
@property (nonatomic, strong) XTYMapAnnotationItem *currentAnnItem;

@end

@implementation XTYMapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _mapView = [[MKMapView alloc] initWithFrame:self.bounds];
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
        [self addSubview:_mapView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.mapView.frame = self.bounds;
}

#pragma mark - Getter Method Lazy Load
- (NSMutableArray *)annotationArrs
{
    if (!_annotationArrs)
    {
        _annotationArrs = [NSMutableArray array];
    }
    
    return _annotationArrs;
}

- (NSMutableArray *)overlayArrs
{
    if (!_overlayArrs)
    {
        _overlayArrs = [NSMutableArray array];
    }
    
    return _overlayArrs;
}

- (NSMutableArray *)annotationItemsArr
{
    if (!_annotationItemsArr)
    {
        _annotationItemsArr = [NSMutableArray array];
    }
    
    return _annotationItemsArr;
}

- (NSMutableArray *)overlayItemsArr
{
    if (!_overlayItemsArr)
    {
        _overlayItemsArr = [NSMutableArray array];
    }
    
    return _overlayItemsArr;
}

- (NSMutableArray *)needCallLoadCallbacks
{
    if (!_needCallLoadCallbacks)
    {
        _needCallLoadCallbacks = [NSMutableArray array];
    }
    
    return _needCallLoadCallbacks;
}

- (NSMutableArray *)needCallWillAddInMapViewCallbacks
{
    if (!_needCallWillAddInMapViewCallbacks)
    {
        _needCallWillAddInMapViewCallbacks = [NSMutableArray array];
    }
    
    return _needCallWillAddInMapViewCallbacks;
}

- (id)createAnnOrOverlayWithItem:(XTYMapAnnotationItem *)item
{
    Class annClass = item.annotationClass;
    id ann;
    
    /** if you want to use overLay to draw points on the map, 
      * you must set the annotationInfo as a XTYCoordinateListItem or its subClass instance
      */
    if (item.isOverlay)
    {
        XTYCoordinateListItem *listItem = item.annotationInfo;
        NSArray<XTYCoordinateItem *> *coordinates = listItem.itemList;
        
        NSUInteger bufCount = [coordinates count];
        NSUInteger coorCounts = 0;
        
        CLLocationCoordinate2D cllocations[bufCount];
        
        for (int i = 0; i < [coordinates count]; i++)
        {
            XTYCoordinateItem *coorinateItem = [coordinates objectAtIndex:i];
            CLLocation *l = [CLLocation validLocationFromLat:coorinateItem.lat lng:coorinateItem.lng];
            
            if (l)
            {
                cllocations[i] = l.coordinate;
                coorCounts++;
            }
        }
        
        ann = [annClass polygonWithCoordinates:cllocations count:coorCounts];
        
        if ([ann respondsToSelector:@selector(setInfo:)])
        {
            [ann performSelector:@selector(setInfo:) withObject:item.annotationInfo];
        }
        
        [self.overlayArrs addObject:ann];
        [self.overlayItemsArr addObject:item];
        [self.mapView addOverlay:ann];
    }
    else
    {
        ann = [[annClass alloc] init];
        if ([ann respondsToSelector:@selector(setInfo:)])
        {
            [ann performSelector:@selector(setInfo:) withObject:item.annotationInfo];
        }
        
        if ([ann respondsToSelector:@selector(setIndex:)])
        {
            [ann performSelector:@selector(setIndex:) withObject:@(item.index)];
        }
        
        [self.annotationArrs addObject:ann];
        [self.annotationItemsArr addObject:item];
        [self.mapView addAnnotation:ann];
        
        if (item.loadCallback)
        {
            XTYMapViewAnnLoadItem *loadItem = [[XTYMapViewAnnLoadItem alloc] init];
            loadItem.loadCallback = item.loadCallback;
            [self.needCallLoadCallbacks addObject:loadItem];
            item.loadCallback = nil;
        }
    }
    
    return ann;
}

- (void)deleteAnnOrOverlayWithItem:(XTYMapAnnotationItem *)item
{
    if (item.isOverlay)
    {
        id overlay = [self.overlayArrs objectAtIndex:[self.overlayItemsArr indexOfObject:item]];
        
        [self.overlayArrs removeObject:overlay];
        [self.overlayItemsArr removeObject:item];
        [self.mapView removeOverlay:overlay];
    }
    else
    {
        id ann = [self.annotationArrs objectAtIndex:[self.annotationItemsArr indexOfObject:item]];
        
        [self.annotationArrs removeObject:ann];
        [self.annotationItemsArr removeObject:item];
        [self.mapView removeOverlay:ann];
    }
}

#pragma mark - change the center of map
- (void)changeMapViewCenterWith:(CLLocationCoordinate2D)coordinate andAnimated:(BOOL)animated
{
    [self.mapView setCenterCoordinate:coordinate animated:animated];
}

- (void)changeMapViewCenterWith:(CLLocationCoordinate2D)coordinate andSpan:(CLLocationDegrees)delta andCompel:(BOOL)compel andAnimated:(BOOL)animated
{
    MKMapView *mapView = self.mapView;
    
    MKCoordinateSpan span = mapView.region.span;
    
    if (compel)
    {
        span.latitudeDelta = delta;
        span.longitudeDelta = delta;
    }
    else if (span.latitudeDelta>delta || span.longitudeDelta>delta)
    {
        span.latitudeDelta = delta;
        span.longitudeDelta = delta;
    }
    
    MKCoordinateRegion regon = MKCoordinateRegionMake(coordinate, span);
    [mapView setRegion:regon animated:animated];
}

- (void)changeMapViewCenterWith:(CLLocationCoordinate2D)coordinate
{
    [self changeMapViewCenterWith:coordinate andSpan:0.3 andCompel:NO andAnimated:YES];
}

- (void)selectAnnWithIndex:(XTYMapAnnIndex)index
{
    id<MKAnnotation> ann = [self getAnnotationWithAnnIndex:index];
    if (ann)
    {
        [self.mapView selectAnnotation:ann animated:YES];
    }
}

- (void)selectCurrentAnnAnimated:(BOOL)animated
{
    if (!_currentAnnotation)
    {
        return;
    }
    
    [self.mapView selectAnnotation:self.currentAnnotation animated:animated];
}

- (void)deselectCurrentAnnAnimated:(BOOL)animated
{
    if (!_currentAnnotation)
    {
        return;
    }
    
    [self.mapView deselectAnnotation:self.currentAnnotation animated:animated];
}

#pragma mark - get annotation instance
- (id<MKAnnotation>)getAnnotationWithAnnIndex:(XTYMapAnnIndex)index
{
    if (self.annotationArrs.count == 0) return nil;
    
    return self.annotationArrs[index];
}

- (id<MKOverlay>)getOverlayWithAnnIndex:(XTYMapOverIndex)index
{
    if (self.overlayArrs.count == 0) return nil;
    
    return self.overlayArrs[index];
}

#pragma mark - method of item process
- (void)setUpAnnotationItemList:(NSArray *)arr
{
    [self.mapView removeOverlays:self.overlayArrs];
    [self.mapView removeAnnotations:self.annotationArrs];
    [self.annotationArrs removeAllObjects];
    [self.overlayArrs removeAllObjects];
    [self.annotationItemsArr removeAllObjects];
    [self.overlayItemsArr removeAllObjects];
    [self.needCallLoadCallbacks removeAllObjects];
    
    for (XTYMapAnnotationItem *item in arr)
    {
        if (![item isKindOfClass:[XTYMapAnnotationItem class]])
        {
#if DEBUG
            NSLog(@"format of item is incorrect");
            assert(0);
#endif
            return;
        }
        
        [self createAnnOrOverlayWithItem:item];
    }
}

- (void)deleteAnnotationItems:(NSArray *)arr
{
    for (XTYMapAnnotationItem *item in arr)
    {
        [self deleteAnnOrOverlayWithItem:item];
    }
}

- (void)addAnnotationItems:(NSArray *)arr
{
    for (XTYMapAnnotationItem *item in arr)
    {
        [self createAnnOrOverlayWithItem:item];
    }
}

- (void)reloadAnnotationItems:(NSArray *)arr
{
    for (XTYMapAnnotationItem *item in arr)
    {
        [self deleteAnnOrOverlayWithItem:item];
        [self createAnnOrOverlayWithItem:item];
    }
}

- (void)deleteAllAnnotationItems
{
    [self.mapView removeOverlays:self.overlayArrs];
    [self.mapView removeAnnotations:self.annotationArrs];
    [self.annotationArrs removeAllObjects];
    [self.overlayArrs removeAllObjects];
    [self.annotationItemsArr removeAllObjects];
    [self.overlayItemsArr removeAllObjects];
    
    [self.needCallLoadCallbacks removeAllObjects];
    
#if DEBUG
    NSLog(@"is mainthead = %@",@([NSThread currentThread].isMainThread));
#endif
}

#pragma mark - MapViewDelegate
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([self.overlayArrs containsObject:overlay])
    {
        NSInteger index = [self.overlayArrs indexOfObject:overlay];
        XTYMapAnnotationItem *item = self.overlayItemsArr[index];
        Class overlayViewClass = item.annotationViewClass;
        id overlayView = [[overlayViewClass alloc] initWithOverlay:overlay];
        
        if (item.loadCallback)
        {
            item.loadCallback(overlayView);
        }
        
        if (item.willAddInMapViewCallback)
        {
            item.willAddInMapViewCallback(overlayView,overlay);
            item.willAddInMapViewCallback = nil;
        }
        
        return overlayView;
    }
    
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
{
    if ([annotation isEqual:self.currentAnnotation])
    {
        if (self.currentAnnItem)
        {
            Class annViewClass = self.currentAnnItem.annotationViewClass;
            
            MKAnnotationView *annView = [mapView dequeueReusableAnnotationViewWithIdentifier:self.currentAnnItem.reusableIdentifier];
            if (!annView)
            {
                annView = [[annViewClass alloc] initWithAnnotation:annotation reuseIdentifier:self.currentAnnItem.reusableIdentifier];
            }
            
            if (self.currentAnnItem.willAddInMapViewCallback)
            {
                self.currentAnnItem.willAddInMapViewCallback(annView,annotation);
            }
            
            return annView;
        }
        
        MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        view.image = [UIImage imageNamed:@""];
        
        return view;
        
    }
    else if ([self.annotationArrs containsObject:annotation])
    {
        NSUInteger index = [self.annotationArrs indexOfObject:annotation];
        XTYMapAnnotationItem *item = self.annotationItemsArr[index];
        Class annViewClass = item.annotationViewClass;
        
        MKAnnotationView *annView = [mapView dequeueReusableAnnotationViewWithIdentifier:item.reusableIdentifier];
        if (!annView)
        {
            annView = [[annViewClass alloc] initWithAnnotation:annotation reuseIdentifier:item.reusableIdentifier];
        }
        
        if (item.willAddInMapViewCallback)
        {
            item.willAddInMapViewCallback(annView,annotation);
        }
        
        return annView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view NS_AVAILABLE(10_9, 4_0);
{
    if([self.annotationArrs containsObject:view.annotation])
    {
        NSInteger index = [self.annotationArrs indexOfObject:view.annotation];
        XTYMapAnnotationItem *item = self.annotationItemsArr[index];
        
        if(item.didSelectCallback)
        {
            item.didSelectCallback(view);
        }
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view NS_AVAILABLE(10_9, 4_0);
{
    if([self.annotationArrs containsObject:view.annotation])
    {
        NSInteger index = [self.annotationArrs indexOfObject:view.annotation];
        XTYMapAnnotationItem *item = self.annotationItemsArr[index];
        if(item.didDeselectCallback)
        {
            item.didDeselectCallback(view);
        }
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views;
{
    for (MKAnnotationView *view in views)
    {
        if([self.annotationArrs containsObject:view.annotation])
        {
            NSInteger index = [self.annotationArrs indexOfObject:view.annotation];
            XTYMapAnnotationItem *item = self.annotationItemsArr[index];
            if(item.willAddInMapViewCallback)
            {
                item.willAddInMapViewCallback(view,view.annotation);
            }
        }
    }
    
    [self callLoadCallbackWithAnnViews:views];
}

- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews
{
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    if (fullyRendered)
    {
        self.mapIsLoad = YES;
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    self.mapView.showsUserLocation = YES;
}

#pragma mark - setter method
- (void)setCurrentAnn:(CLLocationCoordinate2D)coordinate
{
    if (self.currentAnnotation)
    {
        [self.mapView removeAnnotation:self.currentAnnotation];
    }
    
    self.currentAnnotation = [[CurrentAnnotation alloc] initWithCoordinate:coordinate];
    [self.mapView addAnnotation:self.currentAnnotation];
}

- (void)setCurrentAnnItem:(XTYMapAnnotationItem *)item
{
    if (_currentAnnItem)
    {
        [self.mapView removeAnnotation:self.currentAnnotation];
    }
    
    _currentAnnItem = item;
    id<MKAnnotation> ann = [[item.annotationClass alloc] init];
    
    if ([ann respondsToSelector:@selector(setInfo:)])
    {
        [ann performSelector:@selector(setInfo:) withObject:item.annotationInfo];
    }
    self.currentAnnotation = ann;
    [self.mapView addAnnotation:ann];
}

#pragma mark -- 计算所有点的缩放级别
- (void)showAllAnnotationAnimated:(BOOL)animated
{
    [self showAnnotations:self.annotationArrs animated:animated];
}

- (void)showAllAnnotationWithEdage:(UIEdgeInsets)inset animated:(BOOL)animated
{
    if (self.annotationArrs.count==0)
    {
        return;
    }
    
    CLLocationCoordinate2D coords[self.annotationArrs.count];
    NSInteger i = 0;
    for (id<MKAnnotation>ann in self.annotationArrs)
    {
        coords[i] = [ann coordinate];
        i++;
    }
    
    MKCoordinateRegion region = [self getAllAnnotationRegionWithCoordinates:coords andCount:self.annotationArrs.count];
    MKMapRect rect = [self MKMapRectForCoordinateRegion:region];
    [self.mapView setVisibleMapRect:rect edgePadding:inset animated:YES];
}

- (MKCoordinateRegion)getAllAnnotationRegionWithCoordinates:(CLLocationCoordinate2D *)coordinates andCount:(NSInteger)count
{
    // min lat span
#define MinSpanLat  0.001
    // min log span
#define MinSpanLng  0.001
    // empty edge
#define DeltaFactor 1.25
    
    __block CLLocationDegrees minLat = 0.0;
    __block CLLocationDegrees maxLat = 0.0;
    __block CLLocationDegrees minLng = 0.0;
    __block CLLocationDegrees maxLng = 0.0;
    
    for (int i=0; i<count; i++)
    {
        CLLocationCoordinate2D coordinate = coordinates[i];
        if (i == 0)
        {
            minLat = coordinate.latitude;
            maxLat = coordinate.latitude;
            minLng = coordinate.longitude;
            maxLng = coordinate.longitude;
        }
        else
        {
            minLat = minLat < coordinate.latitude ? minLat : coordinate.latitude;
            maxLat = maxLat > coordinate.latitude ? maxLat : coordinate.latitude;
            minLng = minLng < coordinate.longitude ? minLng : coordinate.longitude;
            maxLng = maxLng > coordinate.longitude ? maxLng : coordinate.longitude;
        }
    }
    
    CLLocationDegrees deltaLat = (maxLat - minLat)*DeltaFactor;
    CLLocationDegrees deltaLng = (maxLng - minLng)*DeltaFactor;
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((minLat+maxLat)/2, (minLng+maxLng)/2);
    MKCoordinateSpan span = MKCoordinateSpanMake(deltaLat > MinSpanLat?deltaLat:MinSpanLat
                                                 , deltaLng > MinSpanLng?deltaLng:MinSpanLng);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
    return region;
}

- (void)showCenterWithCoordinates:(CLLocationCoordinate2D *)coordinates andCount:(NSInteger)count animated:(BOOL)animated
{
    MKCoordinateRegion region = [self getAllAnnotationRegionWithCoordinates:coordinates andCount:count];
    [self.mapView setRegion:region animated:YES];
}

- (MKMapRect)MKMapRectForCoordinateRegion:(MKCoordinateRegion)region
{
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude + region.span.latitudeDelta / 2,
                                                                      region.center.longitude - region.span.longitudeDelta / 2));
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude - region.span.latitudeDelta / 2,
                                                                      region.center.longitude + region.span.longitudeDelta / 2));
    return MKMapRectMake(MIN(a.x,b.x), MIN(a.y,b.y), ABS(a.x-b.x), ABS(a.y-b.y));
}

-(void)showAnnotations:(NSArray*)annotations animated:(BOOL)animated
{
    if (annotations.count==0) return;
    
    CLLocationCoordinate2D coords[annotations.count];
    NSInteger i = 0;
    for (id<MKAnnotation>ann in annotations)
    {
        coords[i] = [ann coordinate];
        i++;
    }
    
    [self showCenterWithCoordinates:coords andCount:annotations.count animated:animated];
}

#pragma mark - recall
- (void)callLoadCallbackWithAnnViews:(NSArray *)views
{
    @synchronized(_needCallLoadCallbacks)
    {
        if ([self.needCallLoadCallbacks count] > 0)
        {
            for (MKAnnotationView *view in views)
            {
                if (![self.annotationArrs containsObject:view.annotation]) continue;
                NSInteger index = [self.annotationArrs indexOfObject:view.annotation];
                XTYMapViewAnnLoadItem *item = self.needCallLoadCallbacks[index];
                if (item.isCalled)
                {
                    continue;
                }
                
                void(^loadCallback)() = item.loadCallback;
                loadCallback(view);
                item.isCalled = YES;
            }
        }
    }
}

@end