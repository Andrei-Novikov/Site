//
//  DomainData.h
//  Site
//
//  Created by Navigator on 4/29/15.
//  Copyright (c) 2015 OrangeSoft_Brest. All rights reserved.
//

#import "K9SerializableObject.h"

@interface DomainData : K9SerializableObject
@property (nonatomic, strong) NSNumber* user_enable;
@property (nonatomic, strong) NSNumber* site_enable;

//for error info
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSNumber* code;
@property (nonatomic, strong) NSNumber* status;
@property (nonatomic, strong) NSString* message;

@end
