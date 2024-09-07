//
//  SceneDelegate.m
//  EmojiKeyboard
//
//  Created by Jinwoo Kim on 9/7/24.
//

#import "SceneDelegate.h"
#import "ViewController.h"

@interface SceneDelegate ()
@end

@implementation SceneDelegate

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    ViewController *rootViewController = [ViewController new];
    window.rootViewController = rootViewController;
    [rootViewController release];
    self.window = window;
    [window makeKeyAndVisible];
    [window release];
}

@end
