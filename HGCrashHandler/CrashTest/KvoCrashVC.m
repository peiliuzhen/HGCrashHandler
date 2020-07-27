//
//  KvoCrashVC.m
//  HGSmallSpace
//
//  Created by plz on 2020/7/21.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

#import "KvoCrashVC.h"

@interface KvoCrashVCObj : NSObject
@property (nonatomic, strong) NSString *name;
@end
@implementation KvoCrashVCObj
@end

@interface KvoCrashVC ()
@property (nonatomic, strong) KvoCrashVCObj *sObj;
@end
@implementation KvoCrashVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.sObj = [[KvoCrashVCObj alloc] init];
//#import <XXShield/XXShield.h>
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [XXShieldSDK registerStabilityWithAbility:(EXXShieldTypeKVO)];
//    });
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self func4];
}
/**
 观察者是局部变量，会崩溃
 */
- (void)func1 {
    // 崩溃日志：An -observeValueForKeyPath:ofObject:change:context: message was received but not handled.
    KvoCrashVCObj* obj = [[KvoCrashVCObj alloc] init];
    [self addObserver:obj
           forKeyPath:@"view"
              options:NSKeyValueObservingOptionNew
              context:nil];
    self.view = [[UIView alloc] init];
}
/**
 被观察者是局部变量，会崩溃
 */
- (void)func2 {
    // 崩溃日志：An -observeValueForKeyPath:ofObject:change:context: message was received but not handled.
    KvoCrashVCObj* obj = [[KvoCrashVCObj alloc] init];
    [obj addObserver:self
          forKeyPath:@"name"
             options:NSKeyValueObservingOptionNew
             context:nil];
    obj.name = @"";
}
/**
 没有实现observeValueForKeyPath:ofObject:changecontext:方法:，会崩溃
 */
- (void)func3 {
    // 崩溃日志：An -observeValueForKeyPath:ofObject:change:context: message was received but not handled.
    [self.sObj addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    self.sObj.name = @"0";
}
/**
 重复移除观察者，会崩溃
 */
- (void)func4 {
    // 崩溃日志：because it is not registered as an observer
    [self.sObj addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    self.sObj.name = @"0";
    [self.sObj removeObserver:self forKeyPath:@"name"];
    [self.sObj removeObserver:self forKeyPath:@"name"];
}
/**
 重复添加观察者，不会崩溃，但是添加多少次，一次改变就会被观察多少次
 */
- (void)func5 {
    [self.sObj addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    self.sObj.name = @"0";
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"keyPath = %@", keyPath);
}
// 总结：KVO有两种崩溃
// 1、because it is not registered as an observer
// 2、An -observeValueForKeyPath:ofObject:change:context: message was received but not handled.
@end
