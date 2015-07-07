//
//  K9ServerManager.m
//
//
//  Created by Sania on 03.06.13.
//  Copyright (c) 2013 Orangesoft. All rights reserved.
//

#import "K9ServerManager.h"
#import "K9Parser.h"
#import "K9ServerConsts.h"
#import <AFNetworking/AFURLRequestSerialization.h>
#import <AFNetworking/AFURLResponseSerialization.h>


#define VALUE_BLOCK     @"Block"
#define VALUE_ERROR     @"Error"
#define VALUE_USER_UUID @"UserUUID"
#define VALUE_USER_ID   @"UserID"
#define VALUE_TOKEN     @"Token"
#define VALUE_REQUEST   @"Request"
#define VALUE_RESPONSE  @"Response"


@interface K9ServerManager()
@property (nonatomic, retain) AFHTTPSessionManager* m_HTTPsession;
@property (nonatomic, strong) NSMutableArray* m_fileRequests;
@property (nonatomic, strong) NSRecursiveLock* m_fileRequestsLock;
@end

@implementation K9ServerManager

@synthesize m_HTTPsession;
@synthesize m_fileRequests;
@synthesize m_fileRequestsLock;

@synthesize startRequestDelegateBlock;
@synthesize finishRequestDelegateBlock;

#ifdef SERVER_LOGGING_ENABLE 
    #if (SERVER_LOGGING_ENABLE) 
        #define SERVER_LOG(_CALLER_, _URL_, _PARAMETERS_, _MESSAGE_, _COOKIES_, _STATUS_CODE_) LOG(@"\nCallback:\t%@\nURL:\t\t%@\nParameters:\n%@\nResponse:\n%@\nCookies: %@\nStatus Code: %ld", (_CALLER_), (_URL_), (_PARAMETERS_), (_MESSAGE_), (_COOKIES_), (long)(_STATUS_CODE_))
    #else 
        #define SERVER_LOG(...)
    #endif 
#else 
    #define SERVER_LOG(...)
#endif

+ (K9ServerManager*)shared
{
    static K9ServerManager* __instance = nil;
    static dispatch_once_t __onceToken;
    dispatch_once(&__onceToken, ^
                  {
                      __instance = [[K9ServerManager alloc] init];
                  });
    return __instance;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.m_fileRequests = [NSMutableArray array];
        self.m_fileRequestsLock = [NSRecursiveLock new];
        
        NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                             diskCapacity:20 * 1024 * 1024
                                                                 diskPath:nil];
        [NSURLCache setSharedURLCache:URLCache];
    }
    return self;
}

- (AFHTTPSessionManager*)HTTPsession
{
    if (self.m_HTTPsession == nil)
    {
        self.m_HTTPsession = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:SERVER_BASE_URL]];
//        self.m_HTTPsession.parameterEncoding = AFSOAPParameterEncoding;
        self.m_HTTPsession.requestSerializer = [AFJSONRequestSerializer serializer];
        self.m_HTTPsession.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [self.m_HTTPsession.reachabilityManager startMonitoring];
    }
    
    return self.m_HTTPsession;
}

#pragma mark - BASE Requests

