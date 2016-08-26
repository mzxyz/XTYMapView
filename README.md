# XTYMapView
  


#Main features

#Demonstration
![image](https://github.com/HuanDay/XTYCycleScrollView/blob/master/ScrollViewTest/ScrollViewTest/scrollViewDemo.gif)

#Requirements
* iOS 7.0+ 
* Xcode 7.0+

#Installation
  * Move the `CTYMapView` into you project
  * Import `XTYMapView.h`

#API
##Annotation Item Properties

```
@interface XTYMapAnnotationItem : NSObject

@property (nonatomic, strong) Class annotationViewClass;
@property (nonatomic, strong) Class annotationClass;
@property (nonatomic, strong) NSString *reusableIdentifier;

@property (nonatomic, copy) DidSelectCallback didSelectCallback;
@property (nonatomic, copy) DidDeselectCallback didDeselectCallback;
@property (nonatomic, copy) FinishLoadAnnotationViewCallback loadCallback;
@property (nonatomic, copy) WillAddInMapViewCallback willAddInMapViewCallback;

@property (nonatomic, strong) id annotationInfo;
@property (nonatomic, assign) BOOL isOverlay;
@property (nonatomic, assign) NSInteger index;

@end

```

##XTYMapView Method
XTYMapView provides various methods to add annotations to mapView and use call back properties to deliver selected event.  It is easy to change the center and scale of the mapView.

```
/**get the apple mapView with this readonly mapView*/
@property (nonatomic, readonly) MKMapView *mapView;

/**
 *  set annotation item list manually
 *
 *  @param arr XTYMapAnnotationItem item list
 */
- (void)setUpAnnotationItemList:(NSArray<XTYMapAnnotationItem *> *)arr;

/**
 *  show all annotation view
 *
 *  @param animated with animation or not
 */
- (void)showAllAnnotationAnimated:(BOOL)animated;

/**
 *  change the map center to specified coordinate
 *
 *  @param coordinate center coordinate
 */
- (void)changeMapViewCenterWith:(CLLocationCoordinate2D)coordinate;

/**
 *  change the map center to specified coordinate and scale to specified span
 *
 *  @param coordinate center coordinate
 *  @param delta      span parameter
 *  @param compel     set span automatic or use the specified span
 *  @param animated   set the transform with animation or not
 */
- (void)changeMapViewCenterWith:(CLLocationCoordinate2D)coordinate andSpan:(CLLocationDegrees)delta andCompel:(BOOL)compel andAnimated:(BOOL)animated;

```

#Usage
It is very easy to use in your program.

```
```

#LICENSE
XTYMapView is released under the MIT license. See LICENSE for details.