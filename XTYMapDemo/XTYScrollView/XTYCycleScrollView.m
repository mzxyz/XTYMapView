//
//  XTYCycleScrollView.m
//  XTYCycleScrollView
//
//  Created by Mr.Sunday on 16/8/13.
//  Copyright © 2016年 Sunday. All rights reserved.
//

#import "XTYCycleScrollView.h"
#import "XTYCycleCollectionViewCell.h"
#import "TAPageControl.h"


static NSString * const ID = @"cycleCell";


@interface XTYCycleScrollView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak)     UICollectionView *mainView;
@property (nonatomic, weak)     UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong)   NSMutableArray *imagesGroup;
@property (nonatomic, weak)     NSTimer *timer;
@property (nonatomic, assign)   NSInteger totalItemsCount;
@property (nonatomic, weak)     UIControl *pageControl;

@end

@implementation XTYCycleScrollView

#pragma mark - init method
- (void)dealloc
{
    _mainView.delegate = nil;
    _mainView.dataSource = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (UICollectionView *)scrollView
{
    return _mainView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
        [self setupMainView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialization];
        [self setupMainView];
    }
    return self;
}

- (void)initialization
{
    _pageControlAliment = XTYCycleScrollViewPageContolAlimentCenter;
    _autoScrollTimeInterval = 5.0;
    _titleLabelTextColor = [UIColor whiteColor];
    _titleLabelTextFont= [UIFont systemFontOfSize:14];
    _titleLabelBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _titleLabelHeight = 30;
    _autoScroll = YES;
    _infiniteLoop = YES;
    _showPageControl = YES;
    _pageControlDotSize = CGSizeMake(10, 10);
    _pageControlCenter = CGPointZero;
    _pageControlStyle = XTYCycleScrollViewPageContolStyleAnimated;
    
    self.placeholderImage = [UIImage imageNamed:@"default_logo"];
    self.backgroundColor = [UIColor greenColor];
}

- (instancetype)initWithFrame:(CGRect)frame target:(id)target dotColor:(UIColor *)dotColor infiniteLoop:(BOOL)infiniteLoop
{
    self = [self initWithFrame:frame];
    if (self)
    {
        self.dotColor = dotColor;
        self.infiniteLoop = infiniteLoop;
        self.delegate = target;
    }
    
    return self;
}

+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame
{
    XTYCycleScrollView *cycleScrollView = [[self alloc] initWithFrame:frame];
    return cycleScrollView;
}

+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame imagesGroup:(NSArray *)imagesGroup
{
    XTYCycleScrollView *cycleScrollView = [[self alloc] initWithFrame:frame];
    cycleScrollView.imagesGroup = [NSMutableArray arrayWithArray:imagesGroup];
    return cycleScrollView;
}

+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame imageURLStringsGroup:(NSArray *)imageURLsGroup
{
    XTYCycleScrollView *cycleScrollView = [[self alloc] initWithFrame:frame];
    cycleScrollView.imageURLStringsGroup = [NSMutableArray arrayWithArray:imageURLsGroup];
    return cycleScrollView;
}

#pragma mark - config mainView
- (void)setupMainView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = self.frame.size;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _flowLayout = flowLayout;
    
    UICollectionView *mainView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    mainView.backgroundColor = [UIColor clearColor];
    mainView.pagingEnabled = YES;
    mainView.showsHorizontalScrollIndicator = NO;
    mainView.showsVerticalScrollIndicator = NO;
    mainView.dataSource = self;
    mainView.delegate = self;
    mainView.scrollsToTop = NO;
    
    [mainView registerClass:[XTYCycleCollectionViewCell class] forCellWithReuseIdentifier:ID];
    [self addSubview:mainView];
    _mainView = mainView;
}

/** configure scrollView*/
- (void)configScrollViewWithItemList:(NSArray *)itemList
{
    [self setPageControlStyleWithItemList:itemList];
    
    if (itemList.count !=0)
    {
        if ([itemList[0] isKindOfClass:[NSString class]])
        {
            self.imageURLStringsGroup = itemList;
        }
        else if ([itemList[0] isKindOfClass:[UIImage class]])
        {
            self.localImagesGroup = itemList;
        }
        else if ([itemList[0] isKindOfClass:[UIView class]])
        {
            self.viewsGroup = itemList;
        }
    }
}

- (void)setPageControlStyleWithItemList:(NSArray *)itemList
{
    if ([itemList count] == 1)
    {
        self.pageControlStyle = XTYCycleScrollViewPageContolStyleNone;
    }
    else
    {
        self.pageControlStyle = XTYCycleScrollViewPageContolStyleClassic;
    }
}

#pragma mark - properties setter method
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _flowLayout.itemSize = self.frame.size;
}

- (void)setPageControlCenter:(CGPoint)pageControlCenter
{
    _pageControlCenter = pageControlCenter;
    if ([self.pageControl isKindOfClass:[TAPageControl class]])
    {
        self.pageControl.center = pageControlCenter;
    }
}


