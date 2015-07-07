//
//  K9BaseResponse.h
//
//
//  Created by Sania on 06.06.13.
//  Copyright (c) 2013 Orangesoft. All rights reserved.
//

#import "K9SerializableObject.h"


@interface K9BaseResponse : K9SerializableObject

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSObject* responseBody;
@property (nonatomic, strong) NSArray* cookies;
@property (nonatomic, strong) NSNumber* Success;

@end
