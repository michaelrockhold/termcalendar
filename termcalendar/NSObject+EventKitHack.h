//
//  NSObject+HelpMeOut.h
//  RemLiEx
//
//  Created by Dirk Scheidt on 23.01.20.
//  Copyright © 2020 Dirk Scheidt. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class EKEventStore;

@interface EventKitHack: NSObject

    - (EKEventStore*) permCheck;

@end

NS_ASSUME_NONNULL_END
