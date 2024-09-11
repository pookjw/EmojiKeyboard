//
//  EmojiContentView.m
//  EmojiKeyboardExtension
//
//  Created by Jinwoo Kim on 9/11/24.
//

#import "EmojiContentView.h"

@interface EmojiContentView ()
@property (copy, nonatomic) EmojiContentConfiguration *contentConfiguration;
@property (retain, nonatomic, readonly) UILabel *label;
@end

@implementation EmojiContentView
@synthesize label = _label;

- (instancetype)initWithFrame:(CGRect)frame contentConfiguration:(EmojiContentConfiguration *)contentConfiguration {
    if (self = [super init]) {
        UILabel *label = self.label;
        [self addSubview:label];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [label.topAnchor constraintEqualToAnchor:self.topAnchor],
            [label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [label.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
        
        self.contentConfiguration = contentConfiguration;
    }
    
    return self;
}

- (void)dealloc {
    [_contentConfiguration release];
    [_label release];
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UILabel *label = self.label;
    label.font = [label.font fontWithSize:CGRectGetHeight(label.bounds)];
}

- (void)setContentConfiguration:(EmojiContentConfiguration *)contentConfiguration {
    [_contentConfiguration release];
    _contentConfiguration = [contentConfiguration copy];
    
    self.label.text = static_cast<NSString *>([contentConfiguration.emoji valueForKey:@"string"]);
}

- (UILabel *)label {
    if (auto label = _label) return label;
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    
    _label = [label retain];
    return [label autorelease];
}

- (id<UIContentConfiguration>)configuration {
    return self.contentConfiguration;
}

- (void)setConfiguration:(id<UIContentConfiguration>)configuration {
    self.contentConfiguration = static_cast<EmojiContentConfiguration *>(configuration);
}

- (BOOL)supportsConfiguration:(id<UIContentConfiguration>)configuration {
    return [configuration isKindOfClass:EmojiContentConfiguration.class];
}

@end
