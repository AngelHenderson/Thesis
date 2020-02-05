//
//  AISphereView.h
//  AISphereView
//
//  Created by Mayqiyue on 02/02/2018.
//

#import <UIKit/UIKit.h>

@class AISphereView;

@protocol AISphereViewDelegate <NSObject>

@optional

- (void)sphereView:(AISphereView *)sphereView didSelectItem:(UIView *)view;
- (void)sphereView:(AISphereView *)sphereView pushAnimationCompletion:(BOOL)finished;
- (void)sphereView:(AISphereView *)sphereView popAnimationCompletion:(BOOL)finished;

@end

@interface AISphereView : UIView

@property (nonatomic, weak) id<AISphereViewDelegate> delegate;

@property (nonatomic, assign) BOOL    isDashLine;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, copy  ) UIColor *lineColor;
@property (nonatomic, strong) NSArray *dashLineArray;// @[length, gap]

@property (nonatomic, assign) CGFloat scaleFactor; // Default is 1.0

@property (nonatomic, assign) BOOL enableRotateWithGyro;
@property (nonatomic, assign) BOOL enableAutoRotate;

@property (nonatomic, assign, readonly) NSUInteger stackDepth;

@property (nonatomic, strong, readonly) NSArray <__kindof UIView *>*items;

- (void)pushToCenter:(UIView *)centerView withItems:(NSArray <UIView *>*)items;

- (void)popToCenter:(UIView *)centerView withItems:(NSArray <UIView *>*)items;

- (void)timerStart;
- (void)timerPause;
- (void)timerStop;


@end
