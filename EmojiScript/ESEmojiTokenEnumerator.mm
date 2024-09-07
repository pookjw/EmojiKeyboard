//
//  ESEmojiTokenEnumerator.mm
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import "ESEmojiTokenEnumerator.h"

@interface ESEmojiTokenEnumerator () <NSStreamDelegate> {
    NSInputStream *_inputStream;
    NSMutableArray<NSString *> *_remainingEmojiLines;
    NSString * _processingString;
}
@end

@implementation ESEmojiTokenEnumerator

- (instancetype)initWithURL:(NSURL *)URL {
    if (self = [super init]) {
        _inputStream = [[NSInputStream alloc] initWithURL:URL];
        _inputStream.delegate = self;
        _remainingEmojiLines = [NSMutableArray new];
    }
    
    return self;
}

- (void)dealloc {
    [_inputStream close];
    [_inputStream release];
    [_remainingEmojiLines release];
    [_processingString release];
    [super dealloc];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id _Nullable[])buffer count:(NSUInteger)len {
    assert(len > 0);
    
    NSInputStream *inputStream = _inputStream;
    
    if (state->state == 0) {
        [inputStream open];
        assert(inputStream.hasBytesAvailable);
        
        state->state = 1;
        state->mutationsPtr = reinterpret_cast<unsigned long *>(self);
    }
    
    state->itemsPtr = buffer;
    
    NSMutableArray<NSString *> *remainingEmojiLines = _remainingEmojiLines;
    if (len <= remainingEmojiLines.count) {
        for (NSInteger idx = 0; idx < len; idx++) {
            buffer[idx] = [[remainingEmojiLines[idx] retain] autorelease];
        }
        
        [remainingEmojiLines removeObjectsInRange:NSMakeRange(0, len)];
        
        return len;
    }
    
    NSMutableArray<NSString *> *emojiLines = [[NSMutableArray alloc] initWithCapacity:len];
    assert(remainingEmojiLines.count < len);
    [emojiLines addObjectsFromArray:remainingEmojiLines];
    [remainingEmojiLines removeAllObjects];
    
    while (inputStream.hasBytesAvailable && emojiLines.count < len) @autoreleasepool {
        uint8_t bytes[1024];
        NSInteger readSize = [inputStream read:bytes maxLength:1024];
//        NSString *string = [[NSString alloc] initWithBytes:bytes length:readSize encoding:NSUTF8StringEncoding];
        
        NSMutableString *string = [[NSMutableString alloc] initWithCapacity:readSize];
        for (NSInteger i = 0; i < readSize; i++) {
            [string appendFormat:@"%c", bytes[i]];
        }
        
        assert(string != nil);
        NSArray<NSString *> *components = [string componentsSeparatedByString:@"\n"];
        [string release];
        
        NSUInteger count = components.count;
        assert(count > 0);
        
        NSMutableArray<NSString *> *mutableComponents = [components mutableCopy];
        
        if (_processingString != nil) {
            mutableComponents[0] = [_processingString stringByAppendingString:mutableComponents[0]];
        }
        
        [_processingString release];
        _processingString = [mutableComponents[count - 1] retain];
        [mutableComponents removeLastObject];
        
        for (NSString *component in mutableComponents) {
            if (emojiLines.count < len) {
                [emojiLines addObject:component];
            } else {
                [remainingEmojiLines addObject:component];
            }
        }
        
        [mutableComponents release];
    }
    
    //
    
    NSUInteger emojiLinesCount = emojiLines.count;
    
    for (NSInteger idx = 0; idx < emojiLinesCount; idx++) {
        buffer[idx] = [[emojiLines[idx] retain] autorelease];
    }
    
    [emojiLines release];
    
    if (emojiLinesCount < len) {
        if (_processingString == nil) {
            return 0;
        } else {
            buffer[emojiLinesCount] = [[_processingString retain] autorelease];
            [_processingString release];
            _processingString = nil;
            return emojiLinesCount + 1;
        }
    }
    
    return len;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    abort();
}

@end
