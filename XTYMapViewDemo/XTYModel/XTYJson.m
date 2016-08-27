//
//  XTYJson.m
//  XTYModel
//
//  Created by Michael on 16/8/19.
//  Copyright © 2016 Michael. All rights reserved.
//

#import "XTYJson.h"

@interface XTYJson ()

@property (nonatomic, strong) id jsonObj;

@end

@implementation XTYJson

#pragma mark - init Method
+ (XTYJson *)jsonWithObject:(id)obj
{
    __autoreleasing XTYJson *json = [[XTYJson alloc] initWithObject:obj];
    
    return json;
}

+ (XTYJson *)jsonWithData:(NSData*)jsonData;
{
    id jsonObj = nil;
    
    if (jsonData)
    {
        jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    }
    
    if (jsonObj)
    {
        return [XTYJson jsonWithObject:jsonObj];
    }
    else
    {
        return nil;
    }
}

+ (XTYJson *)jsonWithString:(NSString*)jsonStr;
{
    if ([jsonStr isKindOfClass:[NSString class]])
    {
        NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        return [XTYJson jsonWithData:jsonData];
    }
    return nil;
}

- (id)initWithObject:(id)object;
{
    self = [super init];
    if (self)
    {
        [self setJsonObject:object];
    }
    
    return self;
}

- (void)setJsonObject:(id)jsonObj
{
    /** only accept dict and array*/
    if ([jsonObj isKindOfClass:[NSDictionary class]]||
        [jsonObj isKindOfClass:[NSArray class]])
    {
        _jsonObj = jsonObj;
    }
    else
    {
        _jsonObj = nil;
    }
}

#pragma mark - judging whether the value exists
- (BOOL)hasValueForKey:(NSString*)key;
{
    if (_jsonObj)
    {
        if ([_jsonObj isKindOfClass:[NSDictionary class]])
        {
            return [_jsonObj valueForKey:key] != nil;
        }
    }
    
    return false;
}

- (BOOL)hasValueAtIndex:(NSUInteger)index
{
    if (_jsonObj)
    {
        if ([_jsonObj isKindOfClass:[NSArray class]]&&
            index < [_jsonObj count])
        {
            return YES;
        }
    }
    
    return  NO;
}

#pragma mark - getter method
- (NSString*)stringJson;
{
    if (!_jsonObj) {return nil;}
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_jsonObj options:0 error:&error];
    
    __autoreleasing NSString *stringData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return stringData;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ _jsonObj: %@", [super description], [_jsonObj description]];
}

- (id)jsonObj;
{
    return _jsonObj;
}

- (NSUInteger)count;
{
    if (_jsonObj)
    {
        /**for Array*/
        if ([_jsonObj respondsToSelector:@selector(count)])
        {
            return [_jsonObj count];
        }
    }
    
    return 0;
}

- (instancetype)originValueForKey:(NSString *)key;
{
    if ([_jsonObj isKindOfClass:[NSDictionary class]])
    {
        return [(NSDictionary*)_jsonObj valueForKey:key];
    }
    
    return nil;
}

- (XTYJson*)jsonForKey:(NSString*)key;
{
    id value = [self originValueForKey:key];
    if ([value isKindOfClass:[NSDictionary class]]||
        [value isKindOfClass:[NSArray class]])
    {
        return [XTYJson jsonWithObject:value];
    }
    
    return nil;
}

- (NSString*)stringValueForKey:(NSString*)key;
{
    return [self stringValueForKey:key defaultValue:nil];
}

- (NSString*)stringValueForKey:(NSString*)key defaultValue:(NSString*)defaultStr;
{
    id value = [self originValueForKey:key];
    
    if ([value isKindOfClass:[NSString class]])
    {
        return value;
    }
    else if ([value respondsToSelector:@selector(stringValue)])
    {
        return [value stringValue];
    }
    else
    {
        return defaultStr;
    }
}

