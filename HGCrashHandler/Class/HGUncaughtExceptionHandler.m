//
//  HGUncaughtExceptionHandler.m
//  HGSmallSpace
//
//  Created by plz on 2020/7/23.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

#import "HGUncaughtExceptionHandler.h"
#import "HGCrashFile.h"

@implementation HGUncaughtExceptionHandler

+(void)saveCreash:(NSString *)exceptionInfo {
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    NSString * savePath = [NSString stringWithFormat:@"OCCrash%@.log",timeString];
    
    //写日志保存本地log
    BOOL sucess = [HGCrashFile writeObjectDataToPlist:exceptionInfo fileName:savePath];
    [[NSUserDefaults standardUserDefaults] setObject:savePath forKey:@"OCCrash"];
    NSLog(@"YES sucess:%d",sucess);
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

void HandleException(NSException *exception) {
   
    //异常信息
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];

    //异常错误报告
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    [dict setValue:name forKey:@"name"];
    [dict setValue:reason forKey:@"reason"];
    [dict setValue:callStack forKey:@"call_stack"];
    
    [HGUncaughtExceptionHandler saveCreash:[HGUncaughtExceptionHandler jsonValueWithDictionary:dict]];
    
}

void InstallUncaughtExceptionHandler(void) {
 
    NSSetUncaughtExceptionHandler(&HandleException);
}

@end
