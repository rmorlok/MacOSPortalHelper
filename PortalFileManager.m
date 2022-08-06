//
//  PortalFileManager.m
//  PortalHelper
//
//  Created by Ryan Morlok on 12/16/08.
//  Copyright 2008 EmergingSoft Corporation. All rights reserved.
//

#import "PortalFileManager.h"
#import "PreferencesController.h"
#import "Error.h"

@implementation PortalFileManager

- (BOOL)getFolderForUser:(PortalUser*)pu forDate:(NSCalendarDate*)date createDirectoryIfNecessary:(NSString**)outputFolder error:(NSError**)error
{
	NSString *pathToUserFolder;
	
	if( ![self getFolderForUser:pu createDirectoryIfNecessary:&pathToUserFolder error:error] )
		return NO;
	
	//
	// Compute the path for the date
	//
	NSFileManager *fm = [NSFileManager defaultManager];
	
	[date setCalendarFormat:@"%Y%m%d"];
	NSString *formattedDate = [date description];
	NSArray *pathComponents = [NSArray arrayWithObjects:pathToUserFolder, @"download", formattedDate, nil];
	NSString *userPortalDateFolder = [NSString pathWithComponents:pathComponents];
	BOOL isDirectory = NO;
	
	BOOL pathExists = [fm fileExistsAtPath:[userPortalDateFolder stringByExpandingTildeInPath] isDirectory:&isDirectory];
	
	if( pathExists && !isDirectory )
	{
		NSArray *keys   = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,NSLocalizedFailureReasonErrorKey,nil];
		NSArray *values = [NSArray arrayWithObjects:@"Cannot retrieve user portal folder for date because path specifies a file.", @"Portal folder for date is a file.",nil];
		NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
		
		NSError *tmpError = [NSError errorWithDomain:ERROR_DOMAIN code:ERROR_FAILED_CREATE_DATE_PORTAL_DIRECTORY userInfo:dict];
		
		if( error )
			*error = tmpError;
		
		NSLog(@"Cannot go to date for user's portal directory because it is blocked by a file.");
		return NO;
	}
	
	if( !pathExists )
	{
		NSLog(@"Folder for date does not exist.  Creating folder '%@'.", userPortalDateFolder);
		
		NSError *tmpError;
		if( ![fm createDirectoryAtPath:userPortalDateFolder withIntermediateDirectories:YES attributes:nil error:&tmpError] )
		{
			NSArray *keys   = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,NSLocalizedFailureReasonErrorKey,NSUnderlyingErrorKey,nil];
			NSArray *values = [NSArray arrayWithObjects:
							   @"Cannot retrieve user portal folder for date because the directory did not exist and could not be created.", 
							   @"User's portal does not exist and could not be created.",
							   tmpError,
							   nil];
			NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
			
			NSError *noUserError = [NSError errorWithDomain:ERROR_DOMAIN code:ERROR_FAILED_CREATE_DATE_PORTAL_DIRECTORY userInfo:dict];
			
			if( error )
				*error = noUserError;
			
			NSLog(@"Failed to create directory '%@'.", userPortalDateFolder);
			return NO;
		}
	}
	
	// Everything is good.  Give back to the folder
	if( outputFolder )
		*outputFolder = userPortalDateFolder;
	
	return YES;		
}

