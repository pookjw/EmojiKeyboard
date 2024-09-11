//
//  EmojisView.h
//  EmojiKeyboardExtension
//
//  Created by Jinwoo Kim on 9/11/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface EmojisView : UIView
@property (retain, nonatomic, nullable) id<UIKeyInput> keyInput;
@end

NS_ASSUME_NONNULL_END
