//
//  CollectionCrashVC.m
//  HGSmallSpace
//
//  Created by plz on 2020/7/21.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

#import "CollectionCrashVC.h"

@interface CollectionCrashVC ()
@end
@implementation CollectionCrashVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self case4];
}
/**
 场景一：数组越界
 */
- (void)case1 {
    // reason: '*** -[__NSArrayI objectAtIndex:]: index 4 beyond bounds [0 .. 2]'
    NSArray* array = [[NSArray alloc]initWithObjects:@1, @2, @3, nil];
    NSNumber* number = [array objectAtIndex:4];
    NSLog(@"number = %@", number);
}
/**
 场景二：向数组中添加nil元素
 */
- (void)case2 {
    // reason: '*** -[__NSArrayM insertObject:atIndex:]: object cannot be nil'
    NSMutableArray* array = [[NSMutableArray alloc]initWithObjects:@1, @2, @3, nil];
    [array addObject:nil];
}
/**
 场景三：数组遍历的时候使用错误的方式移除元素
 */
- (void)case3 {
    NSMutableArray<NSNumber*>* array = [NSMutableArray array];
    [array addObject:@1];
    [array addObject:@2];
    [array addObject:@3];
    [array addObject:@4];
    // 不崩溃
    [array enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.integerValue == 1) {
            [array removeObject:obj];
        }
    }];
    // 崩溃，reason: '*** Collection <__NSArrayM: 0x2829946f0> was mutated while being enumerated.'
    for (NSNumber* obj in array) {
        if (obj.integerValue == 2) {
            [array removeObject:obj];
        }
    }
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //        self.view.backgroundColor = [UIColor blueColor];
    //    });
}
/**
 场景四：使用setObject:forKey:向字典中添加value为nil的键值对，推荐使用KVC的setValue:nil forKey:
 */
- (void)case4 {
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:@1 forKey:@1];
    // 不崩溃：value为nil，只会移除key对应的键值对
    [dictionary setValue:nil forKey:@1];
    // 崩溃：reason: '*** -[__NSDictionaryM setObject:forKey:]: object cannot be nil (key: 1)'
    [dictionary setObject:nil forKey:@1];
}
@end
