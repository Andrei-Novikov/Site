//
//  AuthorizationRequest.h
//  Site
//
//  Created by Navigator on 7/10/15.
//  Copyright (c) 2015 OrangeSoft_Brest. All rights reserved.
//

#import "K9BaseRequest.h"

@interface AuthorizationRequest : K9BaseRequest
@property (nonatomic, strong) NSString* login;
@property (nonatomic, strong) NSString* password;
@end
