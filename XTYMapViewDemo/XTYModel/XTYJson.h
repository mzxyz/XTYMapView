//
//  XTYJson.h
//  XTYModel
//
//  Created by Michael on 16/8/19.
//  Copyright © 2016 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTYJson : NSObject <NSCopying>

/** jsonObj is NSDictionary or NSArray*/
@property(nonatomic, readonly) id jsonObj;

/** 
 *  init method
 */
- (instancetype)initWithObject:(id)object;
+ (XTYJson *)jsonWithObject:(id)obj;
+ (XTYJson *)jsonWithData:(NSData*)jsonData;
+ (XTYJson *)jsonWithString:(NSString*)jsonStr;

/** 
 *  return json raw string
 */
- (NSString*)stringJson;

/** 
 *  count of jsonObj
 */
- (NSUInteger)count;

/** 
 *  return NSDictionary or NSArray
 */
- (instancetype)jsonObj;
- (void)setJsonObject:(id)jsonObj;

/** 
 *  search wether exist value at key
 */
- (BOOL)hasValueForKey:(NSString*)key;
- (BOOL)hasValueAtIndex:(NSUInteger)index;

/** 
 *  get json value with key
 */
- (XTYJson*)jsonForKey:(NSString*)key;
- (instancetype)originValueForKey:(NSString *)key;

/** 
 *  get json value with index
 */
- (XTYJson*)jsonAtIndex:(NSUInteger)index;

/** 
 *  return string value for key
 */
- (NSString*)stringValueForKey:(NSString*)key;

/** 
 *  if jsonObj does't contain the key or the value of the key is NSNull, return the default Sring
 */
- (NSString*)stringValueForKey:(NSString*)key defaultValue:(NSString*)defaultStr;

/** 
 *  return NSInteger value for key
 */
- (NSInteger)integerValueForKey:(NSString*)key;

/** 
 *  if jsonObj does't contain the key or the value of the key is NSNull, return the default int value
 */
- (NSInteger)integerValueForKey:(NSString*)key defaultValue:(NSInteger)defaultInt;

/** 
 *  other getter method of base data type with key or index
 */
- (int)intValueForKey:(NSString *)key;
- (int)intValueForKey:(NSString *)key defaultValue:(int)defaultInt;

- (char)charValueForKey:(NSString*)key;
- (NSInteger)charValueForKey:(NSString*)key defaultValue:(int)defaultChar;

- (char)charValueAtIndex:(NSUInteger)index;
- (char)charValueAtIndex:(NSUInteger)index defaultValue:(char)defaultChar;

- (long)longValueForKey:(NSString*)key;
- (long)longValueForKey:(NSString*)key defaultValue:(long)defaultLong;
- (long long)longlongValueForKey:(NSString*)key;
- (long long)longlongValueForKey:(NSString*)key defaultValue:(long long)defaultLonglong;

- (double)doubleValueForKey:(NSString*)key;
- (double)doubleValueForKey:(NSString*)key defaultValue:(double)defaultDouble;
- (float)floatValueForKey:(NSString*)key;
- (float)floatValueForKey:(NSString*)key defaultValue:(float)defaultFloat;

- (BOOL)booleanValueForKey:(NSString*)key;
- (BOOL)booleanValueForKey:(NSString*)key defaultValue:(BOOL)defaultBoolean;

- (id)originValueAtIndex:(NSUInteger)index;
- (NSString*)stringValueAtIndex:(NSUInteger)index;
- (NSString*)stringValueAtIndex:(NSUInteger)index defaultValue:(NSString*)defaultStr;
- (NSInteger)integerValueAtIndex:(NSUInteger)index;
- (NSInteger)integerValueAtIndex:(NSUInteger)index defaultValue:(NSInteger)defaultInt;

- (int)intValueAtIndex:(NSUInteger)index;
- (int)intValueAtIndex:(NSUInteger)index defaultValue:(int)defaultInt;
- (long)longValueAtIndex:(NSUInteger)index;
- (long)longValueAtIndex:(NSUInteger)index defaultValue:(long)defaultLong;
- (long long)longlongValueAtIndex:(NSUInteger)index;
- (long long)longlongValueAtIndex:(NSUInteger)index defaultValue:(long long)defaultLonglong;
- (double)doubleValueAtIndex:(NSUInteger)index;
- (double)doubleValueAtIndex:(NSUInteger)index defaultValue:(double)defaultDouble;
- (float)floatValueAtIndex:(NSUInteger)index;
- (float)floatValueAtIndex:(NSUInteger)index defaultValue:(float)defaultFloat;

@end