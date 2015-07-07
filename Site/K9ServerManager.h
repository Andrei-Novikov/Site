//
//  K9ServerManager.h
//
//
//  Created by Sania on 03.06.13.
//  Copyright (c) 2013 Orangesoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#import "K9BaseRequest.h"
#import "K9BaseResponse.h"
#import "K9FileRequest.h"


#define SERVER_MANAGER_DEFAULT_TIMEOUT  30.0f
#define ERROR_USER_INFO_KEY @"K9ErrorUserInfo"
#define ERROR_USER_INFO_STATUS_CODE @"K9ErrorUserInfoStatusCode"

typedef enum
{
    ServerManagerRequestType_JSON,
    ServerManagerRequestType_SOAP,
} ServerManagerRequestType;


typedef void (^StartBlock) (NSURLRequest* request);
typedef void (^FinishBlock)(NSURLRequest* request, NSURLResponse* response, NSError* error); //error, response can by nil

@interface K9ServerManager : NSObject <NSXMLParserDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) StartBlock startRequestDelegateBlock;
@property (nonatomic, strong) FinishBlock finishRequestDelegateBlock;

+ (K9ServerManager*)shared;
- (AFHTTPSessionManager*)HTTPsession;

#pragma mark - GET / POST Server Requests
- (NSURLSessionDataTask*)GETrequestWithURL:(NSString*)url requestType:(ServerManagerRequestType)requestType urlParameters:(NSDictionary*)params
                  success:(void (^)(K9BaseResponse* response))success
                  failure:(void (^)(NSError* error))failure;
- (NSURLSessionDataTask*)POSTrequestWithURL:(NSString*)url
               requestType:(ServerManagerRequestType)requestType
                parameters:(NSDictionary*)params
                   success:(void (^)(K9BaseResponse* response))success
                   failure:(void (^)(NSError* error))failure;
- (NSURLSessionDataTask*)POSTrequestWithURL:(NSString*)url
               requestType:(ServerManagerRequestType)requestType
                uploadData:(NSData*)data
                parameters:(NSDictionary*)params
                   success:(void (^)(K9BaseResponse* response))success
                   failure:(void (^)(NSError* error))failure;
- (NSURLSessionDataTask*)PUTrequestWithURL:(NSString*)url
              requestType:(ServerManagerRequestType)requestType
               parameters:(NSDictionary*)params
                  success:(void (^)(K9BaseResponse* response))success
                  failure:(void (^)(NSError* error))failure;
- (NSURLSessionDataTask*)PATCHrequestWithURL:(NSString*)url
                requestType:(ServerManagerRequestType)requestType
                 parameters:(NSDictionary*)params
                    success:(void (^)(K9BaseResponse* response))success
                    failure:(void (^)(NSError* error))failure;
- (NSURLSessionDataTask*)DELETErequestWithURL:(NSString*)url requestType:(ServerManagerRequestType)requestType urlParameters:(NSDictionary*)params
                     success:(void (^)(K9BaseResponse* response))success
                     failure:(void (^)(NSError* error))failure;

+ (NSString*)convertDictionaryToString:(NSDictionary*)srcDictionary leftSymbols:(NSString*)leftSymbols;

+ (BOOL)isNetworkAvailable;

#pragma mark -

- (NSURLSessionDataTask*)getRequest:(id)request requestType:(ServerManagerRequestType)requestType requestRelativeURL:(NSString*)relativeURL responseClass:(Class)responseClass delegate:(void (^)(id response, NSError* error))delegate;
- (NSURLSessionDataTask*)postRequest:(id)request
        requestType:(ServerManagerRequestType)requestType
 requestRelativeURL:(NSString*)relativeURL
         uploadData:(NSData*)data
      responseClass:(Class)responseClass
           delegate:(void (^)(id response, NSError* error))delegate;
- (NSURLSessionDataTask*)putRequest:(id)request
       requestType:(ServerManagerRequestType)requestType
requestRelativeURL:(NSString*)relativeURL
     responseClass:(Class)responseClass
          delegate:(void (^)(id response, NSError* error))delegate;
- (NSURLSessionDataTask*)patchRequest:(id)request
         requestType:(ServerManagerRequestType)requestType
  requestRelativeURL:(NSString*)relativeURL
       responseClass:(Class)responseClass
            delegate:(void (^)(id response, NSError* error))delegate;
- (NSURLSessionDataTask*)deleteRequest:(id)request requestType:(ServerManagerRequestType)requestType requestRelativeURL:(NSString*)relativeURL responseClass:(Class)responseClass delegate:(void (^)(id response, NSError* error))delegate;



- (void)downloadFile:(NSURL*)url progress:(K9DownloadFileProgressBlock)progress completed:(K9DownloadFileFinishBlock)completed;
- (void)downloadFile:(NSURL*)url progress:(K9DownloadFileProgressBlock)progress completed:(K9DownloadFileFinishBlock)completed destDirectory:(NSString*)destDirectory;

@end