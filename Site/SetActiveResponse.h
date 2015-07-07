//
//  SetActiveResponse.h
//  Site
//
//  Created by Navigator on 4/29/15.
//  Copyright (c) 2015 OrangeSoft_Brest. All rights reserved.
//

#import "K9BaseResponse.h"
#import "DomainData.h"

@interface SetActiveResponse : K9BaseResponse

@property (nonatomic, strong) DomainData* domain_data;
@property (nonatomic, strong) NSNumber* success;

@end
