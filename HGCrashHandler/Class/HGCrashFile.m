//
//  HGCrashFile.m
//  HGSmallSpace
//
//  Created by plz on 2020/7/23.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

#import "HGCrashFile.h"

@implementation HGCrashFile


+ (BOOL)writeObjectDataToPlist:(id)objectData fileName: (NSString *)fileName{
    
    //根据传入的名称创建文件路径
    NSString *stringNamePath = [self pathForName:fileName];
    //写入文件
    return [objectData writeToFile: stringNamePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


+ (id)readObjectFromePlist: (NSString *)fileName{
    //根据传入的名称获取文件路径
    NSString *stringNamePath = [self pathForName:fileName];
    //从文件读取字典数据
    NSString *string = [NSString stringWithContentsOfFile:stringNamePath encoding:NSUTF8StringEncoding error:nil];
    return string;
}

+ (BOOL)removeObjectDataFromePlist: (NSString *)fileName{
    
    //根据传入的名称获取文件路径
    NSString *stringNamePath = [self pathForName:fileName];
    
    //定义文件管理者
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //删除文件
    return  [fileManager removeItemAtPath:stringNamePath error:nil];
}


//文件路径
+ (NSString *)pathForName:(NSString *)fileName{
    
    //创建文件路径
    NSString *documentPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"crash"];

    //根据传入的名称拼接路径
    NSString *savePath = [documentPath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:savePath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return savePath;
}
@end
