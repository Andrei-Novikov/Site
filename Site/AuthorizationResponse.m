//
//  AuthorizationResponse.m
//  Site
//
//  Created by Navigator on 7/10/15.
//  Copyright (c) 2015 OrangeSoft_Brest. All rights reserved.
//

#import "AuthorizationResponse.h"

@implementation AuthorizationResponse
@synthesize success;
@synthesize data;

- (BOOL)customConvertField:(NSString*)key value:(NSObject*)value
{
    if ([key isEqualToString:@"data"])
    {
        if ([value isKindOfClass:[NSDictionary class]])
        {
            self.data = [AuthData create:(NSDictionary*)value];
            return YES;
        }
    }
    
    return NO;
}

@end
