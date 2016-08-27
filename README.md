# XTYMapView
XTYMapView is a simple and easy to add annotation mapView for iOS. If you are displaying lots of annotations on the map and needing the the annotationView be more reusable , this class is made for you.

#Main Features
- Fast and easy to add annotation.
- All  MKMapViewDelegate method has corresponding block call back for each annotationView.
- Not only support normal annotation, but also provide APIs to add overlay annotation.

#Demonstration
![image](https://github.com/HuanDay/XTYMapView/blob/master/XTYMapDemo/XTYMapDemo/mapViewDemo.gif)

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
XTYMapView provides various methods to add annotations to mapView and use call back properties to deliver selected event.  It is easy to change the center and scales of the mapView.

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
In this demo, we import `XTYModel` to process json data and `XTYCycleScrollView` to present the effect of  `XTYMapView` .

##AnnotationView
Just show the methods,  looking for the details in XTYMapViewDemo files. 

```
@interface DemoAnnotation : NSObject<MKAnnotation>

@property (nonatomic, strong) DemoAnnotationItem *info;

@end

@interface DemoAnnotationView : MKAnnotationView
@end

@implementation DemoAnnotation

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.info.lat, self.info.lng);
}

@end


@interface DemoAnnotationView ()

@property (nonatomic, strong) UIButton *imageBtn;
@property (nonatomic, strong) UIButton *titleBtn;

@end

@implementation DemoAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
}

- (void)setAnnotation:(id<MKAnnotation>)annotation
{
	[super setAnnotation:annotation];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
}
```

##Configure MapView
First init and configure XTYMapAnnotationItem, than set the item list to XTYMapView and show all the annotations. 

```
    WEAKREF(self);
    NSInteger i = 0;
    NSMutableArray *items = [NSMutableArray array];
    NSMutableArray *imageListM = [NSMutableArray array];
    for (DemoAnnotationItem *item in self.annoItemList)
    {
        if (item.lat!=0 && item.lng!=0)
        {
            XTYMapAnnotationItem *annoItem = [[XTYMapAnnotationItem alloc] init];
            annoItem.annotationViewClass = [DemoAnnotationView class];
            annoItem.annotationClass = [DemoAnnotation class];
            annoItem.annotationInfo = item;
            
            annoItem.didSelectCallback = ^(DemoAnnotationView *annotationView)
            {
                [wself.mapView changeMapViewCenterWith:CLLocationCoordinate2DMake(item.lat, item.lng) andAnimated:YES];
            };
            
            [items addObject:annoItem];
            
            i++;
        }
    }
    
    [self.mapView setUpAnnotationItemList:items];
    [self.mapView showAllAnnotationAnimated:YES];

```

#LICENSE
XTYMapView is released under the MIT license. See LICENSE for details.
