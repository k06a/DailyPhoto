//
//  NSXMLParser+Laconic.m
//  DailyPhoto
//
//  Created by Антон Буков on 27.11.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import "NSXMLParser+Laconic.h"

@interface NSXMLParserLaconicDelegate : NSObject<NSXMLParserDelegate>
@property (strong, nonatomic) NSMutableDictionary *currentNode;
@end

@implementation NSXMLParserLaconicDelegate

- (NSMutableDictionary *)currentNode {
    if (_currentNode == nil)
        _currentNode = [NSMutableDictionary dictionary];
    return _currentNode;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSMutableDictionary * newNode = [NSMutableDictionary dictionary];
    newNode[@"parentNode"] = self.currentNode;
    newNode[@"name"] = elementName;
    
    if (attributeDict && attributeDict.count > 0)
        for (id key in attributeDict)
            newNode[key] = attributeDict[key];
    
    self.currentNode = newNode;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!self.currentNode[@"content"])
        self.currentNode[@"content"] = [NSMutableString string];
    [self.currentNode[@"content"] appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    NSMutableDictionary * prev = self.currentNode;
    self.currentNode = self.currentNode[@"parentNode"];
    
    void(^setNode)(id node) = nil;
    
    // Using name as key in parent node
    if (self.currentNode[prev[@"name"]] == nil) {
        setNode = ^(id node){
            self.currentNode[prev[@"name"]] = node;
        };
    }
    else if (![self.currentNode[prev[@"name"]] isKindOfClass:[NSArray class]]) {
        setNode = ^(id node){
            self.currentNode[prev[@"name"]] = [NSMutableArray arrayWithObject:node];
        };
    }
    else {
        setNode = ^(id node){
            [self.currentNode[prev[@"name"]] addObject:node];
        };
    }
    
    // 3 key-values: parent, name, content
    if (prev.count == 3 && prev[@"content"]) {
        // Inlining data at content key
        setNode(prev[@"content"]);
    } else {
        setNode(prev);
        [prev removeObjectForKey:@"parentNode"];
        [prev removeObjectForKey:@"name"];
    }
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
        return [laconic.currentNode copy];
    }
    
    if (error)
        *error = parser.parserError;
    return laconic.currentNode;
}

@end
