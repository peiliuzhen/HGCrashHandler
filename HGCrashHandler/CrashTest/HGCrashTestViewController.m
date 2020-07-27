//
//  HGCrashTestViewController.m
//  HGSmallSpace
//
//  Created by plz on 2020/7/21.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

#import "HGCrashTestViewController.h"
#import "UnrecognizedSelectorVC.h"
#import "KvcCrashVC.h"
#import "BadAccessCrashVC.h"
#import "KvoCrashVC.h"
#import "CollectionCrashVC.h"
#import "ThreadCrashVC.h"

@interface HGCrashTestViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView * tableView;
@property(nonatomic, strong) NSMutableArray * dataArray;

@end

@implementation HGCrashTestViewController

#pragma mark - life cyle 1、控制器生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Crash 测试"];
    [self.view addSubview:self.tableView];
    
    NSArray *tmpArray =[NSArray arrayWithObjects:
                        @"找不到方法的实现unrecognized selector sent to instance",
                        @"KVC造成的crash",
                        @"访问了不该访问的内存导致崩溃 EXC_BAD_ACCESS",
                        @"KVO引起的崩溃",
                        @"集合类相关崩溃",
                        @"线程执行非法指令导致崩溃 EXC_BAD_INSTRUCTION",
                        @"后台返回NSNull导致的崩溃", nil];
    
    self.dataArray = [NSMutableArray arrayWithArray:tmpArray];
    [self.tableView reloadData];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

#pragma mark - 2、不同业务处理之间的方法以

#pragma mark - Network 3、网络请求

#pragma mark - Action Event 4、响应事件

#pragma mark - Call back 5、回调事件

#pragma mark - Delegate 6、代理、数据源
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"identifier"];
        cell.textLabel.text=[self.dataArray objectAtIndex:indexPath.row];
        cell.textLabel.textColor=UIColor.blackColor;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
                UnrecognizedSelectorVC *vc = [[UnrecognizedSelectorVC alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        case 1:{
            KvcCrashVC *vc = [[KvcCrashVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:{
            BadAccessCrashVC *vc = [[BadAccessCrashVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];

        }
            break;
        case 3:{
            KvoCrashVC *vc = [[KvoCrashVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];

        }
            break;
        
        case 4:{
            CollectionCrashVC *vc = [[CollectionCrashVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
            break;
        case 5:{
            ThreadCrashVC *vc = [[ThreadCrashVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];

        }
        break;
        
        case 6:{
            // reason: '-[NSNull integerValue]: unrecognized selector sent to instance 0x2098f99b0'
            NSNull *nullStr = [[NSNull alloc] init];
            NSMutableDictionary* dic = [NSMutableDictionary dictionary];
            [dic setObject:nullStr forKey:@"key"];
            NSNumber* number = [dic valueForKey:@"key"];
            NSInteger test = [number integerValue];
        }
            break;
        
        default:
            break;
    }
   
}

#pragma mark - interface 7、UI处理

#pragma mark - lazy loading 8、懒加载

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
