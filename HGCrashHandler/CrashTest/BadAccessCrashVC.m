//
//  BadAccessCrashVC.m
//  HGSmallSpace
//
//  Created by plz on 2020/7/21.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

#import "BadAccessCrashVC.h"
#import <objc/runtime.h>
@interface BadAccessCrashVC (AssociatedObject)
@property (nonatomic, strong) UIView *associateView;
@end
@implementation BadAccessCrashVC (AssociatedObject)
- (void)setAssociateView:(UIView *)associateView {
    objc_setAssociatedObject(self, @selector(associateView), associateView, OBJC_ASSOCIATION_ASSIGN);
    //objc_setAssociatedObject(self, @selector(associateView), associateView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIView *)associateView {
    return objc_getAssociatedObject(self, _cmd);;
}
@end

@interface BadAccessCrashVC ()
@property (nonatomic, copy)                         void(^blcok)(void);
@property (nonatomic, weak) UIView*                 weakView;
@property (nonatomic, unsafe_unretained) UIView*    unSafeView;
@property (nonatomic, assign) UIView*               assignView;
@end
@implementation BadAccessCrashVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self case1];
}
/**
 悬挂指针：访问没有实现的blcok
 */
- (void)case1 {
    self.blcok();
}
/**
 悬挂指针：对象没有被初始化
 */
- (void)case2 {
    UIView* view = [UIView alloc];
    view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view];
}
/**
 悬挂指针：访问的对象已经被释放掉
 */
- (void)case3 {
    {
        UIView* view = [[UIView alloc]init];
        view.backgroundColor = [UIColor blackColor];
        self.weakView = view;
        self.unSafeView = view;
        self.assignView = view;
        self.associateView = view;
    }
    // ARC下weak对象释放后会自动置nil，因此下面的代码不会崩溃
    [self.view addSubview:self.weakView];
    // 野指针场景一：unsafe_unretained修饰的对象释放后，不会自动置nil，变成野指针，因此下面的代码会崩溃
    [self.view addSubview:self.unSafeView];
    // 野指针场景二：应该使用strong/weak修饰的对象，却错误的使用assign修饰，释放后不会自动置nil
    [self.view addSubview:self.assignView];
    // 野指针场景三：给类添加添加关联变量的时候，类似场景二，应该使用OBJC_ASSOCIATION_RETAIN_NONATOMIC修饰，却错误使用OBJC_ASSOCIATION_ASSIGN
    [self.view addSubview:self.associateView];
}
@end

