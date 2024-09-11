//
//  KeyboardViewController.m
//  EmojiKeyboardExtension
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import "KeyboardViewController.h"
#import "EmojisView.h"
#import <objc/message.h>
#import <objc/runtime.h>

OBJC_EXPORT id objc_msgSendSuper2(void);

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

- (void)_setTextDocumentProxy:(id<UITextDocumentProxy>)textDocumentProxy {
    objc_super superInfo = { self, [self class] };
    reinterpret_cast<void (*)(objc_super *, SEL, id)>(objc_msgSendSuper2)(&superInfo, _cmd, textDocumentProxy);
    
    self.emojisView.keyInput = self.textDocumentProxy;
}

@end
