//
//  GetStateResponse.m
//  Site
//
//  Created by Navigator on 4/29/15.
//  Copyright (c) 2015 OrangeSoft_Brest. All rights reserved.
//

#import "GetStateResponse.h"

@implementation GetStateResponse
@synthesize domain_data;
@synthesize success;

- (BOOL)customConvertField:(NSString*)key value:(NSObject*)value
{
    if ([key isEqualToString:@"data"])
    {
        if ([value isKindOfClass:[NSDictionary class]])
        {
            self.domain_data = [DomainData create:(NSDictionary*)value];
            return YES;
        }
    }
    
    return NO;
}
@end
