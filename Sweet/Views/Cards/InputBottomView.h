//
//  InputBottomView.h
//  XPro
//
//  Created by Mario Z. on 2017/11/15.
//  Copyright © 2017年 Miaozan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol InputBottomViewDelegate

- (void)inputBottomViewDidChangeHeight:(CGFloat)height;
- (void)inputBottomViewDidPressSendWithText:(NSString * _Nullable)text;

@end

@interface InputBottomView : UIView

@property (weak, nonatomic) id <InputBottomViewDelegate> _Nullable  delegate;
@property (assign, nonatomic)NSInteger maxLength;
@property (readonly, nonatomic) UIButton *sendButton;
@property (assign, nonatomic) BOOL shouldSendNilText;
@property (strong, nonatomic) NSString *placeHolder;

+ (CGFloat)defaultHeight;
+ (CGFloat)verticalInset;

- (void)startEditing:(BOOL)isStarted;
- (void)clear;
- (void)setColor:(UIColor *)color;
- (void)setTextViewColor:(UIColor *)color;
- (void)setTextViewTextColor:(UIColor *)color;
- (BOOL)isEditing;

@end

NS_ASSUME_NONNULL_END
