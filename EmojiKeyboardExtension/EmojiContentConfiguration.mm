//
//  EmojiContentConfiguration.m
//  EmojiKeyboardExtension
//
//  Created by Jinwoo Kim on 9/11/24.
//

#import "EmojiContentConfiguration.h"
#import "EmojiContentView.h"

@interface EmojiContentConfiguration ()
@property (assign, nonatomic, readonly) CGRect initialFrame;
@end

@implementation EmojiContentConfiguration

- (instancetype)initWithEmoji:(NSManagedObject *)emoji initialFrame:(CGRect)initialFrame {
    if (self = [super init]) {
        _emoji = [emoji retain];
        _initialFrame = initialFrame;
    }
    
    return self;
}

- (void)dealloc {
    [_emoji release];
    [super dealloc];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    id copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        auto casted = static_cast<EmojiContentConfiguration *>(copy);
        casted->_emoji = [_emoji retain];
        casted->_initialFrame = _initialFrame;
    }
    
    return copy;
}

- (nonnull __kindof UIView<UIContentView> *)makeContentView {
    return [[[EmojiContentView alloc] initWithFrame:self.initialFrame contentConfiguration:self] autorelease];
}

- (nonnull instancetype)updatedConfigurationForState:(nonnull id<UIConfigurationState>)state {
    return self;
}

@end
