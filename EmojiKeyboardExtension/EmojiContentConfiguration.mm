//
//  EmojiContentConfiguration.m
//  EmojiKeyboardExtension
//
//  Created by Jinwoo Kim on 9/11/24.
//

#import "EmojiContentConfiguration.h"
#import "EmojiContentView.h"

__attribute__((objc_direct_members))
@interface EmojiContentConfiguration ()
@property (assign, nonatomic, readonly) CGRect initialFrame;
@end

@implementation EmojiContentConfiguration

- (instancetype)initWithInitialFrame:(CGRect)initialFrame emojiHandler:(void (^)(void (^ _Nonnull)(NSManagedObject * _Nullable)))emojiHandler {
    if (self = [super init]) {
        _initialFrame = initialFrame;
        _emojiHandler = [emojiHandler copy];
    }
    
    return self;
}

- (void)dealloc {
    [_emojiHandler release];
    [super dealloc];
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else {
        auto casted = static_cast<EmojiContentConfiguration *>(other);
        return [_emojiHandler isEqual:casted->_emojiHandler];
    }
}

- (id)copyWithZone:(struct _NSZone *)zone {
    id copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        auto casted = static_cast<EmojiContentConfiguration *>(copy);
        casted->_emojiHandler = [_emojiHandler copy];
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