- (NSURLSessionDataTask*)PerformRequest:(NSMutableURLRequest*)request
           requestType:(ServerManagerRequestType)requestType
               success:(void (^)(K9BaseResponse* response))success
               failure:(void (^)(NSError* error))failure
{
    //Start request
    if (self.startRequestDelegateBlock != nil)
    {
        self.startRequestDelegateBlock(request);
    }
    
#ifdef SERVER_LOGGING_ENABLE
#if (SERVER_LOGGING_ENABLE)
    NSArray* stack = [NSThread callStackSymbols];
    NSString* caller = @" ";
    if (stack.count > 3)
    {
        caller = stack[3];
    }
    NSRange range = [caller rangeOfString:@"["];
    if (caller.length > range.location)
        caller = [caller substringFromIndex:range.location];
    else
        caller = @" ";
    range = [caller rangeOfString:@"]"];
    if (caller.length > range.location + 1)
        caller = [caller substringToIndex:range.location + 1];
    else
        caller = @" ";
#endif
#endif
    
    switch (requestType)
    {
        case ServerManagerRequestType_JSON:
        {
            if (![self.HTTPsession.requestSerializer isKindOfClass:[AFJSONRequestSerializer class]])
            {
                self.HTTPsession.requestSerializer = [AFJSONRequestSerializer serializer];
            }
            
            if (![self.HTTPsession.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]])
            {
                self.HTTPsession.responseSerializer = [AFJSONResponseSerializer serializer];
            }
        }
            break;
            
        case ServerManagerRequestType_SOAP:
        {
            if (![self.HTTPsession.requestSerializer isKindOfClass:[AFPropertyListRequestSerializer class]])
            {
                self.HTTPsession.requestSerializer = [AFPropertyListRequestSerializer serializer];
            }
            
            if (![self.HTTPsession.responseSerializer isKindOfClass:[AFXMLParserResponseSerializer class]])
            {
                self.HTTPsession.responseSerializer = [AFXMLParserResponseSerializer serializer];
            }
        }
            break;
            
        default:
            break;
    }
    __block NSURLSessionDataTask *task = [self.HTTPsession dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error)
    {
        NSArray* allCookies = @[];
        NSInteger statusCode = 200;
        if ([response isKindOfClass:[NSHTTPURLResponse class]])
        {
            allCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[(NSHTTPURLResponse*)response allHeaderFields] forURL:request.URL];
            statusCode = [(NSHTTPURLResponse*)response statusCode];
        }
        SERVER_LOG(caller, request.URL, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding], responseObject, allCookies, statusCode);
        
        if (error)
        {// Finish request
            BOOL isErrorPrinted = NO;
            
            for (NSString* key in error.userInfo)
            {
                NSString* srcString = (NSString*)error.userInfo[key];
                NSString* destString = srcString;
                if ([error.userInfo[key] isKindOfClass:[NSString class]])
                {
                    NSData* srcData = [NSData dataWithBytes:[srcString cStringUsingEncoding:NSUTF8StringEncoding] length:[srcString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
                    NSError* jsonError = nil;
                    NSObject* dest = [NSJSONSerialization JSONObjectWithData:srcData options:0 error:&jsonError];
                    if (jsonError == nil)
                    {
                        destString = (NSString*)dest;
                        for (NSString* subKey in (NSDictionary*)dest)
                        {
                            if ([((NSDictionary*)dest)[subKey] isKindOfClass:[NSArray class]])
                            {
                                NSArray* logArray = (NSArray*)((NSDictionary*)dest)[subKey];
                                for (NSObject* item in logArray)
                                {
                                    LOG(@"!!!!! %@: %@", subKey, item);
                                    isErrorPrinted = YES;
                                }
                            }
                        }
                    }
                }
            }

            if (responseObject)
            {
                if ([responseObject isKindOfClass:[NSDictionary class]])
                {
                    LOG(@"!!!!! %@", [K9ServerManager convertDictionaryToString:responseObject leftSymbols:@""]);
                
                    NSMutableDictionary* tmpUserInfo = error.userInfo.mutableCopy;
                    tmpUserInfo[ERROR_USER_INFO_KEY] = responseObject;
                    tmpUserInfo[ERROR_USER_INFO_STATUS_CODE] = @(statusCode);
                    error = [NSError errorWithDomain:error.domain code:error.code userInfo:tmpUserInfo];
                    
                    isErrorPrinted = YES;
                }
            }
            
            if (!isErrorPrinted)
            {
                LOG(@"%@", error);
            }
            if (self.finishRequestDelegateBlock != nil)
            {
                self.finishRequestDelegateBlock(request, response, error);
            }
            
            if (failure)
            {
                failure(error);
            }
        }
        else
        { // Finish request            
            if (self.finishRequestDelegateBlock != nil)
            {
                self.finishRequestDelegateBlock(request, response, nil);
            }
            
            if (success != nil)
            {
                K9BaseResponse* response = [K9BaseResponse new];
                response.statusCode = statusCode;
                response.cookies = allCookies;
                response.responseBody = responseObject;
                success(response);
            }
        }
    }];
    
    [task resume];
    return task;
}

