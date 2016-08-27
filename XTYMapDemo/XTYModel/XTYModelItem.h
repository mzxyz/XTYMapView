//
//  XTYModelItem.h
//  XTYModel
//
//  Created by Michael on 16/8/19.
//  Copyright © 2016 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTYJson.h"

@interface XTYModelItem : NSObject <NSCopying>

/**
 *  the raw data properties, readonly. When we parse the properties, the item retains the original data, this data can use to upload to the server or anyother uses.
 */
@property (nonatomic, readonly) NSDictionary* originDict;
@property (nonatomic, readonly) XTYJson *json;

/**
 *  init method, the input data is a XTYJson instance, if your original data is a dictionary, just use the XTYJson init method to get a instance with your dictionary. We do not encourage to use original data class, like NSDictionary or NSArray to init item.
 */
- (instancetype)initWithJson:(XTYJson*)json;
- (instancetype)initwithDictionary:(NSDictionary *)dictionary;

/**
 *  follow methods use to parse list data structure, they are class method and should be used with subClass
 */
+ (NSArray<__kindof XTYModelItem *> *)arrayWithArrayDictionary:(NSArray<NSDictionary *>*)arrayDict;
+ (NSMutableArray<__kindof XTYModelItem *> *)mutableArrayWithArrayDictionary:(NSArray<NSDictionary *>*)arrayDict;

#pragma mark - config methods,rewrite them in the subClass if you need
/**
 *  the map between json key and property key <NSString* -> NSString*>, if the key return from the server is not same as the property name, you can rewrite this method to make the properties parse correctly
 */
+ (NSDictionary *)JSONKeyMapForProperties;

/**
 *  returen a dictionary, if the property is kind of NSArray instance or inherite from it, the key is the property name<NSString *>, the value is the Class <like [NSString class]>
 */
+ (NSDictionary *)elementClassMapForNSArrayProperties;

/**
 *  rewrite this method to set a list which includes the properties you do not want to parse
 */
+ (NSArray *)ignoredProperties;

/** parse method*/
- (void)parseProperties;
- (void)rebuildJsonFromProperties;

@end