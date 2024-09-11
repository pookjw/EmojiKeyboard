//
//  ESArgumentParser.mm
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import "ESArgumentParser.h"

@implementation ESArgumentParser

+ (NSURL *)emojiSequencesURL {
    return [ESArgumentParser URLForFlag:@"--sequences-txt" nilIfDoesNotExist:YES];
}

+ (NSURL *)emojiZWJSequencesURL {
    return [ESArgumentParser URLForFlag:@"--zwj-sequences-txt" nilIfDoesNotExist:YES];
}

+ (NSURL *)outputStoreURL {
    return [ESArgumentParser URLForFlag:@"--output-store" nilIfDoesNotExist:NO];
}

+ (NSURL *)URLForFlag:(NSString *)flag nilIfDoesNotExist:(BOOL)nilIfDoesNotExist __attribute__((objc_direct)) {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSArray<NSString *> *arguments = processInfo.arguments;
    NSInteger flagIndex = [arguments indexOfObject:flag];
    
    if (flagIndex == NSNotFound) return nil;
    if (arguments.count <= flagIndex + 1) return nil;
    
    NSString *path = arguments[flagIndex + 1];
    
    if (nilIfDoesNotExist) {
        BOOL isDirectory;
        if (![NSFileManager.defaultManager fileExistsAtPath:path isDirectory:&isDirectory] || isDirectory) {
            return nil;
        }
    }
    
    return [NSURL fileURLWithPath:path];
}

+ (NSString *)helpMessage {
    return [NSString stringWithFormat:@""
            "--sequences-txt        : path of emoji-sequences.txt file\n"
            "--zwj-sequences-txt    : path of emoji-zwj-sequences.txt file\n"
            "--output-store         : path of output store (sqlite) file\n\n"
            "https://unicode.org/Public/emoji/", nil];
}

@end
