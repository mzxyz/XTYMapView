//
//  XTYCycleCollectionViewCell.m
//  XTYCycleScrollView
//
//  Created by Mr.Sunday on 16/8/13.
//  Copyright © 2016年 Sunday. All rights reserved.
//

#import "XTYCycleCollectionViewCell.h"

@interface XTYCycleCollectionViewCell ()\

@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UIImageView *shadowImgView;
@property (nonatomic, strong) UIImageView *bgImageView;

@end

@implementation XTYCycleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupImageView];
        [self setupBgImageView];
        [self setupTitleLabel];
        [self setupShadowImageView];
    }
    
    return self;
}

#pragma mark - title setting
- (void)setTitleLabelBackgroundColor:(UIColor *)titleLabelBackgroundColor
{
    _titleLabelBackgroundColor = titleLabelBackgroundColor;
    _titleLabel.backgroundColor = titleLabelBackgroundColor;
}

- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor
{
    _titleLabelTextColor = titleLabelTextColor;
    _titleLabel.textColor = titleLabelTextColor;
}

- (void)setTitleLabelTextFont:(UIFont *)titleLabelTextFont
{
    _titleLabelTextFont = titleLabelTextFont;
    _titleLabel.font = titleLabelTextFont;
}

- (void)setupTitleLabel
{
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    _titleLabel.hidden = YES;
    [self.contentView addSubview:titleLabel];
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    _titleLabel.text = [NSString stringWithFormat:@"%@", title];
}

#pragma mark - imageView setting
- (void)setupImageView
{
    UIImageView *imgView = [[UIImageView alloc] init];
    _imgView = imgView;
    imgView.clipsToBounds = YES;
    imgView.backgroundColor = [UIColor grayColor];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:imgView];
}

- (void)setupBgImageView
{
    UIImageView *bgView = [[UIImageView alloc] init];
    _bgImageView = bgView;
    [self.contentView addSubview:bgView];
}

- (void)setupShadowImageView
{
    UIImageView *shadowView = [[UIImageView alloc] init];
    shadowView.clipsToBounds = YES;
    [self.contentView addSubview:shadowView];
    _shadowImgView = shadowView;
}

- (void)setBgImage:(UIImage *)bgImage
{
    _bgImage = bgImage;
    self.bgImageView.image = bgImage ? bgImage : nil;
}

- (void)setShadowImage:(UIImage *)shadowImage
{
    _shadowImage = shadowImage;
    self.shadowImgView.image = shadowImage ? shadowImage : nil;
}

#pragma mark  - config imageView

- (void)setImageView:(id)imageSource
{
    self.imgView.image = nil;
    
    self.shadowImgView.hidden = YES;
    [self.contentView bringSubviewToFront:self.bgImageView];
    
    if ([imageSource isKindOfClass:[UIImage class]])
    {
        UIImage *image = imageSource;
        self.imgView.image = (image.size.width==0) ? nil : image;
        self.shadowImgView.hidden = (image.size.width==0) ? YES : NO;
    }
    
    /** this needs to import SDWebImage
    else if ([imageSource isKindOfClass:[NSString class]])
    {
        WEAKREF(self);
        [self.imgView sd_cancelCurrentImageLoad];
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:imageSource]
                        placeholderImage:nil
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   if (image)
                                   {
                                       STRONGREF(wself);
                                       [swself.contentView sendSubviewToBack:swself.bgImageView];
                                       swself.shadowImgView.hidden = NO;
                                   }
                               }];
    }
    */
}

- (void)setView:(UIView *)view
{
    if (_view)
    {
        [_view removeFromSuperview];
    }
    _view = view;
    [self.contentView addSubview:view];
}

- (void)removeAllSubViews
{
    for (UIView *view in self.contentView.subviews)
    {
        [view removeFromSuperview];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _imgView.frame = self.bounds;
    /**
    _bgImageView.frameSize = _bgImageView.image.size;
    _bgImageView.center = self.boundsCenter;
    _shadowImgView.frameSize = CGSizeMake(self.frameWidth, _shadowImgView.image.size.height);
    */
    
    if ([_titleLabel.text length] > 0)
    {
        CGFloat titleLabelW = self.frame.size.width;
        CGFloat titleLabelH = _titleLabelHeight;
        CGFloat titleLabelX = 0;
        CGFloat titleLabelY = self.frame.size.height - titleLabelH;
        _titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
        _titleLabel.hidden = NO;
    }
    else
    {
        _titleLabel.hidden = YES;
    }
}

@end