- (BOOL)getFolderForUser:(PortalUser*)pu createDirectoryIfNecessary:(NSString**)outputFolder error:(NSError**)error
{
	if( nil == pu )
	{
		NSArray *keys   = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,NSLocalizedFailureReasonErrorKey,nil];
		NSArray *values = [NSArray arrayWithObjects:@"Cannot retrieve user portal folder because no user is selected.", @"No user selected.",nil];
		NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
		
		NSError *noUserError = [NSError errorWithDomain:ERROR_DOMAIN code:ERROR_NO_USER_SELECTED userInfo:dict];
		
		if( error )
			*error = noUserError;
		
		NSLog(@"Cannot view folder for user.  Failed to get selected user.");
		return NO;
	}

	NSString *emailAddress = [pu email];
	
	if( nil == emailAddress 
	   || [emailAddress length] <= 0 )
	{
		NSArray *keys   = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,NSLocalizedFailureReasonErrorKey,nil];
		NSArray *values = [NSArray arrayWithObjects:@"Cannot retrieve user portal folder because user does not have email address specified.", @"No email address specified for user.",nil];
		NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
		
		NSError *noUserError = [NSError errorWithDomain:ERROR_DOMAIN code:ERROR_NO_EMAIL_ADDRESS_FOR_USER userInfo:dict];
		
		if( error )
			*error = noUserError;
		
		NSLog(@"Cannot view folder for user.  User does not have email address.");
		return NO;
	}
	
	//
	// Get the root of the file exchange directory
	//
	NSString *pathToRootOfFileExchange = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:EsPathToFileExchangeRootKey];
	
	//
	// Verify the root directory exists
	//
	NSFileManager *fm = [NSFileManager defaultManager];
	
	BOOL isDirectory = NO;
	
	if( nil == pathToRootOfFileExchange
	   || [pathToRootOfFileExchange length] <= 0
	   ||![fm fileExistsAtPath:[pathToRootOfFileExchange stringByExpandingTildeInPath] isDirectory:&isDirectory]
	   || !isDirectory)
	{
		NSArray *keys   = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,NSLocalizedFailureReasonErrorKey,nil];
		NSArray *values = [NSArray arrayWithObjects:@"Cannot retrieve user portal folder because root portal directory is not valid.", @"Invalid root portal directory.",nil];
		NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
		
		NSError *noUserError = [NSError errorWithDomain:ERROR_DOMAIN code:ERROR_INVALID_ROOT_PORTAL_DIRECTORY userInfo:dict];
		
		if( error )
			*error = noUserError;
		
		NSLog(@"Cannot view folder for user '%@'.  File exchange root directory does not exist or is not a directory.", emailAddress);
		return NO;
	}
	
	//
	// Compute the path for the user
	//
	
	NSArray *pathComponents = [NSArray arrayWithObjects:pathToRootOfFileExchange, emailAddress, nil];
	NSString *userPortalFolder = [NSString pathWithComponents:pathComponents];
	
	BOOL pathExists = [fm fileExistsAtPath:[userPortalFolder stringByExpandingTildeInPath] isDirectory:&isDirectory];
	
	if( pathExists && !isDirectory )
	{
		NSArray *keys   = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,NSLocalizedFailureReasonErrorKey,nil];
		NSArray *values = [NSArray arrayWithObjects:@"Cannot retrieve user portal folder because the user's folder name is a file.", @"User's portal directory blocked by file.",nil];
		NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
		
		NSError *noUserError = [NSError errorWithDomain:ERROR_DOMAIN code:ERROR_INVALID_ROOT_PORTAL_DIRECTORY userInfo:dict];
		
		if( error )
			*error = noUserError;
		
		NSLog(@"Cannot go to user's folder because there is a file name interferring with creating a directory.");
		return NO;
	}
	
	if( !pathExists )
	{
		NSLog(@"Folder for user does not currently exist.  Creating folder '%@'.", userPortalFolder);
		
		NSError *tmpError;
		if( ![fm createDirectoryAtPath:userPortalFolder withIntermediateDirectories:YES attributes:nil error:&tmpError] )
		{
			NSArray *keys   = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,NSLocalizedFailureReasonErrorKey,NSUnderlyingErrorKey,nil];
			NSArray *values = [NSArray arrayWithObjects:
							   @"Cannot retrieve user portal folder because the directory did not exist and could not be created.", 
							   @"User's portal does not exist and could not be created.",
							   tmpError,
							   nil];
			NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
			
			NSError *noUserError = [NSError errorWithDomain:ERROR_DOMAIN code:ERROR_FAILED_CREATE_USER_PORTAL_DIRECTORY userInfo:dict];
			
			if( error )
				*error = noUserError;
			
			NSLog(@"Failed to create directory '%@'.", userPortalFolder);
			return NO;
		}
	}
	
	// Everything is good.  Give back to the folder
	if( outputFolder )
		*outputFolder = userPortalFolder;
	
	return YES;	
}

- (BOOL)postFiles:(NSArray*)files forUser:(PortalUser*)pu forDate:(NSCalendarDate*)date error:(NSError**)error
{
	if( 0 == [files count] )
	{
		NSArray *keys   = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,NSLocalizedFailureReasonErrorKey,nil];
		NSArray *values = [NSArray arrayWithObjects:@"No files specified to post for user.", @"No files specified.",nil];
		NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
		
		NSError *noUserError = [NSError errorWithDomain:ERROR_DOMAIN code:ERROR_NO_FILES_SPECIFIED userInfo:dict];
		
		if( error )
			*error = noUserError;
		
		NSLog(@"Cannot post files for user because no files specified.");
		return NO;
	}
	
	NSString *directoryForToday;
	
	if( ![self getFolderForUser:pu forDate:date createDirectoryIfNecessary:&directoryForToday error:error] )
		return NO;
	
	NSFileManager *fm = [NSFileManager defaultManager];
	
	for(NSString *file in files)
	{
		file = [file stringByExpandingTildeInPath];
		
		BOOL isDirectory = NO;
		BOOL fileExists = [fm fileExistsAtPath:file isDirectory:&isDirectory];
		
		if( !fileExists )
		{
			NSArray *keys   = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,NSLocalizedFailureReasonErrorKey,nil];
			NSArray *values = [NSArray arrayWithObjects:
									[NSString stringWithFormat:@"Cannot copy file '%@' because it does not exist.", file],
									[NSString stringWithFormat:@"File '%@' does not exist."],
									nil];
			
			NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
			
			NSError *noUserError = [NSError errorWithDomain:ERROR_DOMAIN code:ERROR_INVALID_FILE_SPECIFIED userInfo:dict];
			
			if( error )
				*error = noUserError;
			
			NSLog(@"Cannot post files for user because file '%@' does not exist.", file);
			return NO;
		}
		
		if( isDirectory )
		{
			NSArray *keys   = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,NSLocalizedFailureReasonErrorKey,nil];
			NSArray *values = [NSArray arrayWithObjects:
							   [NSString stringWithFormat:@"Cannot copy file '%@' because it is a directory.", file],
							   [NSString stringWithFormat:@"File '%@' is a directory."],
							   nil];
			
			NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
			
			NSError *noUserError = [NSError errorWithDomain:ERROR_DOMAIN code:ERROR_INVALID_FILE_SPECIFIED userInfo:dict];
			
			if( error )
				*error = noUserError;
			
			NSLog(@"Cannot post files for user because file '%@' is a directory.", file);
			return NO;
		}
		
		NSString *destAbsolutePath = [directoryForToday stringByAppendingPathComponent:[file lastPathComponent]];
		
		NSLog(@"Copying '%@' to '%@'...", file, destAbsolutePath);
		
		if( ![fm copyItemAtPath:file toPath:destAbsolutePath error:error] )
			return NO;
	}
	
	return YES;
}

@end
