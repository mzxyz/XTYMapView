//
//  CTYColletionViewFlowlayout.h
//  XTYMapViewDemo
//
//  Created by Michael on 16/8/27.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CTYColletionViewFlowlayoutDelegate <NSObject>

- (void)collectionView:(UICollectionView *)collectionView didScrollToCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CTYColletionViewFlowlayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id <CTYColletionViewFlowlayoutDelegate> delegate;

@end