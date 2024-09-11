//
//  KeyboardViewController.m
//  EmojiKeyboardExtension
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import "KeyboardViewController.h"
#import "EmojisView.h"

@interface KeyboardViewController ()
@property (retain, nonatomic, readonly) EmojisView *emojisView;
@end

@implementation KeyboardViewController
@synthesize emojisView = _emojisView;

- (void)dealloc {
    [_emojisView release];
    [super dealloc];
}

- (void)loadView {
    self.view = self.emojisView;
}

- (EmojisView *)emojisView {
    if (auto emojisView = _emojisView) return emojisView;
    
    EmojisView *emojisView = [EmojisView new];
    emojisView.keyInput = self.textDocumentProxy;
    
    _emojisView = [emojisView retain];
    return [emojisView autorelease];
}

@end
