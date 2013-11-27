//
//  NSXMLParser+Laconic.m
//  DailyPhoto
//
//  Created by Антон Буков on 27.11.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import "NSXMLParser+Laconic.h"

@interface NSXMLParserLaconicDelegate : NSObject<NSXMLParserDelegate>
@property (strong, nonatomic) NSMutableDictionary *rootNode;
@property (strong, atomic) NSMutableDictionary *currentNode;
@end

@implementation NSXMLParserLaconicDelegate

- (NSMutableDictionary *)rootNode {
    if (_rootNode == nil)
        _rootNode = [NSMutableDictionary dictionary];
    return _rootNode;
}

- (id)init {
    if (self = [super init]) {
        self.rootNode[@"name"] = @"RootNode";
        self.rootNode[@"childs"] = [NSMutableArray array];
        self.currentNode = self.rootNode;
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSMutableDictionary * newNode = [@{
       @"parentNode":self.currentNode,
       @"name":elementName,
       @"attributes":attributeDict,
       @"childs":[NSMutableArray array]
       } mutableCopy];
    
    [self.currentNode[@"childs"] addObject:newNode];
    
    self.currentNode = newNode;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    self.currentNode[@"content"] = string;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    self.currentNode = self.currentNode[@"parentNode"];
}

@end

@implementation NSXMLParser (Laconic)

+ (id)XMLObjectWithData:(NSData *)data
                  error:(NSError * __autoreleasing *)error;
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    NSXMLParserLaconicDelegate *laconic = [[NSXMLParserLaconicDelegate alloc] init];
    parser.delegate = laconic;
    
    if ([parser parse]) {
        if (error)
            *error = nil;
        return [laconic.rootNode copy];
    }
    
    if (error)
        *error = parser.parserError;
    return laconic.rootNode;
}

@end