- (NSInteger)integerValueForKey:(NSString*)key;
{
    return [self integerValueForKey:key defaultValue:0];
}

- (NSInteger)integerValueForKey:(NSString*)key defaultValue:(NSInteger)defaultInt;
{
    id value = [self originValueForKey:key];
    
    if ([value respondsToSelector:@selector(integerValue)])
    {
        return [value integerValue];
    }
    else
    {
        return defaultInt;
    }
}

#pragma mark - other getter method of base data type with key or index
- (int)intValueForKey:(NSString *)key
{
    return  [self intValueForKey:key defaultValue:0];
}

- (int)intValueForKey:(NSString *)key defaultValue:(int)defaultInt
{
    id value = [self originValueForKey:key];
    if ([value respondsToSelector:@selector(intValue)])
    {
        return [value intValue];
    }
    else
    {
        return defaultInt;
    }
}

- (char)charValueForKey:(NSString*)key;
{
    return [self integerValueForKey:key defaultValue:0];
}

- (NSInteger)charValueForKey:(NSString*)key defaultValue:(int)defaultChar;
{
    id value = [self originValueForKey:key];
    
    if ([value respondsToSelector:@selector(charValue)])
    {
        return [value charValue];
    }
    else
    {
        return defaultChar;
    }
}

- (long)longValueForKey:(NSString*)key;
{
    return [self longValueForKey:key defaultValue:0];
}

- (long)longValueForKey:(NSString*)key defaultValue:(long)defaultLong;
{
    id value = [self originValueForKey:key];
    
    if ([value respondsToSelector:@selector(longValue)])
    {
        return [value longValue];
    }
    else
    {
        return defaultLong;
    }
}

- (long long)longlongValueForKey:(NSString*)key;
{
    return [self longlongValueForKey:key defaultValue:0];
}

- (long long)longlongValueForKey:(NSString*)key defaultValue:(long long)defaultLonglong;
{
    id value = [self originValueForKey:key];
    
    if ([value respondsToSelector:@selector(longLongValue)])
    {
        return [value longLongValue];
    }
    else
    {
        return defaultLonglong;
    }
}

- (double)doubleValueForKey:(NSString*)key;
{
    return [self doubleValueForKey:key defaultValue:0.0];
}

- (double)doubleValueForKey:(NSString*)key defaultValue:(double)defaultDouble;
{
    id value = [self originValueForKey:key];
    
    if ([value respondsToSelector:@selector(doubleValue)])
    {
        return [value doubleValue];
    }
    else
    {
        return 0;
    }
}

- (float)floatValueForKey:(NSString*)key;
{
    return [self floatValueForKey:key defaultValue:0];
}

- (float)floatValueForKey:(NSString*)key defaultValue:(float)defaultFloat;
{
    id value = [self originValueForKey:key];
    
    if ([value respondsToSelector:@selector(floatValue)])
    {
        return [value floatValue];
    }
    else
    {
        return defaultFloat;
    }
}

- (char)charValueAtIndex:(NSUInteger)index;
{
    return [self integerValueAtIndex:index defaultValue:0];
}

- (char)charValueAtIndex:(NSUInteger)index defaultValue:(char)defaultChar;
{
    id value = [self originValueAtIndex:index];
    
    if ([value respondsToSelector:@selector(charValue)])
    {
        return [value charValue];
    }
    
    return defaultChar;
}

- (BOOL)booleanValueForKey:(NSString*)key;
{
    return [self booleanValueForKey:key defaultValue:NO];
}

- (BOOL)booleanValueForKey:(NSString*)key defaultValue:(BOOL)defaultBoolean;
{
    NSString *value = [self stringValueForKey:key defaultValue:nil];
    if (value)
    {
        return [value boolValue];
    }
    
    return defaultBoolean;
}

