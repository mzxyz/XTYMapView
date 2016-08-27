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
    return CLLocationCoordinate2DMake(self.info.lat, self.info.lng);
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
        [self addSubview:self.imageBtn];
        self.imageBtn.hidden = YES;
        
        self.titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.titleBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [self.titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
        [self.imageBtn setImage:[UIImage imageNamed:anno.info.imageName] forState:UIControlStateSelected];
        self.imageBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    [self.titleBtn setTitle:anno.info.title forState:UIControlStateNormal];
    
    self.imageBtn.bounds = CGRectZero;
    [self.imageBtn sizeToFit];
    
    self.titleBtn.bounds = CGRectZero;
    [self.titleBtn sizeToFit];
    
    self.imageBtn.frame = CGRectMake(0, 0, 32, 32);
    self.titleBtn.frame = CGRectMake(0, 0, 40, 18);
    self.frame = CGRectMake(0, 0, self.imageBtn.frame.size.width*2, self.imageBtn.frame.size.height);

    self.imageBtn.center = self.center;
    self.titleBtn.center = self.center;
    self.backgroundColor = [UIColor clearColor];
    self.titleBtn.backgroundColor = [UIColor orangeColor];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [UIView animateWithDuration:0.2 animations:^{
        [self.imageBtn setSelected:selected];
        [self.titleBtn setSelected:selected];
        self.imageBtn.hidden = !selected;
        self.titleBtn.hidden = selected;
    }];
}

@end