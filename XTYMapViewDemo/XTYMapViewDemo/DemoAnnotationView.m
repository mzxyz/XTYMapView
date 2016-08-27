//
//  DemoAnnotationView.m
//  XTYMapViewDemo
//
//  Created by Michael on 16/8/27.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "DemoAnnotationView.h"

@implementation DemoAnnotation

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.info.coordinateItem.lat, self.info.coordinateItem.lng);
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
    if (self)
    {
        self.imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.imageBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        self.imageBtn.frame = CGRectMake(0, 0, 32, 32);
        self.imageBtn.layer.cornerRadius = 16;
        self.imageBtn.layer.borderWidth = 1;
        self.imageBtn.clipsToBounds = YES;
        [self addSubview:self.imageBtn];
        
        self.titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.titleBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.titleBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self addSubview:self.titleBtn];
        
        self.annotation = annotation;
    }
    
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    DemoAnnotation *anno = (DemoAnnotation *)annotation;
   
    if (self.imageBtn)
    {
        [self.imageBtn setBackgroundImage:[UIImage imageNamed:anno.info.imageName] forState:UIControlStateSelected];
        [self.imageBtn setBackgroundImage:nil forState:UIControlStateNormal];
    }
    
    [self.titleBtn setTitle:anno.info.title forState:UIControlStateNormal];
    [self.titleBtn setTitle:nil forState:UIControlStateSelected];
    
    self.imageBtn.bounds = CGRectZero;
    [self.imageBtn sizeToFit];
    
    self.titleBtn.bounds = CGRectZero;
    [self.titleBtn sizeToFit];
    
    self.frame = CGRectMake(0, 0, self.imageBtn.frame.size.width, self.imageBtn.frame.size.height+20);
    self.titleBtn.frame = self.imageBtn.frame;

    self.imageBtn.center = self.center;
    self.titleBtn.center = self.center;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [UIView animateWithDuration:0.2 animations:^{
        [self.imageBtn setSelected:selected];
        [self.titleBtn setSelected:selected];
    }];
}

@end