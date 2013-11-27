//
//  NSXMLParser+Laconic.h
//  DailyPhoto
//
//  Created by Антон Буков on 27.11.13.
//  Copyright (c) 2013 Codeless Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSXMLParser (Laconic)

+ (id)XMLObjectWithData:(NSData *)data
                  error:(NSError * __autoreleasing *)error;

@end
