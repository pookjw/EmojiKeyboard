//
//  ESTextLineEnumerator.m
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/7/24.
//

#define USE_STACK_POINTER 1

#import "ESTextLineEnumerator.h"
#if USE_STACK_POINTER
#include <alloca.h>
#endif

@interface ESTextLineEnumerator () <NSStreamDelegate> {
    NSInputStream *_inputStream;
    NSMutableArray<NSString *> *_remainingEmojiLines;
    uint8_t *_unprocessedBytes;
    size_t _unprocessesBytesCount;
#if USE_STACK_POINTER
    BOOL _unprocessedBytesStack;
#endif
}
@end

@implementation ESTextLineEnumerator

- (instancetype)initWithURL:(NSURL *)URL {
    if (self = [super init]) {
        NSInputStream *inputStream = [[NSInputStream alloc] initWithURL:URL];
        inputStream.delegate = self;
        
        _inputStream = inputStream;
        _remainingEmojiLines = [NSMutableArray new];
    }
    
    return self;
}

- (void)dealloc {
    [_inputStream close];
    [_inputStream release];
    [_remainingEmojiLines release];
    
#if USE_STACK_POINTER
    if (_unprocessedBytes != NULL && !_unprocessedBytesStack) {
        free(_unprocessedBytes);
    }
#else
    if (_unprocessedBytes != NULL) {
        free(_unprocessedBytes);
    }
#endif
    
    [super dealloc];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id _Nullable[])buffer count:(NSUInteger)len {
    assert(len > 0);
    
    NSInputStream *inputStream = _inputStream;
    
    if (state->state == 0) {
        [inputStream open];
        assert(inputStream.hasBytesAvailable);
        
        state->state = 1;
        state->mutationsPtr = (unsigned long *)self;
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
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        
        uint8_t bytes[1024];
        NSInteger readSize = [inputStream read:bytes maxLength:1024];
        
        NSString *string;
        if (readSize <= 0) {
            assert(_unprocessedBytes != NULL);
            string = [[NSString alloc] initWithBytes:_unprocessedBytes length:_unprocessesBytesCount encoding:NSUTF8StringEncoding];
            
#if USE_STACK_POINTER
            if (!_unprocessedBytesStack) {
                free(_unprocessedBytes);
            }
#else
            free(_unprocessedBytes);
#endif
            
            _unprocessedBytes = NULL;
            _unprocessesBytesCount = 0;
#if USE_STACK_POINTER
            _unprocessedBytesStack = NO;
#endif
        } else {
            NSInteger lastNewlineIndex = NSNotFound;
            for (NSInteger idx = readSize - 1; idx >= 0; idx--) {
                if (bytes[idx] == '\n') {
                    lastNewlineIndex = idx;
                    break;
                }
            }
            
            if (lastNewlineIndex == NSNotFound) {
                // \n이 없으면
                // - 일단 _unprocessedBytes로 넘기고 continue 해야함. line 하나가 너무 길면 잘리며 char 배열이 잘려서 원치 않는 결과가 나옴 (기존에 _unprocessedBytes이 이미 있다면 합쳐야함)
                // - readSize가 예상보다 작으면 그 문자열을 바로 string으로 해야함 (이전 _unprocessedBytes과 합쳐서). 마지막 loop일 것.
                if (readSize < 128) {
                    if (_unprocessedBytes == NULL) {
                        string = [[NSString alloc] initWithBytes:bytes length:readSize encoding:NSUTF8StringEncoding];
                        assert(string != nil);
                    } else {
#if USE_STACK_POINTER
                        uint8_t *newBytes = (uint8_t *)alloca((_unprocessesBytesCount + readSize) * sizeof(uint8_t));
#else
                        uint8_t *newBytes = (uint8_t *)malloc((_unprocessesBytesCount + readSize) * sizeof(uint8_t));
#endif
                        memcpy(newBytes, _unprocessedBytes, _unprocessesBytesCount * sizeof(uint8_t));
                        memcpy(newBytes + _unprocessesBytesCount, bytes, readSize * sizeof(uint8_t));
                        string = [[NSString alloc] initWithBytes:newBytes length:_unprocessesBytesCount + readSize encoding:NSUTF8StringEncoding];
                        assert(string != nil);
                        
#if !USE_STACK_POINTER
                        free(newBytes);
#endif
                        
#if USE_STACK_POINTER
                        if (!_unprocessedBytesStack) {
                            free(_unprocessedBytes);
                        }
#else
                        free(_unprocessedBytes);
#endif
                        
                        _unprocessedBytes = NULL;
                        _unprocessesBytesCount = 0;
                        
#if USE_STACK_POINTER
                        _unprocessedBytesStack = NO;
#endif
                    }
                } else {
#if USE_STACK_POINTER
                    uint8_t *newBytes = (uint8_t *)alloca((_unprocessesBytesCount + readSize) * sizeof(uint8_t));
#else
                    uint8_t *newBytes = (uint8_t *)malloc((_unprocessesBytesCount + readSize) * sizeof(uint8_t));
#endif
                    memcpy(newBytes, _unprocessedBytes, _unprocessesBytesCount * sizeof(uint8_t));
                    memcpy(newBytes + _unprocessesBytesCount, bytes, readSize * sizeof(uint8_t));
                    
#if USE_STACK_POINTER
                    if (!_unprocessedBytesStack) {
                        free(_unprocessedBytes);
                    }
#else
                    free(_unprocessedBytes);
#endif
                    
                    _unprocessedBytes = newBytes;
                    _unprocessesBytesCount = _unprocessesBytesCount + readSize;
#if USE_STACK_POINTER
                    _unprocessedBytesStack = YES;
#endif
                    continue;
                }
            } else {
                if (_unprocessedBytes == NULL) {
                    string = [[NSString alloc] initWithBytes:bytes length:lastNewlineIndex encoding:NSUTF8StringEncoding];
                    assert(string != nil);
                } else {
#if USE_STACK_POINTER
                    uint8_t *newBytes = (uint8_t *)alloca((_unprocessesBytesCount + lastNewlineIndex) * sizeof(uint8_t));
#else
                    uint8_t *newBytes = (uint8_t *)malloc((_unprocessesBytesCount + lastNewlineIndex) * sizeof(uint8_t));
#endif
                    memcpy(newBytes, _unprocessedBytes, _unprocessesBytesCount * sizeof(uint8_t));
                    
#if USE_STACK_POINTER
                    if (!_unprocessedBytesStack) {
                        free(_unprocessedBytes);
                    }
#else
                    free(_unprocessedBytes);
#endif
                    
                    memcpy(newBytes + _unprocessesBytesCount, bytes, lastNewlineIndex * sizeof(uint8_t));
                    string = [[NSString alloc] initWithBytes:newBytes length:_unprocessesBytesCount + lastNewlineIndex encoding:NSUTF8StringEncoding];
                    assert(string != nil);
#if !USE_STACK_POINTER
                    free(newBytes);
#endif
                }
                
                // - 1 및 + 1은 발견한 \n을 제외한다.
                
#if USE_STACK_POINTER
                _unprocessedBytes = (uint8_t *)alloca((readSize - lastNewlineIndex - 1) * sizeof(uint8_t));
#else
                _unprocessedBytes = (uint8_t *)malloc((readSize - lastNewlineIndex - 1) * sizeof(uint8_t));
#endif
                memcpy(_unprocessedBytes, bytes + lastNewlineIndex + 1, (readSize - lastNewlineIndex - 1) * sizeof(uint8_t));
                _unprocessesBytesCount = readSize - lastNewlineIndex - 1;
                
#if USE_STACK_POINTER
                _unprocessedBytesStack = YES;
#endif
            }
        }
        
        NSArray<NSString *> *components = [string componentsSeparatedByString:@"\n"];
        [string release];
        
        NSUInteger count = components.count;
        assert(count > 0);
        
        NSMutableArray<NSString *> *mutableComponents = [components mutableCopy];
        
        for (NSString *component in mutableComponents) {
            if (emojiLines.count < len) {
                [emojiLines addObject:component];
            } else {
                [remainingEmojiLines addObject:component];
            }
        }
        
        [mutableComponents release];
        [pool release];
    }
    
#if USE_STACK_POINTER
    if (_unprocessedBytesStack) {
        void *newHeapBytes = malloc(sizeof(uint8_t) * _unprocessesBytesCount);
        memcpy(newHeapBytes, _unprocessedBytes, sizeof(uint8_t) * _unprocessesBytesCount);
        _unprocessedBytes = newHeapBytes;
        _unprocessedBytesStack = NO;
    }
#endif
    
    //
    
    NSUInteger emojiLinesCount = emojiLines.count;
    
    for (NSInteger idx = 0; idx < emojiLinesCount; idx++) {
        buffer[idx] = [[emojiLines[idx] retain] autorelease];
    }
    
    [emojiLines release];
    
    if (emojiLinesCount < len) {
        [inputStream close];
        return emojiLinesCount;
    }
    
    return len;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
}

@end
