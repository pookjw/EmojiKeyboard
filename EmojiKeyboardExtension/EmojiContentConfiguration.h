//
//  EmojiContentConfiguration.h
//  EmojiKeyboardExtension
//
//  Created by Jinwoo Kim on 9/11/24.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmojiContentConfiguration : NSObject <UIContentConfiguration>
@property (retain, nonatomic, readonly, nullable) NSManagedObject *emoji;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithEmoji:(NSManagedObject * _Nullable)emoji initialFrame:(CGRect)initialFrame;
@end

NS_ASSUME_NONNULL_END
