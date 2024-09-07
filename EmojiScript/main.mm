//
//  main.mm
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import <CoreData/CoreData.h>
#import "ESArgumentParser.h"
#import "ESEmojiTextFileEnumerator.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSURL * _Nullable emojiSequencesURL = [ESArgumentParser emojiSequencesURL];
        NSURL * _Nullable emojiZwjSequencesURL = [ESArgumentParser emojiZwjSequencesURL];
        
        if (emojiSequencesURL == nil || emojiZwjSequencesURL == nil) {
            NSLog(@"%@", ESArgumentParser.helpMessage);
            return EXIT_FAILURE;
        }
        
        ESEmojiTextFileEnumerator *enumerator = [[ESEmojiTextFileEnumerator alloc] initWithURL:emojiSequencesURL];
        
        for (id foo in enumerator) {
            
        }
        
        return EXIT_SUCCESS;
    }
}
