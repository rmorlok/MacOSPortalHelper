//
//  AppController.h
//  PortalHelper
//
//  Created by Ryan Morlok on 11/27/08.
//  Copyright 2008 Morlok Technologies, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"
#import "PortalUsersController.h"

@interface AppController : NSObject {
	PreferencesController *preferencesController;
	PortalUsersController *portalUsersController;
}

- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)launchPortalUrl:(id)sender;


@end
