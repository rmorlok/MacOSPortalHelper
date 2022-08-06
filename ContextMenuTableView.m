//
//  ContextMenuTableView.m
//  PortalHelper
//
//  Created by Ryan Morlok on 12/6/08.
//  Copyright 2008 Morlok Technologies, Inc. All rights reserved.
//

#import "ContextMenuTableView.h"


@implementation ContextMenuTableView

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSLog(@"Context menu requested for table view.");
	
	// Get the row for which the context menu was requested
	int row = [self rowAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
	
	if( row < 0 || row >= [self numberOfRows] )
		return nil;
	
	// Make sure the row is selected
	[self selectRow:row	byExtendingSelection:false];
	
	return [self menu];
}

@end
