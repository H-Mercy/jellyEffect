//
//  CuteView.h
//  BJZApp
//
//  Created by rockfintech on 2021/4/7.
//  Copyright © 2021 kedll. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CuteViewDelegate <NSObject>

- (void)backMeWithHeaderCenterY:(CGFloat)centerY;

@end
NS_ASSUME_NONNULL_BEGIN

@interface CuteView : UIView
@property(nonatomic,strong)id <CuteViewDelegate>cuteDelegate;
@property (nonatomic, strong) UIImageView *headerImage;
- (void)handlePanAction:(UIPanGestureRecognizer *)pan;
@end

NS_ASSUME_NONNULL_END
