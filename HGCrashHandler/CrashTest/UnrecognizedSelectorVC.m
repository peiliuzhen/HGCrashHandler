//
//  UnrecognizedSelectorVC.m
//  HGSmallSpace
//
//  Created by plz on 2020/7/21.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

#import "UnrecognizedSelectorVC.h"
/**
 代理协议
 */
@protocol UnrecognizedSelectorVCDelegate <NSObject>
@optional
- (void)notImplementionFunc;
@end
/**
 测试控制器的代理对象
 */
@interface UnrecognizedSelectorVCObj : NSObject<UnrecognizedSelectorVCDelegate>
@property (nonatomic, strong) NSString *name;
@end
@implementation UnrecognizedSelectorVCObj
@end
/**
 测试控制器
 */
@interface UnrecognizedSelectorVC ()
@property(nonatomic, weak) id<UnrecognizedSelectorVCDelegate> delegate;
@property(nonatomic, copy) NSMutableArray *mutableArray;
@end
@implementation UnrecognizedSelectorVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self case1];
}
/**
 场景一：没有实现代理
 */
- (void)case1 {
    UnrecognizedSelectorVCObj* obj = [[UnrecognizedSelectorVCObj alloc] init];
    self.delegate = obj;
    // 崩溃：reason: '-[UnrecognizedSelectorVCObj notImplementionFunc]: unrecognized selector sent to instance 0x2808047f0'
    [self.delegate notImplementionFunc];
    // 解决办法：应该使用下面的代码
    if ( [self.delegate respondsToSelector:@selector(notImplementionFunc)] ) {
        [self.delegate notImplementionFunc];
    }
}
/**
 场景二：可变属性使用copy修饰
 */
- (void)case2 {
    NSMutableArray* array = [NSMutableArray arrayWithObjects:@1, @2, @3, nil];
    self.mutableArray = array;
    // 崩溃：reason: '-[__NSArrayI addObject:]: unrecognized selector sent to instance 0x281198a50'
    [self.mutableArray addObject:@4];
    // 原因：NSMutableArray经过copy之后变成NSArray
    // @property (nonatomic, copy) NSMutableArray *mArray;
    // 等同于
    // - (void)setMArray:(NSMutableArray *)mArray {
    //    _mArray = mArray.copy;
    //}
    // 解决办法：使用strong修饰或者重写set方法

    // 知识点：集合类对象和非集合类对象的copy与mutableCopy
    // [NSArray copy]                  // 浅复制(新的和原来的是一个array)
    // [NSArray mutableCopy]           // 深复制(array是新的，但是内容还是原来的，内容的指针没有变化)
    // [NSMutableArray copy]           // 深复制(array是新的，但是内容还是原来的，内容的指针没有变化)
    // [NSMutableArray mutableCopy]    // 深复制(array是新的，但是内容还是原来的，内容的指针没有变化)
}
/**
 场景三：低版本系统使用高版本API
 */
- (void)case3 {
    if (@available(iOS 10.0, *)) {
        [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {

        }];
    } else {
        // Fallback on earlier versions
    }
}
@end
