//
//  SERDomainObject.m
//  SEROptionsControllerDemo
//
//  Created by Stanley Rost on 23.03.13.
//  Copyright (c) 2013 Stanley Rost. All rights reserved.
//

#import "SERDomainObject.h"

@implementation SERDomainObject

+ (instancetype)objectOfType:(kType)type
{
  SERDomainObject *object = [SERDomainObject new];
  object.type = type;
  
  return object;
}

+ (NSString *)stringForType:(kType)type
{
  NSString *string = nil;
  
  switch (type)
  {
    case kTypeFoo: string = @"Foo!"; break;
    case kTypeBar: string = @"Bar?"; break;
    case kTypeBaz: string = @"Baz."; break;
  }
  
  NSAssert(string, @"SERDomainObject: unknown type");
  return string;

}

+ (UIImage *)imageForType:(kType)type
{
  NSString *imageName = nil;
  
  switch (type)
  {
    case kTypeFoo: imageName = @"foo.png"; break;
    case kTypeBar: imageName = @"bar.png"; break;
    case kTypeBaz: imageName = @"baz.png"; break;
  }
  
  return imageName ? [UIImage imageNamed:imageName] : nil;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@: %@", NSStringFromClass([self class]), [[self class] stringForType:self.type]];
}

- (BOOL)isEqual:(id)other
{
  if ([other respondsToSelector:@selector(type)])
  {
    return self.type == [(SERDomainObject *)other type];
  }
  else
  {
    return NO;
  }
}

- (NSUInteger)hash
{
  return self.type;
}


@end