- (NSMutableURLRequest*)requestWithMethod:(NSString*)method url:(NSString*)url parameters:(NSDictionary*)params
{
    AFHTTPSessionManager* session = [self HTTPsession];
    return [session.requestSerializer requestWithMethod:method
                                              URLString:[[NSURL URLWithString:url relativeToURL:session.baseURL] absoluteString]
                                             parameters:params error:nil];
}

- (NSURLSessionDataTask*)GETrequestWithURL:(NSString*)url requestType:(ServerManagerRequestType)requestType urlParameters:(NSDictionary*)params success:(void (^)(K9BaseResponse* response))success failure:(void (^)(NSError* error))failure
{
    NSMutableURLRequest* request = [self requestWithMethod:@"GET" url:url parameters:params];
    return [self PerformRequest:request requestType:requestType success:success failure:failure];
}

- (NSURLSessionDataTask*)POSTrequestWithURL:(NSString*)url
               requestType:(ServerManagerRequestType)requestType
                parameters:(NSDictionary*)params
                   success:(void (^)(K9BaseResponse* response))success
                   failure:(void (^)(NSError* error))failure
{
    return [self POSTrequestWithURL:url requestType:requestType uploadData:nil parameters:params success:success failure:failure];
}

- (NSURLSessionDataTask*)POSTrequestWithURL:(NSString*)url
               requestType:(ServerManagerRequestType)requestType
                uploadData:(NSData*)data
                parameters:(NSDictionary*)params
                   success:(void (^)(K9BaseResponse* response))success
                   failure:(void (^)(NSError* error))failure
{
    NSMutableURLRequest* request = nil;
    switch (requestType)
    {
        case ServerManagerRequestType_JSON:
            if (!data)
            {
                request = [self requestWithMethod:@"POST" url:url parameters:params];
            }
            else
            {
                AFHTTPSessionManager* session = [self HTTPsession];
                request = [session.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                          URLString:[[NSURL URLWithString:url relativeToURL:session.baseURL] absoluteString]
                                                                         parameters:params
                                                          constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
                                                              [formData appendPartWithFileData:data name:@"image" fileName:@"image.jpg" mimeType:@"image/jpeg"];
                                                            }
                                                                              error:nil];
            }
            break;
            
        case ServerManagerRequestType_SOAP:
            request = [self requestWithMethod:@"POST" url:url parameters:params];
            [request setValue:url forHTTPHeaderField:@"SOAPAction"];
            break;
            
        default:
            break;
    }
    return [self PerformRequest:request requestType:requestType success:success failure:failure];
}

- (NSURLSessionDataTask*)PUTrequestWithURL:(NSString*)url
               requestType:(ServerManagerRequestType)requestType
                parameters:(NSDictionary*)params
                   success:(void (^)(K9BaseResponse* response))success
                   failure:(void (^)(NSError* error))failure
{
    NSMutableURLRequest* request = nil;
    switch (requestType)
    {
        case ServerManagerRequestType_JSON:
            request = [self requestWithMethod:@"PUT" url:url parameters:params];
            break;
            
        case ServerManagerRequestType_SOAP:
            request = [self requestWithMethod:@"PUT" url:url parameters:params];
            [request setValue:url forHTTPHeaderField:@"SOAPAction"];
            break;
            
        default:
            break;
    }
    return [self PerformRequest:request requestType:requestType success:success failure:failure];
}

- (NSURLSessionDataTask*)PATCHrequestWithURL:(NSString*)url
                requestType:(ServerManagerRequestType)requestType
                 parameters:(NSDictionary*)params
                    success:(void (^)(K9BaseResponse* response))success
                    failure:(void (^)(NSError* error))failure
{
    NSMutableURLRequest* request = nil;
    switch (requestType)
    {
        case ServerManagerRequestType_JSON:
            request = [self requestWithMethod:@"PATCH" url:url parameters:params];
            break;
            
        case ServerManagerRequestType_SOAP:
            request = [self requestWithMethod:@"PATCH" url:url parameters:params];
            [request setValue:url forHTTPHeaderField:@"SOAPAction"];
            break;
            
        default:
            break;
    }
    return [self PerformRequest:request requestType:requestType success:success failure:failure];
}


