//
//  K9BaseResponse.m
//
//
//  Created by Sania on 06.06.13.
//  Copyright (c) 2013 Orangesoft. All rights reserved.
//

#import "K9BaseResponse.h"

@implementation K9BaseResponse

@synthesize statusCode;
@synthesize responseBody;
@synthesize cookies;


- (void)getDictionariesFromArray:(NSArray*)srcArray destDictionary:(NSMutableDictionary*)dstDictionary
{
    for (id item in srcArray)
    {
        if ([item isKindOfClass:[NSDictionary class]])
        {
            [dstDictionary addEntriesFromDictionary:item];
        }
        else if ([item isKindOfClass:[NSArray class]])
        {
            [self getDictionariesFromArray:item destDictionary:dstDictionary];
        }
    }
}

- (void)load:(id)info   // load new, merge with old
{
    [super load:info];
    
    if ([info isKindOfClass:[K9BaseResponse class]])
    {
        NSMutableDictionary* properties = [NSMutableDictionary dictionary];
        K9BaseResponse* baseResponseInfo = (K9BaseResponse*)info;

        self.statusCode = baseResponseInfo.statusCode;
        
        if (baseResponseInfo.responseBody != nil)
        {
            if ([baseResponseInfo.responseBody isKindOfClass:[NSDictionary class]])
            {
                [properties addEntriesFromDictionary:(NSDictionary*)baseResponseInfo.responseBody];
            }
            
            { // JSON
                if ([baseResponseInfo.responseBody isKindOfClass:[NSString class]])
                {
                    NSData* responseData = [(NSString*)baseResponseInfo.responseBody dataUsingEncoding:NSUTF8StringEncoding];
                    NSError* jsonError = nil;
                    id result = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                    if ([result isKindOfClass:[NSDictionary class]])
                    {
                        [properties addEntriesFromDictionary:result];
                    }
                    else if ([result isKindOfClass:[NSArray class]])
                    {
                        [self getDictionariesFromArray:result destDictionary:properties];
                    }
                }
                else if ([baseResponseInfo.responseBody isKindOfClass:[NSData class]])
                {
                    NSError* jsonError = nil;
                    [NSJSONSerialization JSONObjectWithData:(NSData*)baseResponseInfo.responseBody options:0 error:&jsonError];
                }
            }
            
            { // Url parameters
                
            }
            
            { // XML
                
            }
        }
        
        if (baseResponseInfo.cookies != nil)
        {
            for (NSHTTPCookie* cookie in baseResponseInfo.cookies)
            {
                properties[cookie.name] = cookie.value;
            }
        }
        
        [super load:properties];
    }
}

- (NSString*)description // Need for print russian symbols to console
{
    NSDictionary* allValueDictionary = [self serializeToDictionary:NO];
    NSString* convertedString = [K9ServerManager convertDictionaryToString:allValueDictionary leftSymbols:@""];
    return [[super description] stringByAppendingFormat:@" %@", convertedString];
}

@end
