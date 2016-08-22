//
//  XTYMapAnnotationItem.h
//  XTYMapView
//
//  Created by Michael on 16/8/21.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FinishLoadAnnotationViewCallback)(id annotationView);
typedef void(^DidSelectCallback)(id annotationView);
typedef void(^DidDeselectCallback)(id annotationView);
typedef void(^WillAddInMapViewCallback)(id annotationView,id annotation);

@protocol XTYMapAnnotationItemProtocol <NSObject>

- (void)setInfo:(id)info;
- (void)setIndex:(NSInteger)index;

@end

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