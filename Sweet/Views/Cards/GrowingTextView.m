//
//  GrowingTextView.m
//  Fe
//
//  Created by Mario Z. on 2017/5/23.
//  Copyright © 2017年 Fe.Party. All rights reserved.
//

#import "GrowingTextView.h"

@interface GrowingTextView ()

@property (weak, nonatomic) NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) NSString *oldText;
@property (assign, nonatomic) CGFloat oldWidth;

@end

@implementation GrowingTextView

#pragma mark - Public

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    if (self = [super initWithFrame:frame textContainer:textContainer]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, 30);
}

- (CGFloat)currentHeight {
    CGSize size = [self sizeThatFits:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
    return self.maxHeight > 0 ? MIN(size.height, self.maxHeight) : size.height;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([self.text isEqualToString:self.oldText] && self.oldWidth == self.bounds.size.width) { return; }
    
    self.oldText = self.text;
    self.oldWidth = self.bounds.size.width;
    
    CGSize size = [self sizeThatFits:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
    CGFloat height = self.maxHeight > 0 ? MIN(size.height, self.maxHeight) : size.height;
    
    if (self.heightConstraint == nil) {
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:height];
        [self addConstraint:self.heightConstraint];
    }
    
    if (ABS(height - self.heightConstraint.constant) > 0.1) {
        self.heightConstraint.constant = height;
        [self scrollRangeToVisible:NSMakeRange(0, 0)];
        if ([self.delegate respondsToSelector:@selector(textView:didChangeHeight:)]) {
            [(id <GrowingTextViewDelegate>)self.delegate textView:self didChangeHeight:height];
        }
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.text.length != 0 || self.placeHolder.length == 0) {
        return;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = self.textAlignment;
    
    CGRect placeHolderRect = CGRectMake(self.textContainerInset.left + self.placeHolderLeftMargin,
                                self.textContainerInset.top,
                                self.frame.size.width - self.textContainerInset.left - self.textContainerInset.right,
                                self.frame.size.height);
    NSMutableDictionary *attributes =
    [@{NSForegroundColorAttributeName: self.placeHolderColor,
      NSParagraphStyleAttributeName: paragraphStyle} mutableCopy];
    if (self.font) {
        [attributes setObject:self.font forKey:NSFontAttributeName];
    }
    [self.placeHolder drawInRect:placeHolderRect withAttributes:attributes];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

- (void)commonInit {
    self.maxHeight = 0;
    self.maxLength = 0;
    self.trimWhiteSpaceWhenEndEditing = YES;
    self.contentMode = UIViewContentModeRedraw;
    self.placeHolderColor = [UIColor colorWithWhite:0.8 alpha:1];
    self.placeHolderLeftMargin = 5;
    [self associateConstraints];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidEndEditing:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:self];
}

- (void)associateConstraints {
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight && constraint.relation == NSLayoutRelationEqual) {
            self.heightConstraint = constraint;
            break;
        }
    }
}

#pragma mark - Setters

- (void)setText:(NSString *)text {
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    [self setNeedsDisplay];
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor {
    _placeHolderColor = placeHolderColor;
    [self setNeedsDisplay];
}

- (void)setPlaceHolderLeftMargin:(CGFloat)placeHolderLeftMargin {
    _placeHolderLeftMargin = placeHolderLeftMargin;
    [self setNeedsDisplay];
}

#pragma mark - Notes

- (void)textDidEndEditing:(NSNotification *)note {
    GrowingTextView *textView = note.object;
    if (![textView isEqual:self]) {
        return;
    }
    self.text = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self setNeedsDisplay];
}

- (void)textDidChange:(NSNotification *)note {
    GrowingTextView *textView = note.object;
    if (![textView isEqual:self]) {
        return;
    }
    if (self.maxLength > 0 && self.text.length > self.maxLength) {
        self.text = [self.text substringToIndex:self.maxLength];
        [self.undoManager removeAllActions];
    }
    [self setNeedsDisplay];
}

@end
