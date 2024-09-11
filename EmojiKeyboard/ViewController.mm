//
//  ViewController.mm
//  EmojiKeyboard
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import "ViewController.h"

@implementation ViewController

- (NSString *)textInputContextIdentifier {
    return @"ABC";
}

- (void)loadView {
    UITextView *textView = [UITextView new];
    textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    self.view = textView;
    [textView release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view becomeFirstResponder];
}

@end
