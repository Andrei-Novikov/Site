//
//  AuthorizationResponse.h
//  Site
//
//  Created by Navigator on 7/10/15.
//  Copyright (c) 2015 OrangeSoft_Brest. All rights reserved.
//

#import "K9BaseResponse.h"
#import "AuthData.h"

@interface AuthorizationResponse : K9BaseResponse
@property (nonatomic, strong) NSNumber* success;
@property (nonatomic, strong) AuthData* data;
@end
