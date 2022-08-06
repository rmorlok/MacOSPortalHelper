//
//  AppDelegate.h
//  PortalHelper
//
//  Created by Ryan Morlok on 12/16/08.
//  Copyright 2008 EmergingSoft Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PortalUsersController.h"

@interface AppDelegate : NSObject {
	IBOutlet PortalUsersController *portalUsersController;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filename;
- (void)showPortalUsersWindow:(id)sender;

@end
