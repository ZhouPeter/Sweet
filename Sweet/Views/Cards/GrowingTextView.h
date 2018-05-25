//
//  GrowingTextView.h
//  Fe
//
//  Created by Mario Z. on 2017/5/23.
//  Copyright © 2017年 Fe.Party. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GrowingTextView;
@protocol GrowingTextViewDelegate <UITextViewDelegate>

@optional
- (void)textView:(GrowingTextView *)textView didChangeHeight:(CGFloat)height;

@end

@interface GrowingTextView : UITextView

@property (assign, nonatomic) int maxLength;
@property (assign, nonatomic) CGFloat maxHeight;
@property (assign, nonatomic) BOOL trimWhiteSpaceWhenEndEditing;
@property (strong, nonatomic) NSString *placeHolder;
@property (strong, nonatomic) UIColor *placeHolderColor;
@property (assign, nonatomic) CGFloat placeHolderLeftMargin;

- (CGFloat)currentHeight;

@end
