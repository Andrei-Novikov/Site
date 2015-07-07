//
//  K9XMLParser.m
//
//
//  Created by Sania on 19.11.13.
//  Copyright (c) 2013 Orangesoft. All rights reserved.
//

#import "K9Parser.h"

@interface K9Parser ()
@property (nonatomic, strong) NSXMLParser* m_xmlParser;
@property (nonatomic, strong) NSMutableDictionary* m_data;
@property (nonatomic, strong) NSMutableArray* m_elementNames;
@property (nonatomic, strong) NSMutableArray* m_elementValues;
@end

#pragma mark -

@implementation K9Parser

@dynamic xmlParser;
@dynamic asDictionary;

@synthesize m_xmlParser;
@synthesize m_elementNames;
@synthesize m_elementValues;
@synthesize m_data;

#pragma mark -

+ (K9Parser*)parserWithNSXMLParser:(NSXMLParser*)parser
{
    return [[K9Parser alloc] initWithNSXMLParser:parser];
}

- (id)initWithNSXMLParser:(NSXMLParser*)parser
{
    self = [super init];
    if (self != nil)
    {
        self.xmlParser = parser;
    }
    return self;
}

#pragma mark -

- (NSDictionary*)asDictionary
{
    return self.m_data;
}

- (NSXMLParser*)xmlParser
{
    return m_xmlParser;
}

- (void)setXmlParser:(NSXMLParser*)parser
{
    if (self.m_xmlParser != nil)
    {
        self.m_xmlParser.delegate = nil;
    }
    
    self.m_elementNames = [NSMutableArray array];
    self.m_elementValues = [NSMutableArray array];
    self.m_data = [NSMutableDictionary dictionary];
    self.m_xmlParser = parser;
    self.m_xmlParser.delegate = self;
    [self.m_xmlParser parse];
}

#pragma mark -

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
//    LOG(@"Start %@", elementName);
    id destination = self.m_data;
    for (NSString* name in self.m_elementNames)
    {
        id val = destination[name];
        while ([val isKindOfClass:[NSMutableArray class]])
        {
            val = [val lastObject];
        }
        destination = val;
    }
    id element = destination[elementName];
    if ([element isKindOfClass:[NSMutableDictionary class]])
    {
        NSMutableArray* tmpArray = [NSMutableArray array];
        [tmpArray addObject:element];
        [tmpArray addObject:[NSMutableDictionary dictionary]];
        destination[elementName] = tmpArray;
    }
    else if ([element isKindOfClass:[NSMutableArray class]])
    {
        [(NSMutableArray*)element addObject:[NSMutableDictionary dictionary]];
    }
    else if (element == nil)
    {
        destination[elementName] = [NSMutableDictionary dictionary];
    }
    else
    {
        NSMutableArray* tmpArray = [NSMutableArray array];
        [tmpArray addObject:element];
        [tmpArray addObject:[NSMutableDictionary dictionary]];
        destination[elementName] = tmpArray;
    }
    
    [self.m_elementNames addObject:elementName];
    [self.m_elementValues addObject:[NSMutableString string]];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
//    LOG(@"End %@", elementName);
    [self.m_elementNames removeLastObject];
    if (self.m_elementValues.count > 0)
    {
        id destination = self.m_data;
        for (NSString* name in self.m_elementNames)
        {
            id val = destination[name];
            while ([val isKindOfClass:[NSMutableArray class]])
            {
                val = [val lastObject];
            }
            destination = val;
        }
        id oldVal = destination[elementName];
        if ([oldVal isKindOfClass:[NSMutableDictionary class]])
        {
            NSString* string = [self.m_elementValues lastObject];
            if (string.length > 0)
            {
                NSObject* result = string;
                NSString* testString = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789.-"]];
                if (testString.length == 0)
                {
                    NSRange testRange = [string rangeOfString:@"."];
                    if (testRange.length == 0)
                    {
                        result = [NSNumber numberWithLongLong:string.longLongValue];
                        NSString* testResult = [NSString stringWithFormat:@"%@", result];
                        while (testResult.length < string.length)
                        {
                            testResult = [NSString stringWithFormat:@"0%@", testResult];
                        }
                        if (![string isEqualToString:testResult])
                        {
                            result = string;
                        }
                    }
                    else
                    {
                        result = [NSNumber numberWithDouble:string.doubleValue];
                    }
                }
                else if ([string compare:@"YES" options:NSCaseInsensitiveSearch] == NSOrderedSame || [string compare:@"true" options:NSCaseInsensitiveSearch] == NSOrderedSame)
                {
                    result = @YES;
                }
                else if ([string compare:@"NO" options:NSCaseInsensitiveSearch] == NSOrderedSame || [string compare:@"false" options:NSCaseInsensitiveSearch] == NSOrderedSame)
                {
                    result = @NO;
                }
                destination[elementName] = result;
            }
        }
        else if ([oldVal isKindOfClass:[NSMutableArray class]])
        {
            NSString* string = [self.m_elementValues lastObject];
            if (string.length > 0)
            {
                NSObject* result = string;
                NSString* testString = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789.-"]];
                if (string.length > 0 && testString.length == 0)
                {
                    NSRange testRange = [string rangeOfString:@"."];
                    if (testRange.length == 0)
                    {
                        result = [NSNumber numberWithLongLong:string.longLongValue];
                    }
                    else
                    {
                        result = [NSNumber numberWithDouble:string.doubleValue];
                    }
                }
                else if ([string compare:@"YES" options:NSCaseInsensitiveSearch] == NSOrderedSame || [string compare:@"true" options:NSCaseInsensitiveSearch] == NSOrderedSame)
                {
                    result = @YES;
                }
                else if ([string compare:@"NO" options:NSCaseInsensitiveSearch] == NSOrderedSame || [string compare:@"false" options:NSCaseInsensitiveSearch] == NSOrderedSame)
                {
                    result = @NO;
                }
                [oldVal removeLastObject];
                [oldVal addObject:result];
            }
        }
        [self.m_elementValues removeLastObject];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
//    LOG(@"%@", string);
    
/*    NSString* testString = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789."]];
    if (string.length > 0 && testString.length == 0)
    {
        NSRange testRange = [string rangeOfString:@"."];
        if (testRange.length == 0)
        {
            [self.m_elementValues addObject:[NSNumber numberWithLongLong:string.longLongValue]];
        }
        else
        {
            [self.m_elementValues addObject:[NSNumber numberWithDouble:string.doubleValue]];
        }
    }
    else if ([string compare:@"YES" options:NSCaseInsensitiveSearch] == NSOrderedSame || [string compare:@"true" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        [self.m_elementValues addObject:@YES];
    }
    else if ([string compare:@"NO" options:NSCaseInsensitiveSearch] == NSOrderedSame || [string compare:@"false" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        [self.m_elementValues addObject:@NO];
    }
    else
    {
        [self.m_elementValues addObject:string];
    }*/
    NSMutableString* lastElement = [self.m_elementValues lastObject];
    [lastElement appendString:string];
}

@end
