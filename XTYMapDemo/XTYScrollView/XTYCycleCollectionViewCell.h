//
//  XTYCycleCollectionViewCell.h
//  XTYCycleScrollView
//
//  Created by Mr.Sunday on 16/8/13.
//  Copyright © 2016年 Sunday. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XTYCycleCollectionViewCell : UICollectionViewCell


@property (nonatomic, strong)   UIView *view;
@property (nonatomic, weak)     UIImageView *imgView;

@property (nonatomic, strong)   UIImage *bgImage;
@property (nonatomic, strong)   UIImage *shadowImage;     

@property (nonatomic, copy)     NSString *title;
@property (nonatomic, strong)   UIColor  *titleLabelTextColor;
@property (nonatomic, strong)   UIFont   *titleLabelTextFont;
@property (nonatomic, strong)   UIColor  *titleLabelBackgroundColor;
@property (nonatomic, assign)   CGFloat  titleLabelHeight;

@property (nonatomic, assign) BOOL hasConfigured;

- (void)setImageView:(id)imageSource;

@end