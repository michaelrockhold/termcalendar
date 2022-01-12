//
//  NSObject+EventKitHack.m
//
//  Created by Dirk Scheidt on 23.01.20.
//  Copyright © 2020 Dirk Scheidt. All rights reserved.
//

#import "NSObject+EventKitHack.h"
#import <AppKit/AppKit.h>
#import <EventKit/EventKit.h>

static EKEventStore *store;

@implementation EventKitHack

    // Today this is the only working sollution to get the permissions.
- (EKEventStore*) permCheck {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    store = [[EKEventStore alloc] initWithAccessToEntityTypes:EKEntityMaskReminder+EKEntityMaskEvent];
#pragma clang diagnostic pop
    return store;
}

@end
