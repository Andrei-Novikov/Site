//
//  AuthData.h
//  Site
//
//  Created by Navigator on 7/17/15.
//  Copyright (c) 2015 OrangeSoft_Brest. All rights reserved.
//

#import "K9BaseResponse.h"

@interface AuthData : K9SerializableObject

@property (nonatomic, strong) NSString* access_token;

@end