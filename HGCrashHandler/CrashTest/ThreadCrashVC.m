//
//  ThreadCrashVC.m
//  HGSmallSpace
//
//  Created by plz on 2020/7/21.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

#import "ThreadCrashVC.h"

@interface ThreadCrashVC ()
@property (nonatomic, strong) NSMutableArray *array;
@end

@implementation ThreadCrashVC
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self case1];
}
/**
 dispatch_group_leave比dispatch_group_enter执行的次数多
 */
- (void)case1 {
    // 崩溃：Thread 1: EXC_BREAKPOINT (code=1, subcode=0x1054f6348)
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_leave(group);
}
/**
 在子线程更新UI
 */
- (void)case2 {
        [NSThread detachNewThreadSelector:@selector(setup) toTarget:self withObject:nil];
}

- (void)setup
{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(100, 150, 100, 50)];
    [self.view addSubview:label];
    label.text = @"Test";
    label.textColor = [UIColor whiteColor];
    
}
/**
 多个线程同时释放一个对象
 */
- (void)case3 {
    // ==================使用信号量同步后不崩溃==================
    {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        __block NSObject *obj = [NSObject new];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            while (YES) {
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                obj = [NSObject new];
                dispatch_semaphore_signal(semaphore);
            }
        });
        while (YES) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            obj = [NSObject new];
            dispatch_semaphore_signal(semaphore);
        }
    }
    // ==================未同步则崩溃==================
    {
        __block NSObject *obj = [NSObject new];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            while (YES) {
                obj = [NSObject new];
            }
        });
        while (YES) {
            obj = [NSObject new];
        }
    }
}
/**
 多线程中的数组扩容、浅复制
 扩容：数组的地址已经改变，报错was mutated while being enumerated
 浅复制：访问僵尸对象，报错EXC_BAD_ACCESS

 // 知识点：集合类对象和非集合类对象的copy与mutableCopy
 // [NSArray copy]                  // 浅复制
 // [NSArray mutableCopy]           // 深复制
 // [NSMutableArray copy]           // 深复制
 // [NSMutableArray mutableCopy]    // 深复制

 参考：
 [Swift数组扩容原理](https://bestswifter.com/swiftarrayappend/)
 [戴仓薯](https://juejin.im/post/5a9aa633518825556a71d9f3)
 */
-(void)case4 {
    {
        NSArray *array = @[@[@"a", @"b"], @[@"c", @"d"]];
        NSArray *copyArray = [array copy];
        NSMutableArray *mCopyArray = [array mutableCopy];
        NSLog(@"array = %p，copyArray = %p，mCopyArray = %p", array, copyArray, mCopyArray);
    }
    {
        NSMutableArray *array = [NSMutableArray arrayWithObjects:[NSMutableString stringWithString:@"a"],@"b",@"c",nil];
        NSArray *copyArray = [array copy];
        NSMutableArray *mCopyArray = [array mutableCopy];
        NSLog(@"array = %p，copyArray = %p，mCopyArray = %p", array, copyArray, mCopyArray);
    }

    dispatch_queue_t queue1 = dispatch_queue_create("queue1", 0);
    dispatch_queue_t queue2 = dispatch_queue_create("queue2", 0);

    NSMutableArray* array = [NSMutableArray array];

    dispatch_async(queue1, ^{
        while (true) {
            if (array.count < 10) {
                [array addObject:@(array.count)];
            } else {
                [array removeAllObjects];
            }
        }
    });

    dispatch_async(queue2, ^{
        while (true) {
            // case 1：数组扩容
            for (NSNumber* number in array) {
              NSLog(@"%@", number);
            }
            // case 2：数组扩容
            NSArray* immutableArray = array;
            for (NSNumber* number in immutableArray) {
              NSLog(@"%@", number);
            }
            // case 3：浅复制 在 [NSArray copy] 的过程，
            // copy 方法内部调用initWithArray:range:copyItems: 时
            // 数组被另一个线程清空，range 不一致导致抛出 exception
            NSArray* immutableArray1 = [array copy];
            for (NSNumber* number in immutableArray1) {
                NSLog(@"%@", number);
            }
            // case 4：浅复制 数组内的对象被其他线程释放，访问僵尸对象
            NSArray* immutableArray2 = [array mutableCopy];
            for (NSNumber* number in immutableArray2) {
                NSLog(@"%@", number);
            }
        }
    });
}
@end
