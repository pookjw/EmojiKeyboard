//
//  main.mm
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import <CoreData/CoreData.h>
#import "ESArgumentParser.h"
#import "ESEmojiToken.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSURL * _Nullable emojiSequencesURL = [ESArgumentParser emojiSequencesURL];
        NSURL * _Nullable emojiZWJSequencesURL = [ESArgumentParser emojiZWJSequencesURL];
        
        if (emojiSequencesURL == nil || emojiSequencesURL == nil) {
            NSLog(@"%@", ESArgumentParser.helpMessage);
            return EXIT_FAILURE;
        }
        
        //
        
        NSArray<ESEmojiToken *> *emojiTokens = [ESEmojiToken emojiTokensFromURL:emojiSequencesURL];
        NSArray<ESEmojiToken *> *emojiZWJSequencesTokens = [ESEmojiToken emojiTokensFromURL:emojiZWJSequencesURL];
        
        //
        
        NSMutableSet<ESEmojiToken *> *tokens = [NSMutableSet new];
        __block NSUInteger count = 0;
        
        for (ESEmojiToken *token in emojiTokens){
            [tokens addObject:token];
//            NSLog(@"%@", token.string);
            count += 1;
        }
        assert(tokens.count == count);
        
        for (ESEmojiToken *token in emojiZWJSequencesTokens){
            [tokens addObject:token];
//            NSLog(@"%@", token.string);
            count += 1;
        }
        
        assert(tokens.count == count);
        
        //
        
        NSDictionary<ESEmojiToken *, NSArray<ESEmojiToken *> *> *emojiTokenReferences = [ESEmojiToken emojiTokenReferencesFromEmojiTokens:[emojiTokens arrayByAddingObjectsFromArray:emojiZWJSequencesTokens]];
        
        [emojiTokenReferences enumerateKeysAndObjectsUsingBlock:^(ESEmojiToken * _Nonnull key, NSArray<ESEmojiToken *> * _Nonnull obj, BOOL * _Nonnull stop) {
            NSLog(@"%@ (%@)", key.string, key.identifier);
            
            [tokens removeObject:key];
            
            [obj enumerateObjectsUsingBlock:^(ESEmojiToken * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"    - %@ (%@)", obj.string, obj.identifier);
                [tokens removeObject:obj];
            }];
            
        }];
        
        assert(tokens.count == 0);
        
        /*
         💑
             - 💑🏻
             - 💑🏼
             - 💑🏽
             - 💑🏾
             - 💑🏿
         
         1F468 200D 2764 FE0F 200D 1F48B 200D 1F468 👨‍❤️‍💋‍👨
         */
        //
        
        return EXIT_SUCCESS;
    }
}
