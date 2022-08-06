//
//  PreferencesController.h
//  PortalHelper
//
//  Created by Ryan Morlok on 11/27/08.
//  Copyright 2008 Morlok Technologies, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const EsPathToLoginsXmlFileKey;
extern NSString * const EsPathToFileExchangeRootKey;
extern NSString * const EsBasePortalUrl;

@interface PreferencesController : NSWindowController {
	IBOutlet NSTextField *pathToLoginsXmlFile;
	IBOutlet NSTextField *pathToFileExchangeRoot;
}

- (IBAction)chooseLoginsXmlFile:(id)sender;
- (IBAction)chooseFileExchangeRoot:(id)sender;

@end
