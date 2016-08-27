//
//  ViewController.m
//  XTYMapDemo
//
//  Created by Michael on 16/8/27.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "ViewController.h"
#import "XTYCycleScrollView.h"
#import "DemoAnnotationItem.h"
#import "DemoAnnotationView.h"
#import "XTYMapView.h"

@interface ViewController () <XTYCycleScrollViewDelegate>

@property (nonatomic, strong) XTYMapView *mapView;
@property (nonatomic, strong) XTYCycleScrollView *scrollView;
@property (nonatomic, strong) NSArray<DemoAnnotationItem *> *annoItemList;

@end

@interface ViewController ()

@end

@implementation ViewController

#define WEAKREF(ttttt)          __weak __typeof__ (ttttt) w##ttttt = ttttt
#define ScreenWidth             [UIScreen mainScreen].bounds.size.width
#define ScreenHeight            [UIScreen mainScreen].bounds.size.height
#define ItemWidth               (ScreenWidth-15*2-12*2)
#define MapHeight               (ScreenHeight-150)
#define CollectionViewHeight    150
#define ItemViewHight           90

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.mapView = [[XTYMapView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, MapHeight)];
    [self.view addSubview:self.mapView];
    
    self.scrollView = [[XTYCycleScrollView alloc] initWithFrame:(CGRect){0, MapHeight, ScreenWidth, CollectionViewHeight}
                                                         target:self
                                                       dotColor:[UIColor lightGrayColor]
                                                   infiniteLoop:YES];
    self.scrollView.autoScrollTimeInterval = 1;
    self.scrollView.showPageControl = NO;
    [self.view addSubview:self.scrollView];
    
    [self configAnnoItemList];
    [self configViews];
}

- (void)configViews
{
    if (self.annoItemList.count == 0) return;
    
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
        
        UIImage *image = [UIImage imageNamed:item.imageName];
        [imageListM addObject:image];
    }
    
    [self.mapView setUpAnnotationItemList:items];
    [self.mapView showAllAnnotationAnimated:YES];
    [self.scrollView configScrollViewWithItemList:imageListM];
}

#pragma mark -- XTYCycleScrollViewDelegate
- (void)cycleScrollView:(XTYCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index
{
    if (index < self.annoItemList.count)
    {
        id<MKAnnotation> ann = [self.mapView getAnnotationWithAnnIndex:index];
        [self.mapView.mapView selectAnnotation:ann animated:YES];
    }
}

- (void)configAnnoItemList
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"demo_map" ofType:@"json"];
    XTYJson *dataJson = [XTYJson jsonWithData:[NSData dataWithContentsOfFile:filePath]];
    XTYJson *annoJson = [dataJson jsonForKey:@"data"];
    
    __block NSMutableArray *annoListM = [NSMutableArray array];
    for (NSInteger i=0; i<annoJson.count; i++)
    {
        DemoAnnotationItem *item = [[DemoAnnotationItem alloc] initWithJson:[annoJson jsonAtIndex:i]];
        [annoListM addObject:item];
    }
    
    self.annoItemList = [annoListM copy];    
}

@end