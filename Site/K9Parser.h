//
//  K9XMLParser.h
//
//
//  Created by Sania on 19.11.13.
//  Copyright (c) 2013 Orangesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface K9Parser : NSObject <NSXMLParserDelegate>

+ (K9Parser*)parserWithNSXMLParser:(NSXMLParser*)parser;
- (id)initWithNSXMLParser:(NSXMLParser*)parser;

@property (nonatomic, strong) NSXMLParser* xmlParser;
@property (nonatomic, readonly) NSDictionary* asDictionary;

@end
