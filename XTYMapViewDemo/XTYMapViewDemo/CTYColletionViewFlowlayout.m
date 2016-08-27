//
//  CTYColletionViewFlowlayout.m
//  XTYMapViewDemo
//
//  Created by Michael on 16/8/27.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "CTYColletionViewFlowlayout.h"

#define CONSTRAINT_VALUE(value, min, max) MIN(MAX((value), (min)), (max))
@implementation CTYColletionViewFlowlayout

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGSize size = self.collectionView.bounds.size;
    CGPoint center = CGPointMake(size.width/2, size.height/2);
    CGFloat w = self.collectionView.bounds.size.width;
    CGFloat h = self.collectionView.bounds.size.height;
    CGRect targetRect = CGRectZero;
    
    enum _ProposedDirection {
        _ProposedDirection_Left = 0,
        _ProposedDirection_Right,
        _ProposedDirection_Current,
    } direction = _ProposedDirection_Current;
    
    if (proposedContentOffset.x+w/2 > center.x) {
        targetRect = CGRectMake(center.x-w/2, 0, w*2, h);
        direction = _ProposedDirection_Right;
    }
    else if (proposedContentOffset.x+w/2 < center.x) {
        targetRect = CGRectMake(center.x-w/2-w, 0, w*2, h);
        direction = _ProposedDirection_Left;
    }
    else {
        targetRect = CGRectMake(center.x-w/2, 0, w, h);
    }
    
    BOOL swipe = ABS(velocity.x) >= 0.3;
    if (swipe) {
        if (velocity.x > 0) {
            direction = _ProposedDirection_Right;
        }
        else if (velocity.x < 0) {
            direction = _ProposedDirection_Left;
        }
    }
    
    NSArray *sips = [self.collectionView indexPathsForSelectedItems];
    if ([sips count] == 0) {
        return proposedContentOffset;
    }
    
    NSIndexPath *sip = [sips firstObject];
    UICollectionViewLayoutAttributes *slayout = [super layoutAttributesForItemAtIndexPath:sip];
    
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    NSIndexPath *ip = nil;
    
    CGPoint pt = CGPointMake(proposedContentOffset.x+w/2, h/2);
    if (slayout && !swipe && CGRectContainsPoint(slayout.frame, pt)) {
        proposedContentOffset.x = CGRectGetMidX(slayout.frame)-w/2;
        ip = sip;
    }
    else {
        for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
            if (direction == _ProposedDirection_Right
                && layoutAttributes.indexPath.item == sip.item+1) {
                ip = layoutAttributes.indexPath;
                proposedContentOffset.x = CGRectGetMidX(layoutAttributes.frame)-w/2;
                break;
            }
            else if (direction == _ProposedDirection_Left
                     && layoutAttributes.indexPath.item == sip.item-1) {
                ip = layoutAttributes.indexPath;
                proposedContentOffset.x = CGRectGetMidX(layoutAttributes.frame)-w/2;
                break;
            }
            else if (direction == _ProposedDirection_Current
                     && CGRectContainsPoint(layoutAttributes.frame, pt)) {
                ip = layoutAttributes.indexPath;
                proposedContentOffset.x = CGRectGetMidX(layoutAttributes.frame)-w/2;
                break;
            }
        }
        
        if (!ip) {
            if (direction == _ProposedDirection_Right) {
                UICollectionViewLayoutAttributes *last = [array lastObject];
                ip = last.indexPath;
                proposedContentOffset.x = CGRectGetMidX(last.frame)-w/2;
            }
            else if (direction == _ProposedDirection_Left) {
                UICollectionViewLayoutAttributes *first = [array firstObject];
                ip = first.indexPath;
                proposedContentOffset.x = CGRectGetMidX(first.frame)-w/2;
            }
            else {
                ip = sip;
                proposedContentOffset.x = CGRectGetMidX(slayout.frame)-w/2;
            }
        }
    }
    
    if (ip) {
        [self.delegate collectionView:self.collectionView didScrollToCellAtIndexPath:ip];
    } else {
        ip = ip;
    }
    
    proposedContentOffset.x = CONSTRAINT_VALUE(proposedContentOffset.x,
                                               -self.collectionView.contentInset.left,
                                               self.collectionView.contentSize.width+self.collectionView.contentInset.right-w);
    
    return proposedContentOffset;
}

@end