//
//  InputBottomView.m
//  XPro
//
//  Created by Mario Z. on 2017/11/15.
//  Copyright © 2017年 Miaozan. All rights reserved.
//

#import "InputBottomView.h"
#import "GrowingTextView.h"
@interface InputBottomView () <GrowingTextViewDelegate>

@property (strong, nonatomic) GrowingTextView *textView;
@property (readwrite, strong, nonatomic) UIButton *sendButton;

@end

@implementation InputBottomView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.maxLength = 1000;
        _placeHolder = @"说点什么";
        [self setupTextView];
        [self updateSendButtonState];
        [self setColor:[UIColor colorWithRed:242 / 255.0 green:242 / 255.0 blue:242 / 255.0 alpha:1]];
    }
    return self;
}

#pragma mark - Public

+ (CGFloat)defaultHeight {
    return 44;
}

+ (CGFloat)verticalInset {
    return 4;
}

- (void)startEditing:(BOOL)isStarted {
    if (isStarted) {
        [self.textView becomeFirstResponder];
    } else {
        self.textView.text = nil;
        [self.textView endEditing:YES];
    }
}

- (void)clear {
    self.textView.text = nil;
}

- (BOOL)isEditing {
    return self.textView.isFirstResponder;
}

- (void)setColor:(UIColor *)color {
    self.backgroundColor = color;
    self.textView.backgroundColor = color;
}

- (void)setTextViewColor:(UIColor *)color {
    self.textView.backgroundColor = color;
}

- (void)setTextViewTextColor:(UIColor *)color{
    self.textView.textColor = color;
}

- (void)setShouldSendNilText:(BOOL)shouldSendNilText {
    _shouldSendNilText = shouldSendNilText;
    [self updateSendButtonState];
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    self.textView.placeHolder = placeHolder;
}

#pragma mark - Actions

- (void)didPressSendButton {
    NSString *text = self.textView.text;
    self.textView.text = nil;
    [self updateSendButtonState];
    [self.delegate inputBottomViewDidPressSendWithText:text];
}

#pragma mark - UIViewGestureRecognizers

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

#pragma mark - Private

- (void)setupTextView {
    self.sendButton = [UIButton new];
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.sendButton setImage:[UIImage imageNamed:@"Send"] forState:UIControlStateNormal];
    [self.sendButton setImage:[UIImage imageNamed:@"SendDisabled"] forState:UIControlStateDisabled];
    [self.sendButton addTarget:self action:@selector(didPressSendButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sendButton];
    [[self.sendButton.widthAnchor constraintEqualToConstant:32] setActive:YES];
    [[self.sendButton.heightAnchor constraintEqualToConstant:32] setActive:YES];
    [[self.sendButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-6] setActive:YES];
    [[self.sendButton.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-6] setActive:YES];
    self.textView = [GrowingTextView new];
    self.textView.translatesAutoresizingMaskIntoConstraints = false;
    self.textView.placeHolder = self.placeHolder;
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.placeHolderColor = [UIColor colorWithRed:155 / 255.0 green:155 / 255.0 blue:155 / 255.0 alpha:1];
    self.textView.placeHolderLeftMargin = 16;
    self.textView.textColor = [UIColor blackColor];
    self.textView.maxHeight = 100;
    self.textView.delegate = self;
    [self addSubview:self.textView];
    [[self.textView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:10] setActive:YES];
    [[self.textView.rightAnchor constraintEqualToAnchor:self.sendButton.leftAnchor constant:-10] setActive:YES];
    [[self.textView.topAnchor constraintEqualToAnchor:self.topAnchor constant:4] setActive:YES];
}

- (void)updateSendButtonState {
    if (self.shouldSendNilText) {
        self.sendButton.enabled = self.textView.text.length <= self.maxLength;
    } else {
        self.sendButton.enabled = self.textView.text.length > 0 && self.textView.text.length <= self.maxLength;
    }
}

#pragma mark - GrowingTextViewDelegate

- (void)textView:(GrowingTextView *)textView didChangeHeight:(CGFloat)height {
    [self.delegate inputBottomViewDidChangeHeight:height];
}

- (void)textViewDidChange:(UITextView *)textView {
    [self updateSendButtonState];
}

@end