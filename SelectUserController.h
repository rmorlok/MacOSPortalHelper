//
//  SelectUserController.h
//  PortalHelper
//
//  Created by Ryan Morlok on 12/19/08.
//  Copyright 2008 EmergingSoft Corporation. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SelectUserController : NSWindowController {
	IBOutlet NSButton *okButton;
	IBOutlet NSButton *cancelButton;
	IBOutlet NSTextField *descriptionLabel;
	NSArray *portalUsers;
}


- (IBAction)cancel:(id)sender;
- (IBAction)ok:(id)sender;

@end
