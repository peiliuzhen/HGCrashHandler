//
//  KvcCrashVC.m
//  HGSmallSpace
//
//  Created by plz on 2020/7/21.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

#import "KvcCrashVC.h"

@interface KvcCrashVCObj : NSObject
@property (nonatomic, strong) NSString *name;
@end
@implementation KvcCrashVCObj
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}
- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}
@end

@interface KvcCrashVC ()
@end
@implementation KvcCrashVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self case1];
}
/**
 场景一：对象不支持KVC
 */
- (void)case1 {
    // reason: '[<NSObject 0x282fe7f90> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key key.'
    NSObject* obj = [[NSObject alloc]init];
    [obj setValue:@"value" forKey:@"key"];
}
/**
 场景二：key为nil
 */
- (void)case2 {
    // reason: '*** -[KvcCrashVCObj setValue:forKey:]: attempt to set a value for a nil key'
    KvcCrashVCObj* obj = [[KvcCrashVCObj alloc]init];
    // value 为nil不会崩溃
    [obj setValue:nil forKey:@"name"];
    // key为nil会崩溃（直接写nil编译器会提示警告，更多时候我们传的是变量）
    [obj setValue:@"value" forKey:nil];
}
/**
 场景三：key不是object的属性产生的crash
 */
- (void)case3 {
    // reason: '[<KvcCrashVCObj 0x2810bfa80> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key falseKey.'
    KvcCrashVCObj* obj = [[KvcCrashVCObj alloc]init];
    [obj setValue:nil forKey:@"falseKey"];
}
@end
