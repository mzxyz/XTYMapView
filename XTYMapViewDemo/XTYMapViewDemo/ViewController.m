//
//  ViewController.m
//  XTYMapViewDemo
//
//  Created by Michael on 16/8/27.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "ViewController.h"
#import "CTYColletionViewFlowlayout.h"
#import "DemoCollectionViewCell.h"
#import "DemoAnnotationItem.h"
#import "XTYCoordinateItem.h"
#import "DemoAnnotationView.h"
#import "XTYMapView.h"

@interface ViewController ()<CTYColletionViewFlowlayoutDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) XTYMapView *mapView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) CTYColletionViewFlowlayout *layout;
@property (nonatomic, strong) NSArray<DemoAnnotationItem *> *annoItemList;

@end

@implementation ViewController

#define WEAKREF(ttttt)          __weak __typeof__ (ttttt) w##ttttt = ttttt
#define ScreenWidth             [UIScreen mainScreen].bounds.size.width
#define ScreenHeight            [UIScreen mainScreen].bounds.size.height
#define ItemWidth               (ScreenWidth-15*2-12*2)
#define MapHeight               (ScreenHeight-64-110)
#define CollectionViewHeight    110
#define ItemViewHight           90

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.mapView = [[XTYMapView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, MapHeight)];
    [self.view addSubview:self.mapView];
    
    self.layout = [[CTYColletionViewFlowlayout alloc] init];
    self.layout.minimumLineSpacing = 12;
    self.layout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15);
    self.layout.itemSize = CGSizeMake(ItemWidth, ItemViewHight);
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView =
    [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64+MapHeight, ScreenWidth, CollectionViewHeight) collectionViewLayout:self.layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.layout.delegate = self;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.collectionView registerClass:[DemoCollectionViewCell class] forCellWithReuseIdentifier:@"DemoCollectionViewCell"];
    [self.view addSubview:_collectionView];
    
    [self configMapView];
}

- (void)configMapView
{
    if (self.annoItemList.count == 0) return;
    
    NSInteger i = 0;
    NSMutableArray *items = [NSMutableArray array];
    WEAKREF(self);
    for (DemoAnnotationItem *item in self.annoItemList)
    {
        if (item.coordinateItem.lat!=0 && item.coordinateItem.lng!=0)
        {
            XTYMapAnnotationItem *annoItem = [[XTYMapAnnotationItem alloc] init];
            annoItem.annotationViewClass = [DemoAnnotationView class];
            annoItem.annotationClass = [DemoAnnotation class];
            annoItem.annotationInfo = item;
            
            annoItem.didSelectCallback = ^(DemoAnnotationView *annotationView){
                [wself.mapView changeMapViewCenterWith:CLLocationCoordinate2DMake(item.coordinateItem.lat, item.coordinateItem.lng) andAnimated:YES];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                [wself.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
            };
            [items addObject:item];
            
            i++;
        }
    }
    
    [self.mapView setUpAnnotationItemList:items];
    [self collectionView:self.collectionView didScrollToCellAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [self.mapView showAllAnnotationAnimated:YES];
}

#pragma mark -- CollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.annoItemList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DemoAnnotationItem *item = self.annoItemList[indexPath.item];
    
    DemoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DemoCollectionViewCell" forIndexPath:indexPath];
    
    return cell;
}

#pragma mark -- CollectionDelegate
- (void)collectionView:(UICollectionView *)collectionView didScrollToCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item<self.annoItemList.count)
    {
        [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        id<MKAnnotation> ann = [self.mapView getAnnotationWithAnnIndex:indexPath.item];
        [self.mapView.mapView selectAnnotation:ann animated:YES];
    }
}

@end