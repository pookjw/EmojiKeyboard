//
//  ViewController.m
//  EmojiKeyboard
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import "ViewController.h"

@implementation ViewController

- (void)loadView {
    UITextView *textView = [UITextView new];
    textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    self.view = textView;
    [textView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view becomeFirstResponder];
}

@end
