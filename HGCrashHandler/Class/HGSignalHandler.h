//
//  HGSignalHandler.h
//  HGSmallSpace
//
//  Created by plz on 2020/7/23.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HGSignalHandler : NSObject

@end

void InstallSignalHandler(void);

NS_ASSUME_NONNULL_END