- (NSURLSessionDataTask*)DELETErequestWithURL:(NSString*)url requestType:(ServerManagerRequestType)requestType urlParameters:(NSDictionary*)params success:(void (^)(K9BaseResponse* response))success failure:(void (^)(NSError* error))failure
{
    NSMutableURLRequest* request = nil;
    switch (requestType)
    {
        case ServerManagerRequestType_JSON:
            request = [self requestWithMethod:@"DELETE" url:url parameters:params];
            break;
            
        case ServerManagerRequestType_SOAP:
            request = [self requestWithMethod:@"DELETE" url:url parameters:params];
            [request setValue:url forHTTPHeaderField:@"SOAPAction"];
            break;
            
        default:
            break;
    }
    return [self PerformRequest:request requestType:requestType success:success failure:failure];
}

#pragma mark - Server Requests Engine
// Perform in background
// Return result to main thread


- (void)callBlockWithParameters:(NSDictionary*)params
{
    id block = [params valueForKey:VALUE_BLOCK];
    if (block)
    {
        id value = [params valueForKey:VALUE_RESPONSE];
        NSError* error = [params valueForKey:VALUE_ERROR];
        ((void (^)(id, NSError*))block)(value, error);
    }
}

- (NSURLSessionDataTask*)getRequest:(id)request requestType:(ServerManagerRequestType)requestType requestRelativeURL:(NSString*)relativeURL responseClass:(Class)responseClass delegate:(void (^)(id response, NSError* error))delegate
{
    if (request == nil || [request isKindOfClass:[K9BaseRequest class]])
    {
        NSDictionary* urlParams = [request serializeToDictionary];
        return [self GETrequestWithURL:relativeURL requestType:requestType urlParameters:(urlParams.allKeys.count > 0 ? urlParams : nil)
                         success:^(id response)
         {
             void (^parser)(id, NSError*) = ^(id response, NSError* error){
                 if (delegate != nil)
                 {
                     if (response != nil)
                     {
                         [responseClass create:response completed:^(id object) {
                             ((void (^)(id response, NSError* error))delegate)(object, error);
                         }];
                     }
                     else
                     {
                         if (error == nil)
                         {
                             error = [NSError errorWithDomain:@"Can't PARSE response" code:-1 userInfo:response];
                         }
                         ((void (^)(id response, NSError* error))delegate)(nil, error);
                     }
                 }
             };
             NSDictionary* params = @{VALUE_BLOCK:parser, VALUE_RESPONSE:response};
             [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
         }
                         failure:^(NSError* error){
                             if (delegate != nil)
                             {
                                 NSDictionary* params = @{VALUE_BLOCK:delegate, VALUE_ERROR:error};
                                 [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
                             }
                         }];
    }
    else
    {
        return [self PerformRequest:request requestType:requestType success:^(K9BaseResponse *response) {
            NSDictionary* params = @{VALUE_BLOCK:delegate, VALUE_RESPONSE:response};
            [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
        } failure:^(NSError *error) {
            NSDictionary* params = @{VALUE_BLOCK:delegate, VALUE_ERROR:error};
            [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
        }];
    }
}

- (NSURLSessionDataTask*)postRequest:(id)request
        requestType:(ServerManagerRequestType)requestType
 requestRelativeURL:(NSString*)relativeURL
         uploadData:(NSData*)data
      responseClass:(Class)responseClass
           delegate:(void (^)(id response, NSError* error))delegate
{
    if (request == nil || [request isKindOfClass:[K9BaseRequest class]])
    {
        return [self POSTrequestWithURL:relativeURL requestType:requestType uploadData:data parameters:[request serializeToDictionary]
            success:^(id response)
                {
                    void (^parser)(id, NSError*) = ^(id response, NSError* error){
                        if (delegate != nil)
                        {
                            if (response != nil)
                            {
                                switch (requestType)
                                {
                                    case ServerManagerRequestType_JSON:
                                    {
                                        [responseClass create:response completed:^(id object){
                                            ((void (^)(id response, NSError* error))delegate)(object, error);
                                        }];
                                    }
                                        break;
                                        
                                    case ServerManagerRequestType_SOAP:
                                    {
                                        K9BaseResponse* soapResponse = (K9BaseResponse*)response;
                                        NSXMLParser* xmlParser = (NSXMLParser*)soapResponse.responseBody;
                                        K9Parser* soapParser = [K9Parser parserWithNSXMLParser:xmlParser];
                                        NSDictionary* soapResult = [self cleanSOAP:soapParser.asDictionary];
                                        [responseClass create:soapResult completed:^(id object){
                                            ((void (^)(id response, NSError* error))delegate)(object, error);
                                        }];
                                    }
                                        break;
                                        
                                    default:
                                        break;
                                }
                            }
                            else
                            {
                                if (error == nil)
                                {
                                    error = [NSError errorWithDomain:@"Can't PARSE response" code:-1 userInfo:response];
                                }
                                ((void (^)(id response, NSError* error))delegate)(nil, error);
                            }
                        }
                    };
                    NSDictionary* params = @{VALUE_BLOCK:parser, VALUE_RESPONSE:response};
                    [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
                }
             failure:^(NSError* error){
                 if (delegate != nil)
                 {
                     NSDictionary* params = @{VALUE_BLOCK:delegate, VALUE_ERROR:error};
                     [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
                 }
             }];
    }
    else
    {
        return [self PerformRequest:request requestType:requestType success:^(K9BaseResponse *response) {
            NSDictionary* params = @{VALUE_BLOCK:delegate, VALUE_RESPONSE:response};
            [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
        } failure:^(NSError *error) {
            NSDictionary* params = @{VALUE_BLOCK:delegate, VALUE_ERROR:error};
            [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
        }];
    }
}

- (NSURLSessionDataTask*)putRequest:(id)request
        requestType:(ServerManagerRequestType)requestType
 requestRelativeURL:(NSString*)relativeURL
      responseClass:(Class)responseClass
           delegate:(void (^)(id response, NSError* error))delegate
{
    if (request == nil || [request isKindOfClass:[K9BaseRequest class]])
    {
        return [self PUTrequestWithURL:relativeURL requestType:requestType parameters:[request serializeToDictionary]
                         success:^(id response)
         {
             void (^parser)(id, NSError*) = ^(id response, NSError* error){
                 if (delegate != nil)
                 {
                     if (response != nil)
                     {
                         switch (requestType)
                         {
                             case ServerManagerRequestType_JSON:
                             {
                                 [responseClass create:response completed:^(id object){
                                     ((void (^)(id response, NSError* error))delegate)(object, error);
                                 }];
                             }
                                 break;
                                 
                             case ServerManagerRequestType_SOAP:
                             {
                                 K9BaseResponse* soapResponse = (K9BaseResponse*)response;
                                 NSXMLParser* xmlParser = (NSXMLParser*)soapResponse.responseBody;
                                 K9Parser* soapParser = [K9Parser parserWithNSXMLParser:xmlParser];
                                 NSDictionary* soapResult = [self cleanSOAP:soapParser.asDictionary];
                                 [responseClass create:soapResult completed:^(id object){
                                     ((void (^)(id response, NSError* error))delegate)(object, error);
                                 }];
                             }
                                 break;
                                 
                             default:
                                 break;
                         }
                     }
                     else
                     {
                         if (error == nil)
                         {
                             error = [NSError errorWithDomain:@"Can't PARSE response" code:-1 userInfo:response];
                         }
                         ((void (^)(id response, NSError* error))delegate)(nil, error);
                     }
                 }
             };
             NSDictionary* params = @{VALUE_BLOCK:parser, VALUE_RESPONSE:response};
             [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
         }
                         failure:^(NSError* error){
                             if (delegate != nil)
                             {
                                 NSDictionary* params = @{VALUE_BLOCK:delegate, VALUE_ERROR:error};
                                 [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
                             }
                         }];
    }
    else
    {
        return [self PerformRequest:request requestType:requestType success:^(K9BaseResponse *response) {
            NSDictionary* params = @{VALUE_BLOCK:delegate, VALUE_RESPONSE:response};
            [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
        } failure:^(NSError *error) {
            NSDictionary* params = @{VALUE_BLOCK:delegate, VALUE_ERROR:error};
            [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
        }];
    }
}

- (NSURLSessionDataTask*)patchRequest:(id)request
       requestType:(ServerManagerRequestType)requestType
requestRelativeURL:(NSString*)relativeURL
     responseClass:(Class)responseClass
          delegate:(void (^)(id response, NSError* error))delegate
{
    if (request == nil || [request isKindOfClass:[K9BaseRequest class]])
    {
        return [self PATCHrequestWithURL:relativeURL requestType:requestType parameters:[request serializeToDictionary]
                        success:^(id response)
         {
             void (^parser)(id, NSError*) = ^(id response, NSError* error){
                 if (delegate != nil)
                 {
                     if (response != nil)
                     {
                         switch (requestType)
                         {
                             case ServerManagerRequestType_JSON:
                             {
                                 [responseClass create:response completed:^(id object){
                                     ((void (^)(id response, NSError* error))delegate)(object, error);
                                 }];
                             }
                                 break;
                                 
                             case ServerManagerRequestType_SOAP:
                             {
                                 K9BaseResponse* soapResponse = (K9BaseResponse*)response;
                                 NSXMLParser* xmlParser = (NSXMLParser*)soapResponse.responseBody;
                                 K9Parser* soapParser = [K9Parser parserWithNSXMLParser:xmlParser];
                                 NSDictionary* soapResult = [self cleanSOAP:soapParser.asDictionary];
                                 [responseClass create:soapResult completed:^(id object){
                                     ((void (^)(id response, NSError* error))delegate)(object, error);
                                 }];
                             }
                                 break;
                                 
                             default:
                                 break;
                         }
                     }
                     else
                     {
                         if (error == nil)
                         {
                             error = [NSError errorWithDomain:@"Can't PARSE response" code:-1 userInfo:response];
                         }
                         ((void (^)(id response, NSError* error))delegate)(nil, error);
                     }
                 }
             };
             NSDictionary* params = @{VALUE_BLOCK:parser, VALUE_RESPONSE:response};
             [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
         }
                        failure:^(NSError* error){
                            if (delegate != nil)
                            {
                                NSDictionary* params = @{VALUE_BLOCK:delegate, VALUE_ERROR:error};
                                [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
                            }
                        }];
    }
    else
    {
        return [self PerformRequest:request requestType:requestType success:^(K9BaseResponse *response) {
            NSDictionary* params = @{VALUE_BLOCK:delegate, VALUE_RESPONSE:response};
            [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
        } failure:^(NSError *error) {
            NSDictionary* params = @{VALUE_BLOCK:delegate, VALUE_ERROR:error};
            [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
        }];
    }
}

- (NSDictionary*)findSOAPBodyInArray:(NSArray*)array
{
    for (id val in array)
    {
        if ([val isKindOfClass:[NSDictionary class]])
        {
            id result = [self findSOAPBodyInDictionary:val];
            if (result != nil)
            {
                return result;
            }
        }
        else if ([val isKindOfClass:[NSArray class]])
        {
            id result = [self findSOAPBodyInArray:val];
            if (result != nil)
            {
                return result;
            }
        }
    }
    return nil;
}

- (NSDictionary*)findSOAPBodyInDictionary:(NSDictionary*)dictionary
{
    for (NSString* key in dictionary.allKeys)
    {
        NSRange range = [key rangeOfString:@"Body" options:NSCaseInsensitiveSearch];
        if (range.length > 0)
        {
            return dictionary[key];
        }
        id val = dictionary[key];
        if ([val isKindOfClass:[NSDictionary class]])
        {
            id result = [self findSOAPBodyInDictionary:val];
            if (result != nil)
            {
                return result;
            }
        }
        else if ([val isKindOfClass:[NSArray class]])
        {
            id result = [self findSOAPBodyInArray:val];
            if (result != nil)
            {
                return result;
            }
        }
    }
    return nil;
}

- (NSMutableArray*)cleanSOAPArray:(NSArray*)array
{
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:array.count];
    
    for (id val in array)
    {
        if ([val isKindOfClass:[NSArray class]])
        {
            id res = [self cleanSOAPArray:val];
            if (res != nil)
            {
                [result addObject:res];
            }
        }
        else if ([val isKindOfClass:[NSDictionary class]])
        {
            id res = [self cleanSOAPDictionary:val];
            if (res != nil)
            {
                [result addObject:res];
            }
        }
        else
        {
            [result addObject:val];
        }
    }
    
    return result;
}

- (NSMutableDictionary*)cleanSOAPDictionary:(NSDictionary*)dictionary
{
    if (dictionary != nil && dictionary.allKeys.count > 0)
    {
        NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:dictionary.count];
        for (NSString* key in dictionary.allKeys)
        {
            NSArray* componets = [key componentsSeparatedByString:@":"];
            id val = dictionary[key];
            if ([val isKindOfClass:[NSDictionary class]])
            {
                NSMutableDictionary* tmpResult = [self cleanSOAPDictionary:val];
                if (tmpResult != nil)
                {
                    result[[componets lastObject]] = tmpResult;
                }
            }
            else if ([val isKindOfClass:[NSArray class]])
            {
                result[[componets lastObject]] = [self cleanSOAPArray:val];
            }
            else
            {
                result[[componets lastObject]] = val;
            }
        }
        return result;
    }
    return nil;
}

- (NSDictionary*)cleanSOAP:(NSDictionary*)dictionary
{
    NSDictionary* bodyDictionary = [self findSOAPBodyInDictionary:dictionary];

    return [self cleanSOAPDictionary:bodyDictionary];
}

- (void)deleteRequest:(id)request
          requestType:(ServerManagerRequestType)requestType
   requestRelativeURL:(NSString*)relativeURL
        responseClass:(Class)responseClass
             delegate:(void (^)(id response, NSError* error))delegate
{
    if (request == nil || [request isKindOfClass:[K9BaseRequest class]])
    {
        [self DELETErequestWithURL:relativeURL requestType:requestType urlParameters:[request serializeToDictionary]
                        success:^(id response)
         {
             void (^parser)(id, NSError*) = ^(id response, NSError* error){
                 if (delegate != nil)
                 {
                     if (response != nil)
                     {
                         [responseClass create:response completed:^(id object){
                             ((void (^)(id response, NSError* error))delegate)(object, error);
                         }];
                     }
                     else
                     {
                         if (error == nil)
                         {
                             error = [NSError errorWithDomain:@"Can't PARSE response" code:-1 userInfo:response];
                         }
                         ((void (^)(id response, NSError* error))delegate)(nil, error);
                     }
                 }
             };
             NSDictionary* params = @{VALUE_BLOCK:parser, VALUE_RESPONSE:response};
             [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
         }
                        failure:^(NSError* error){
                            if (delegate != nil)
                            {
                                NSDictionary* params = @{VALUE_BLOCK:delegate, VALUE_ERROR:error};
                                [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
                            }
                        }];
    }
    else
    {
        [self PerformRequest:request requestType:requestType success:^(K9BaseResponse *response) {
            NSDictionary* params = @{VALUE_BLOCK:delegate, VALUE_RESPONSE:response};
            [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
        } failure:^(NSError *error) {
            NSDictionary* params = @{VALUE_BLOCK:delegate, VALUE_ERROR:error};
            [self performSelectorOnMainThread:@selector(callBlockWithParameters:) withObject:params waitUntilDone:NO];
        }];
    }
}

+ (BOOL)isNetworkAvailable
{
    AFHTTPSessionManager* httpSession = [[K9ServerManager shared] HTTPsession];
    return (httpSession.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi ||
            httpSession.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN);
}

+ (NSString*)convertArrayToString:(NSArray*)srcArray leftSymbols:(NSString*)leftSymbols
{
    NSString* result = [leftSymbols stringByAppendingString:@"\n[\n"];
    for (id value in srcArray)
    {
        if ([value isKindOfClass:[NSDictionary class]])
        {
            result = [result stringByAppendingFormat:@"\t%@%@", leftSymbols, [K9ServerManager convertDictionaryToString:value leftSymbols:[leftSymbols stringByAppendingString:@"\t"]]];
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            result = [result stringByAppendingFormat:@"\t%@%@", leftSymbols, [K9ServerManager convertArrayToString:value leftSymbols:[leftSymbols stringByAppendingString:@"\t"]]];
        }
        else if ([value isKindOfClass:[NSNumber class]])
        {
            result = [result stringByAppendingFormat:@"\t%@%@,\n", leftSymbols, value];
        }
        else
        {
            result = [result stringByAppendingFormat:@"\t%@\"%@\",\n", leftSymbols, value];
        }
    }
    result = [result stringByAppendingFormat:@"%@];\n", leftSymbols];
    return result;
}

+ (NSString*)convertDictionaryToString:(NSDictionary*)srcDictionary leftSymbols:(NSString*)leftSymbols
{
    NSString* result = [@"\n" stringByAppendingString:[leftSymbols stringByAppendingString:@"{\n"]];
    for (NSString* key in srcDictionary.allKeys)
    {
        id value = srcDictionary[key];
        
        if ([value isKindOfClass:[NSDictionary class]])
        {
            result = [result stringByAppendingFormat:@"\t%@\"%@\" = %@", leftSymbols, key, [K9ServerManager convertDictionaryToString:value leftSymbols:[leftSymbols stringByAppendingString:@"\t"]]];
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            result = [result stringByAppendingFormat:@"\t%@\"%@\" = %@", leftSymbols, key, [K9ServerManager convertArrayToString:value leftSymbols:[leftSymbols stringByAppendingString:@"\t"]]];
        }
        else if ([value isKindOfClass:[NSNumber class]])
        {
            result = [result stringByAppendingFormat:@"\t%@\"%@\" = %@;\n", leftSymbols, key, value];
        }
        else
        {
            result = [result stringByAppendingFormat:@"\t%@\"%@\" = \"%@\";\n", leftSymbols, key, value];
        }
    }
    result = [result stringByAppendingFormat:@"%@};\n", leftSymbols];
    return result;
}



#pragma mark - Download

- (void)downloadFile:(NSURL*)url progress:(K9DownloadFileProgressBlock)progress completed:(K9DownloadFileFinishBlock)completed
{
    [self downloadFile:url progress:progress completed:completed destDirectory:nil];
}

- (void)downloadFile:(NSURL*)url progress:(K9DownloadFileProgressBlock)progress completed:(K9DownloadFileFinishBlock)completed destDirectory:(NSString*)destDirectory
{
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData//NSURLRequestReturnCacheDataElseLoad
                                         timeoutInterval:SERVER_MANAGER_DEFAULT_TIMEOUT];
    __block K9FileRequest* requestInfo = [K9FileRequest new];
    requestInfo.request = request;
    requestInfo.progressBlock = progress;
    requestInfo.finishBlock = completed;
    if (destDirectory)
    {
        requestInfo.destURL = [CACHES_DIRECTORY URLByAppendingPathComponent:destDirectory];
    }
    else
    {
        requestInfo.destURL = CACHES_DIRECTORY;
    }
    
    __block NSProgress* tmpProgress = nil;
    
    __block NSURLSessionDownloadTask *task = [[K9ServerManager shared].HTTPsession downloadTaskWithRequest:request progress:&tmpProgress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        BOOL isDirectory = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:requestInfo.destURL.absoluteString isDirectory:&isDirectory])
        {
            NSError* error = nil;
            [[NSFileManager defaultManager] createDirectoryAtURL:requestInfo.destURL withIntermediateDirectories:YES attributes:nil error:&error];
            if (!error)
            {
                return [requestInfo.destURL URLByAppendingPathComponent:[K9ServerProvider fileNameFromURL:url.absoluteString]];
            }
        }
        return [CACHES_DIRECTORY URLByAppendingPathComponent:[K9ServerProvider fileNameFromURL:url.absoluteString]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (!error)
        {
            if (requestInfo.finishBlock)
            {
                requestInfo.finishBlock(filePath, error);
            }
        }
    }];
    


    if (tmpProgress)
    {
        [tmpProgress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionInitial context:nil];
        [tmpProgress setUserInfoObject:requestInfo forKey:@"RequestInfo"];
    }

    [task resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    NSProgress* progress = (NSProgress*)object;
    K9FileRequest* requestInfo = progress.userInfo[@"RequestInfo"];
        
    if ([requestInfo isKindOfClass:[K9FileRequest class]] && requestInfo.progressBlock)
    {
        requestInfo.progressBlock([requestInfo.destURL URLByAppendingPathComponent:[K9ServerProvider fileNameFromURL:requestInfo.request.URL.absoluteString]], @(progress.completedUnitCount));
    }
}

@end
