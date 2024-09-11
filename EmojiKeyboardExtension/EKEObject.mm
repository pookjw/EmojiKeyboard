//
//  EKEObject.mm
//  EmojiScript
//
//  Created by Jinwoo Kim on 9/11/24.
//

#import "EKEObject.h"
#import <objc/message.h>
#import <objc/runtime.h>
#include <execinfo.h>
#include <dlfcn.h>
#include <cstring>

namespace es_NSProcessInfo {
    namespace arguments {
        NSArray<NSString *> * (*original)(NSProgress *, SEL);
        NSArray<NSString *> * custom(NSProgress *self, SEL _cmd) {
            void *buffer[2];
            int count = backtrace(buffer, 2);
            
            if (count < 2) {
                return original(self, _cmd);
            }
            
            void *addr = buffer[1];
            struct dl_info info;
            assert(dladdr(addr, &info) != 0);
            
            if (std::strcmp(info.dli_sname, "+[_PFRoutines valueForProcessArgument:]") == 0) {
                NSMutableArray<NSString *> *customArguments = [original(self, _cmd) mutableCopy];
                
                NSInteger idx = [customArguments indexOfObject:@"-com.apple.CoreData.ConcurrencyDebug"];
                
                if (idx == NSNotFound) {
                    [customArguments addObjectsFromArray:@[@"-com.apple.CoreData.ConcurrencyDebug", @"1"]];
                } else if (idx + 1 == customArguments.count) {
                    [customArguments addObject:@"1"];
                } else {
                    customArguments[idx + 1] = @"1";
                }
                
                return [customArguments autorelease];
            } else {
                return original(self, _cmd);
            }
        }
        void swizzle() {
            Class targetClass = objc_lookUpClass("_NSSwiftProcessInfo");
            if (targetClass == nullptr) targetClass = NSProcessInfo.class;
            
            Method method = class_getInstanceMethod(targetClass, @selector(arguments));
            original = reinterpret_cast<decltype(original)>(method_getImplementation(method));
            method_setImplementation(method, reinterpret_cast<IMP>(custom));
        }
    }
}

@implementation EKEObject

+ (void)load {
    es_NSProcessInfo::arguments::swizzle();
}

@end
