//
//  SERDomainObject.h
//  SEROptionsControllerDemo
//
//  Created by Stanley Rost on 23.03.13.
//  Copyright (c) 2013 Stanley Rost. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  kTypeFoo,
  kTypeBar,
  kTypeBaz
} kType;

@interface SERDomainObject : NSObject

@property (nonatomic) kType type;

+ (instancetype)objectOfType:(kType)type;
+ (NSString *)stringForType:(kType)type;
+ (UIImage *)imageForType:(kType)type;

@end
