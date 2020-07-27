//
//  HGSignalHandler.m
//  HGSmallSpace
//
//  Created by plz on 2020/7/23.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

#import "HGSignalHandler.h"
#include <execinfo.h>
#include <libkern/OSAtomic.h>
#import "HGCrashFile.h"

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalException";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

@implementation HGSignalHandler

+(void)saveCreash:(NSString *)exceptionInfo
{

    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    NSString * savePath = [NSString stringWithFormat:@"SigCrash%@.log",timeString];
    
    //写日志保存本地log
    BOOL sucess = [HGCrashFile writeObjectDataToPlist:exceptionInfo fileName:savePath];
    //保存日志需要上传邮件或者服务器
    [[NSUserDefaults standardUserDefaults] setObject:exceptionInfo forKey:@"SigCrashLog"];
    NSLog(@"YES sucess:%d",sucess);
}

// SignalException 堆栈信息转数组格式
+ (NSArray *)backtrace {
    
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int i = 0; i < frames; i++){
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);

    return backtrace;
}

+ (NSString *)jsonValueWithDictionary:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    
    if (!jsonData) {
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

void SignalExceptionHandler(int signal)
{
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal]
     forKey:UncaughtExceptionHandlerSignalKey];
    NSArray *callStack =  [HGSignalHandler backtrace]; //获取signal类型的堆栈信息
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    NSString *reason = [NSString stringWithFormat:NSLocalizedString(@"Signal %d was raised.", nil),signal];
    NSException *exception = [NSException
                              exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                              reason:reason
                              userInfo:userInfo];
    NSString *name =[exception name];
    
    //异常错误报告
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    [dict setValue:name forKey:@"name"];
    [dict setValue:reason forKey:@"reason"];
    [dict setValue:callStack forKey:@"call_stack"];
    
    [HGSignalHandler saveCreash:[HGSignalHandler jsonValueWithDictionary:dict]];
}


void InstallSignalHandler(void)
{
    signal(SIGHUP, SignalExceptionHandler);
    signal(SIGINT, SignalExceptionHandler);
    signal(SIGQUIT, SignalExceptionHandler);
    
    signal(SIGABRT, SignalExceptionHandler);
    signal(SIGILL, SignalExceptionHandler);
    signal(SIGSEGV, SignalExceptionHandler);
    signal(SIGFPE, SignalExceptionHandler);
    signal(SIGBUS, SignalExceptionHandler);
    signal(SIGPIPE, SignalExceptionHandler);
}

@end
