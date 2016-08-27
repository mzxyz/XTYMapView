//
//  XTYCycleScrollView.h
//  XTYCycleScrollView
//
//  Created by Mr.Sunday on 16/8/13.
//  Copyright © 2016年 Sunday. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - stype ENUM
typedef NS_ENUM(NSInteger,XTYCycleScrollViewPageContolAliment)
{
    XTYCycleScrollViewPageContolAlimentRight,
    XTYCycleScrollViewPageContolAlimentCenter
};

typedef NS_ENUM(NSInteger,XTYCycleScrollViewPageContolStyle)
{
    XTYCycleScrollViewPageContolStyleClassic,        // system default style
    XTYCycleScrollViewPageContolStyleAnimated,       // animation pagecontrol
    XTYCycleScrollViewPageContolStyleNone            // do not show pagecontrol
};


#pragma mark - select protocol
@class XTYCycleScrollView;
@protocol XTYCycleScrollViewDelegate <NSObject>

@optional

/**
 *  tells the delegate the view scroll to the specific index
 *
 *  @param cycleScrollView  the scroll view
 *  @param index           next index
 */
- (void)cycleScrollView:(XTYCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index;

/**
 *  tells the delegate the item at specific index was selected
 *
 *  @param cycleScrollView the scroll view
 *  @param index           the index of selected view
 */
- (void)cycleScrollView:(XTYCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index;

@end


#pragma mark - scrollView class
@interface XTYCycleScrollView : UIView

/**
 *  init method with config parameters
 *
 *  @param frame        scroll view frame
 *  @param target       delegate target
 *  @param dotColor     page control dot color
 *  @param infiniteLoop whether infinite loop automaitically
 *
 *  @return scroll View instance
 */
- (instancetype)initWithFrame:(CGRect)frame target:(id)target dotColor:(UIColor *)dotColor infiniteLoop:(BOOL)infiniteLoop;


#pragma mark - data source
/**
 *  config method with data source
 *
 *  @param itemList element of item list can be image url<string>, image<UIImage> or view<UIView>
 */
- (void)configScrollViewWithItemList:(NSArray *)itemList;

/** properties which can config*/
@property (nonatomic, readonly) UIScrollView *scrollView;

/** local images data list*/
@property (nonatomic, strong) NSArray<NSString *> *localImagesGroup;

/** web image data list*/
@property (nonatomic, strong) NSArray<NSString *> *imageURLStringsGroup;

/** title for each image data list*/
@property (nonatomic, strong) NSArray<NSString *> *titlesGroup;

/** views list*/
@property (nonatomic, strong) NSArray<UIView *> *viewsGroup;


#pragma mark - scroll control properties
/** croll time interval, default 2s*/
@property (nonatomic, assign) CGFloat autoScrollTimeInterval;

/** can infinite loop, default Yes*/
@property(nonatomic,assign) BOOL infiniteLoop;

/** automatic scroll, default Yes*/
@property(nonatomic,assign) BOOL autoScroll;

/** the delegate of touch inside event*/
@property (nonatomic, weak) id<XTYCycleScrollViewDelegate> delegate;


#pragma mark - customize style
/** show the pageControl, default Yes*/
@property (nonatomic, assign) BOOL showPageControl;

/** if only one page, hiden pageControl, default Yes*/
@property (nonatomic, assign) BOOL hidesForSinglePage;

/** pagecontrol style，default XTYCycleScrollViewPageContolStyleAnimated*/
@property (nonatomic, assign) XTYCycleScrollViewPageContolStyle pageControlStyle;

/** placeholder image*/
@property (nonatomic, strong) UIImage *placeholderImage;

/** the shadow image*/
@property (nonatomic, strong) UIImage *shadowImage;

/** the aliment of pageControl*/
@property (nonatomic, assign) XTYCycleScrollViewPageContolAliment pageControlAliment;

/** pageControl frame, use center to ajust it's frame*/
@property (nonatomic, assign) CGPoint pageControlCenter;

/** the dot size of pageControl*/
@property (nonatomic, assign) CGSize pageControlDotSize;

/** the color of pageControl dot*/
@property (nonatomic, strong) UIColor *dotColor;

/** the highlight color of pageContril dot*/
@property (nonatomic, strong) UIColor *dotHightlightColor;

/** the image of dot*/
@property (nonatomic, strong) UIImage *dotImage;

/** the highlight image of dot*/
@property (nonatomic, strong) UIImage *dotHightLightImage;

/** the properties of title Label*/
@property (nonatomic, strong) UIColor *titleLabelTextColor;
@property (nonatomic, strong) UIFont  *titleLabelTextFont;
@property (nonatomic, strong) UIColor *titleLabelBackgroundColor;
@property (nonatomic, assign) CGFloat titleLabelHeight;

/** scroll deriction vertical or horizontal*/
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;


/** class method to init instance*/
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame;

/**
 *  init instance
 *
 *  @param frame       scroll view frame
 *  @param imagesGroup image list @[(UIImage),...]
 *
 *  @return scroll view instance
 */
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame imagesGroup:(NSArray<UIImage *> *)imagesGroup;

/**
 *  init instance
 *
 *  @param frame                <#frame description#>
 *  @param imageURLStringsGroup <#imageURLStringsGroup description#>
 *
 *  @return <#return value description#>
 */
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame imageURLStringsGroup:(NSArray<NSString *> *)imageURLStringsGroup;

@end