- (XTYJson*)jsonAtIndex:(NSUInteger)index;
{
    id value = [self originValueAtIndex:index];
    if ([value isKindOfClass:[NSDictionary class]]
        || [value isKindOfClass:[NSArray class]])
    {
        return [XTYJson jsonWithObject:value];
    }
    return nil;
}

- (id)originValueAtIndex:(NSUInteger)index;
{
    if (_jsonObj && [_jsonObj isKindOfClass:[NSArray class]] && index < [_jsonObj count])
    {
        return [(NSArray*)_jsonObj objectAtIndex:index];
    }
    return nil;
}

- (NSString*)stringValueAtIndex:(NSUInteger)index;
{
    return [self stringValueAtIndex:index defaultValue:nil];
}

- (NSString*)stringValueAtIndex:(NSUInteger)index defaultValue:(NSString*)defaultStr;
{
    id value = [self originValueAtIndex:index];
    if ([value isKindOfClass:[NSString class]])
    {
        return value;
    }
    else if ([value respondsToSelector:@selector(stringValue)])
    {
        return [value stringValue];
    }
    else
    {
        return defaultStr;
    }
}

- (int)intValueAtIndex:(NSUInteger)index
{
    return [self intValueAtIndex:index defaultValue:0];
}
- (int)intValueAtIndex:(NSUInteger)index defaultValue:(int)defaultInt
{
    id value = [self originValueAtIndex:index];
    if ([value respondsToSelector:@selector(intValue)])
    {
        return [value intValue];
    }
    
    return defaultInt;
}

- (NSInteger)integerValueAtIndex:(NSUInteger)index;
{
    return [self integerValueAtIndex:index defaultValue:0];
}

- (NSInteger)integerValueAtIndex:(NSUInteger)index defaultValue:(NSInteger)defaultInt;
{
    id value = [self originValueAtIndex:index];
    
    if ([value respondsToSelector:@selector(integerValue)])
    {
        return [value integerValue];
    }
    
    return defaultInt;
}

- (long)longValueAtIndex:(NSUInteger)index;
{
    return [self longValueAtIndex:index defaultValue:0];
}

- (long)longValueAtIndex:(NSUInteger)index defaultValue:(long)defaultLong;
{
    id value = [self originValueAtIndex:index];
    
    if ([value respondsToSelector:@selector(longValue)])
    {
        return [value longValue];
    }
    
    return defaultLong;
}

- (long long)longlongValueAtIndex:(NSUInteger)index;
{
    return [self longlongValueAtIndex:index defaultValue:0];
}

- (long long)longlongValueAtIndex:(NSUInteger)index defaultValue:(long long)defaultLonglong;
{
    id value = [self originValueAtIndex:index];
    
    if ([value respondsToSelector:@selector(longLongValue)])
    {
        return [value longLongValue];
    }
    else
    {
        return defaultLonglong;
    }
}

- (double)doubleValueAtIndex:(NSUInteger)index;
{
    return [self doubleValueAtIndex:index defaultValue:0];
}

- (double)doubleValueAtIndex:(NSUInteger)index defaultValue:(double)defaultDouble;
{
    id value = [self originValueAtIndex:index];
    
    if ([value respondsToSelector:@selector(doubleValue)])
    {
        return [value doubleValue];
    }
    
    return defaultDouble;
}

- (float)floatValueAtIndex:(NSUInteger)index;
{
    return [self floatValueAtIndex:index defaultValue:0];
}

- (float)floatValueAtIndex:(NSUInteger)index defaultValue:(float)defaultFloat;
{
    id value = [self originValueAtIndex:index];
    
    if ([value respondsToSelector:@selector(floatValue)])
    {
        return [value floatValue];
    }
    
    return defaultFloat;
}

- (id)copyWithZone:(NSZone *)zone
{
    XTYJson *copyJson = [[self.class allocWithZone:zone] initWithObject:[_jsonObj copyWithZone:zone]];
    return copyJson;
}

@end