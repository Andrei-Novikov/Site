//
//  K9FileRequest.h
//  knizniki
//
//  Created by Sania on 18.03.14.
//  Copyright (c) 2014 Orangesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^K9DownloadFileFinishBlock)(NSURL* localURL, NSError* error);
typedef void (^K9DownloadFileProgressBlock)(NSURL* localURL, NSNumber* loadedBytes);

@interface K9FileRequest : NSObject
@property (nonatomic, strong) NSURLRequest* request;
@property (nonatomic, strong) NSURL* destURL;
@property (nonatomic, strong) K9DownloadFileFinishBlock finishBlock;
@property (nonatomic, strong) K9DownloadFileProgressBlock progressBlock;
@property (nonatomic, strong) NSMutableData* responseData;
@end