- (void)setPageControlDotSize:(CGSize)pageControlDotSize
{
    _pageControlDotSize = pageControlDotSize;
    [self setupPageControl];
    
    if ([self.pageControl isKindOfClass:[TAPageControl class]])
    {
        TAPageControl *pageContol = (TAPageControl *)_pageControl;
        pageContol.dotSize = pageControlDotSize;
    }
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage
{
    _hidesForSinglePage = hidesForSinglePage;
    
    if ([self.pageControl isKindOfClass:[TAPageControl class]])
    {
        TAPageControl *pageControl = (TAPageControl *)_pageControl;
        pageControl.hidesForSinglePage = hidesForSinglePage;
    }
    else
    {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.hidesForSinglePage = hidesForSinglePage;
    }
}

- (void)setShowPageControl:(BOOL)showPageControl
{
    _showPageControl = showPageControl;
    
    _pageControl.hidden = !showPageControl;
}

- (void)setDotColor:(UIColor *)dotColor
{
    _dotColor = dotColor;
    
    if ([self.pageControl isKindOfClass:[TAPageControl class]])
    {
        TAPageControl *pageControl = (TAPageControl *)_pageControl;
        pageControl.dotColor = dotColor;
    }
    else
    {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.pageIndicatorTintColor = dotColor;
    }
}

- (void)setDotHightlightColor:(UIColor *)dotHightlightColor
{
    UIPageControl *pageControl = (UIPageControl *)_pageControl;
    pageControl.currentPageIndicatorTintColor = dotHightlightColor;
}

- (void)setDotImage:(UIImage *)dotImage
{
    _dotImage = dotImage;
    
    if ([self.pageControl isKindOfClass:[TAPageControl class]])
    {
        TAPageControl *pageControl = (TAPageControl *)_pageControl;
        pageControl.dotImage = dotImage;
    }
}

- (void)setDotHightLightImage:(UIImage *)dotHightLightImage
{
    _dotHightLightImage = dotHightLightImage;
    
    if ([self.pageControl isKindOfClass:[TAPageControl class]])
    {
        TAPageControl *pageControl = (TAPageControl *)_pageControl;
        pageControl.currentDotImage = dotHightLightImage;
    }
}

- (void)setInfiniteLoop:(BOOL)infiniteLoop
{
    _infiniteLoop = infiniteLoop;
    
    if (!infiniteLoop)
    {
        _autoScroll = NO;
    }
}

-(void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
    [_timer invalidate];
    _timer = nil;
    
    if (_autoScroll)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setupTimer) object:nil];
        [self performSelector:@selector(setupTimer) withObject:nil afterDelay:4];
    }
}

- (void)setAutoScrollTimeInterval:(CGFloat)autoScrollTimeInterval
{
    _autoScrollTimeInterval = autoScrollTimeInterval;
    
    [self setAutoScroll:self.autoScroll];
}

- (void)setPageControlStyle:(XTYCycleScrollViewPageContolStyle)pageControlStyle
{
    _pageControlStyle = pageControlStyle;
    
    [self setupPageControl];
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    _scrollDirection = scrollDirection;
    self.flowLayout.scrollDirection = scrollDirection;
}

- (void)setImagesGroup:(NSMutableArray *)imagesGroup
{
    _imagesGroup = imagesGroup;
    
    _totalItemsCount = self.infiniteLoop ? self.imagesGroup.count * 100 : self.imagesGroup.count;
    
    if (imagesGroup.count != 1)
    {
        self.mainView.scrollEnabled = YES;
        [self setAutoScroll:self.autoScroll];
    }
    else
    {
        self.mainView.scrollEnabled = NO;
    }
    
    [self setupPageControl];
    [self.mainView reloadData];
}

- (void)setImageURLStringsGroup:(NSArray *)imageURLStringsGroup
{
    _imageURLStringsGroup = imageURLStringsGroup;
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:imageURLStringsGroup.count];
    for (int i = 0; i < imageURLStringsGroup.count; i++)
    {
        /**
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageURLStringsGroup[i]]
                                                        options:SDWebImageRetryFailed
                                                       progress:nil
                                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *url) {
                                                      }];
        */
        
        [images addObject:imageURLStringsGroup[i]];
    }
    
    self.imagesGroup = images;
}

- (void)setLocalImagesGroup:(NSArray *)localImagesGroup
{
    _localImagesGroup = localImagesGroup;
    self.imagesGroup = [localImagesGroup mutableCopy];
}

- (void)setViewsGroup:(NSArray<UIView *> *)viewsGroup
{
    _viewsGroup = viewsGroup;
    self.imagesGroup = [viewsGroup mutableCopy];
}

