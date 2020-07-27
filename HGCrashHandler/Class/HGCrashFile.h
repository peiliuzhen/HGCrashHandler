//
//  HGCrashFile.h
//  HGSmallSpace
//
//  Created by plz on 2020/7/23.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HGCrashFile : NSObject

/**
 *  向plist 文件中写入数据
 */
+ (BOOL)writeObjectDataToPlist:(id)objectData fileName: (NSString *)fileName;

/**
 *  够根据名字读取数据
 */
+ (id)readObjectFromePlist: (NSString *)fileName;

/**
 *  能够根据名字删除数据
 */
+ (BOOL)removeObjectDataFromePlist: (NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