#pragma mark - page & scroll
- (void)setupPageControl
{
    if (_pageControl) [_pageControl removeFromSuperview]; // 重新加载数据时调整
    
    switch (self.pageControlStyle)
    {
        case XTYCycleScrollViewPageContolStyleAnimated:
        {
            TAPageControl *pageControl = [[TAPageControl alloc] init];
            pageControl.numberOfPages = self.imagesGroup.count;
            pageControl.dotColor = self.dotColor;
            pageControl.dotImage = [UIImage imageNamed:@"page_dot_normal"];
            pageControl.currentDotImage = [UIImage imageNamed:@"page_dot_highlight"];
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
            
        case XTYCycleScrollViewPageContolStyleClassic:
        {
            UIPageControl *pageControl = [[UIPageControl alloc] init];
            pageControl.numberOfPages = self.imagesGroup.count;
            pageControl.pageIndicatorTintColor = self.dotColor;
            pageControl.currentPageIndicatorTintColor = self.dotHightlightColor;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
            
        default:
            break;
    }
}


- (void)automaticScroll
{
    if (0 == _totalItemsCount) return;
    
    int currentIndex = 0;
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical)
    {
        currentIndex = _mainView.contentOffset.y / _flowLayout.itemSize.height;
    }
    else
    {
        currentIndex = _mainView.contentOffset.x / _flowLayout.itemSize.width;
    }
    
    
    int targetIndex = currentIndex + 1;
    if (targetIndex >= _totalItemsCount)
    {
        if (self.infiniteLoop)
        {
            targetIndex = _totalItemsCount * 0.5;
        }
        else
        {
            targetIndex = 0;
        }
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:targetIndex inSection:0];
    [_mainView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didScrollToIndex:)])
    {
        [self.delegate cycleScrollView:self didScrollToIndex:(targetIndex%self.imagesGroup.count)];
    }
}

- (void)setupTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

#pragma mark - life circles

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _flowLayout.itemSize = self.frame.size;
    
    _mainView.frame = self.bounds;
    if (_mainView.contentOffset.x == 0 &&  _totalItemsCount)
    {
        NSInteger targetIndex = 0;
        if (self.infiniteLoop)
        {
            targetIndex = _totalItemsCount * 0.5;
        }
        else
        {
            targetIndex = 0;
        }
        
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    CGSize size = CGSizeZero;
    if ([self.pageControl isKindOfClass:[TAPageControl class]])
    {
        TAPageControl *pageControl = (TAPageControl *)_pageControl;
        size = [pageControl sizeForNumberOfPages:self.imagesGroup.count];
    }
    else
    {
        size = CGSizeMake(self.imagesGroup.count * self.pageControlDotSize.width * 1.2, self.pageControlDotSize.height);
    }
    
    CGFloat x = (self.frame.size.width - size.width) * 0.5;
    if (self.pageControlAliment == XTYCycleScrollViewPageContolAlimentRight)
    {
        x = self.mainView.frame.size.width - size.width - 10;
    }
    CGFloat y =  self.mainView.frame.size.height - size.height - 10;
    
    if ([self.pageControl isKindOfClass:[TAPageControl class]])
    {
        TAPageControl *pageControl = (TAPageControl *)_pageControl;
        [pageControl sizeToFit];
    }
    
    _pageControl.frame = CGRectMake(x, y, size.width, size.height);
    if (!CGPointEqualToPoint(_pageControlCenter,CGPointZero))
    {
        _pageControl.center = _pageControlCenter;
    }
    
    _pageControl.hidden = !_showPageControl;
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _totalItemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    long itemIndex = indexPath.item % self.imagesGroup.count;
    id view = self.imagesGroup[itemIndex];
    XTYCycleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    // view->configured view
    if ([view isKindOfClass:[UIView class]])
    {
        cell.view = view;
        return cell;
    }
    else
    {
        // view->image or imageUrl
        cell.shadowImage = self.shadowImage;
        cell.bgImage = self.placeholderImage;
        [cell setImageView:view];
        
        if (_titlesGroup.count) {
            cell.title = _titlesGroup[itemIndex];
        }
        
        if (!cell.hasConfigured) {
            cell.titleLabelBackgroundColor = self.titleLabelBackgroundColor;
            cell.titleLabelHeight = self.titleLabelHeight;
            cell.titleLabelTextColor = self.titleLabelTextColor;
            cell.titleLabelTextFont = self.titleLabelTextFont;
            cell.hasConfigured = YES;
        }
        
        return cell;
    }
}

#pragma - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didSelectItemAtIndex:)])
    {
        [self.delegate cycleScrollView:self didSelectItemAtIndex:indexPath.item % self.imagesGroup.count];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger itemIndex = (scrollView.contentOffset.x + self.mainView.frame.size.width * 0.5) / self.mainView.frame.size.width;
    
    if (!self.imagesGroup.count)
    {
        return;
    }
    
    NSInteger indexOnPageControl = itemIndex % self.imagesGroup.count;
    
    if ([self.pageControl isKindOfClass:[TAPageControl class]]) {
        TAPageControl *pageControl = (TAPageControl *)_pageControl;
        pageControl.currentPage = indexOnPageControl;
    }
    else
    {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPage = indexOnPageControl;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.autoScroll)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.autoScroll)
    {
        [self setupTimer];
    }
}

@end