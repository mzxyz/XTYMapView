//
//  XTYModelItem.m
//  XTYModel
//
//  Created by Michael on 16/8/19.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "XTYModelItem.h"
#import <objc/runtime.h>
#import <objc/message.h>

#ifdef DEBUG
#define XTYModelAssert(condition, desc, ...) \
{if(!(condition)){NSLog(desc, ##__VA_ARGS__);NSAssert(NO, desc, ##__VA_ARGS__);}}
#else
#define XTYModelAssert(condition, desc, ...) (void*)0
#endif


#pragma mark - property attributes
@interface __PropertyAttribute : NSObject

@property (nonatomic, strong) NSString *propertyName;
@property (nonatomic, strong) NSString *returnValueType;
@property (nonatomic, assign) BOOL readonly;
@property (nonatomic, assign) BOOL hasVariable;

@end

@implementation __PropertyAttribute

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ name:%@ value:%@ ro:%d hv:%d>",
            [super description], self.propertyName, self.returnValueType, self.readonly, self.hasVariable];
}

@end


#pragma mark - XTYModelItem implementation
@implementation XTYModelItem
{
    id _json;
}

+ (void)load
{
}

#pragma mark - these method should be rewrite by subClass if need
+ (NSDictionary *)JSONKeyMapForProperties
{
    return @{};
}

+ (NSDictionary *)elementClassMapForNSArrayProperties
{
    return @{};
}

+ (NSArray *)ignoredProperties
{
    return @[];
}

- (NSDictionary *)originDict
{
    return (NSDictionary *)self.json.jsonObj;
}

#pragma mark - init Method
- (instancetype)initWithJson:(XTYJson*)json;
{
    self = [super init];
    if (self)
    {
        if (json && [json jsonObj])
        {
            if ([[json jsonObj] isKindOfClass:[NSDictionary class]])
            {
                _json = json;
                [self parseProperties];
            }
            else if ([[json jsonObj] isKindOfClass:[NSArray class]] && [[json jsonObj] count] == 0)
            {
            }
            else
            {
                XTYModelAssert(NO, @"XTYModelItem initWithJson param is not Dictionary type obj in Json");
            }
        }
    }
    
    return self;
}

- (instancetype)initwithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary isKindOfClass:[NSDictionary class]])
    {
        _json = [[XTYJson alloc] initWithObject:dictionary];
        return [self initWithJson:_json];
    }
    else
    {
        return nil;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self parseProperties];
    }
    
    return self;
}

#pragma mark - combine properties dictionary
- (NSDictionary *)__recursiveBuildDictionaryFromPropertiesByClass:(Class)aClass
{
    @autoreleasepool
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        if (aClass && aClass != [XTYModelItem superclass])
        {
            [dict addEntriesFromDictionary:[self __recursiveBuildDictionaryFromPropertiesByClass:[aClass superclass]]];
        }
        else
        {
            return [dict copy];
        }
        
        [dict addEntriesFromDictionary:[self __buildDictionaryFromProperties:aClass]];
        
        return [dict copy];
    }
}

- (NSDictionary *)__buildDictionaryFromProperties:(Class)aClass
{
    NSDictionary *keyMap =  [self.class recursiveKeyMap];
    NSDictionary *arrayElementMap = [self.class recursiveElementKeys];
    NSSet *ignoredSet = [self.class recursiveIgnoredProperties];
    
    NSDictionary *maps = [aClass classMapOfProperties];
    NSMutableDictionary *propertyDict = [[NSMutableDictionary alloc] init];
    
    for (NSString *propertyName in maps)
    {
        __PropertyAttribute *attr = maps[propertyName];
        
        NSString *jsonKey = keyMap[propertyName];
        if (jsonKey.length == 0)
        {
            jsonKey = propertyName;
        }
        
        if ([ignoredSet containsObject:propertyName])
        {
            if ([_json originValueForKey:jsonKey])
            {
                propertyDict[jsonKey] = [_json originValueForKey:jsonKey];
            }
            
            continue;
        }
        
        const char *aRetType = [attr.returnValueType UTF8String];
        Class propertyClazz = [[self class] classFromRetType:aRetType];
        
        /** item subClass*/
        if ([propertyClazz isSubclassOfClass:[XTYModelItem class]])
        {
            /** getter method*/
            XTYModelItem *item = ((XTYModelItem *(*)(id,SEL))objc_msgSend)(self, NSSelectorFromString(propertyName));
            if (item)
            {
                /** circle parse*/
                propertyDict[jsonKey] = [item __recursiveBuildDictionaryFromPropertiesByClass:item.class];
            }
        }

        /** NSString*/
        else if (propertyClazz == [NSString class] || [propertyClazz isSubclassOfClass:[NSString class]])
        {
            NSString *string = ((NSString *(*)(id,SEL))objc_msgSend)(self, NSSelectorFromString(propertyName));
            if (string)
            {
                propertyDict[jsonKey] = string;
            }
        }
        
        /** NSArray*/
        else if (propertyClazz == [NSArray class] || [propertyClazz isSubclassOfClass:[NSArray class]]
                 || propertyClazz == [NSSet class] || [propertyClazz isSubclassOfClass:[NSSet class]])
        {
            Class elementClass = arrayElementMap[propertyName];
            if (elementClass == nil)
            {
                XTYModelAssert(NO, @"%@ the property did not define the element type in this <elementClassMapForNSArrayProperties>  method", propertyName);
                continue;
            }
            
            id value = ((id(*)(id,SEL))objc_msgSend)(self, NSSelectorFromString(propertyName));
            if (value)
            {
                NSArray *array = nil;
                if ((propertyClazz == [NSSet class] || [propertyClazz isSubclassOfClass:[NSSet class]]) &&
                    [value isKindOfClass:[NSSet class]])
                {
                    array = [(NSSet *)value allObjects];
                }
                else
                {
                    array = value;
                }
                
                if ([array isKindOfClass:[NSArray class]])
                {
                    /** the item is array*/
                    if ([elementClass isSubclassOfClass:[XTYModelItem class]])
                    {
                        NSMutableArray *jsonarray = [[NSMutableArray alloc] init];
                        for (XTYModelItem *item in array)
                        {
                            if ([item isKindOfClass:elementClass])
                            {
                                [jsonarray addObject:[item __recursiveBuildDictionaryFromPropertiesByClass:item.class]];
                            }
                            else
                            {
                                XTYModelAssert(NO, @"%@ %@ array，has element is not %@ type", self, propertyName, elementClass);
                            }
                        }
                        
                        if (jsonarray.count)
                        {
                            propertyDict[jsonKey] = [jsonarray copy];
                        }
                    }
                    /** (NSArray<NSString *> *)*/
                    else if ([elementClass isSubclassOfClass:[NSString class]]
                             || [elementClass isSubclassOfClass:[NSNumber class]]
                             || [elementClass isSubclassOfClass:[NSDictionary class]]
                             || [elementClass isSubclassOfClass:[NSArray class]])
                    {
                        NSMutableArray *jsonarray = [[NSMutableArray alloc] init];
                        for (id obj in array)
                        {
                            if ([obj isKindOfClass:elementClass])
                            {
                                [jsonarray addObject:[obj copy]];
                            }
                            else
                            {
                                XTYModelAssert(NO, @"%@ %@ array，has element is not %@ type", self, propertyName, elementClass);
                            }
                        }
                        if (jsonarray.count)
                        {
                            propertyDict[jsonKey] = [jsonarray copy];
                        }
                    }
                    /** NSSet*/
                    else if ([elementClass isSubclassOfClass:[NSSet class]]) {
                        NSMutableArray *jsonarray = [[NSMutableArray alloc] init];
                        for (NSSet *obj in array) {
                            if ([obj isKindOfClass:elementClass]) {
                                [jsonarray addObject:[[obj allObjects] copy]];
                            }
                            else {
                                XTYModelAssert(NO, @"%@ %@ array，has element is not %@ type", self, propertyName, elementClass);
                            }
                        }
                        if (jsonarray.count) {
                            propertyDict[jsonKey] = [jsonarray copy];
                        }
                    }
                    /** (NSArray<XTYJson *> *)*/
                    else if (elementClass == [XTYJson class] ||
                             [elementClass isSubclassOfClass:[XTYJson class]])
                    {
                        NSMutableArray *jsonarray = [[NSMutableArray alloc] init];
                        for (XTYJson *json in array)
                        {
                            if ([json isKindOfClass:elementClass])
                            {
                                [jsonarray addObject:[json jsonObj]];
                            }
                            else
                            {
                                XTYModelAssert(NO, @"%@ %@ array，has element is not %@ type", self, propertyName, elementClass);
                            }
                        }
                        
                        if (jsonarray.count)
                        {
                            propertyDict[jsonKey] = [jsonarray copy];
                        }
                    }
                    else
                    {
                        XTYModelAssert(NO, @"%%@ %@ array，has element is not %@ type", self, propertyName);
                    }
                }
                else
                {
                    XTYModelAssert(NO, @"%@ %@ array，has element is not XTYJson", self, propertyName);
                }
            }
        }
        
        /** XTYjson*/
        else if (propertyClazz == [XTYJson class] || [propertyClazz isSubclassOfClass:[XTYJson class]])
        {
            XTYJson *json = ((XTYJson *(*)(id,SEL))objc_msgSend)(self, NSSelectorFromString(propertyName));
            if ([json isKindOfClass:propertyClazz])
            {
                propertyDict[jsonKey] = [json.jsonObj copy];
            }
            else
            {
                XTYModelAssert(NO, @"%@ %@ array，has element is not %@ type", self, propertyName, propertyClazz);
            }
        }
        else
        {   /**c type*/
            switch (aRetType[0])
            {
                case _C_CHR:
                    propertyDict[jsonKey] = @(((char(*)(id,SEL))objc_msgSend)(self, NSSelectorFromString(propertyName)));
                    break;
                case _C_BOOL:
                    propertyDict[jsonKey] = @(((BOOL(*)(id,SEL))objc_msgSend)(self, NSSelectorFromString(propertyName)));
                    break;
                case _C_INT:
                    propertyDict[jsonKey] = @(((int(*)(id,SEL))objc_msgSend)(self, NSSelectorFromString(propertyName)));
                    break;
                case _C_UINT:
                    propertyDict[jsonKey] = @(((unsigned int(*)(id,SEL))objc_msgSend)(self, NSSelectorFromString(propertyName)));
                    break;
                case _C_LNG_LNG:
                    propertyDict[jsonKey] = @(((long long(*)(id,SEL))objc_msgSend)(self, NSSelectorFromString(propertyName)));
                    break;
                case _C_ULNG_LNG:
                    propertyDict[jsonKey] = @(((unsigned long long(*)(id,SEL))objc_msgSend)(self, NSSelectorFromString(propertyName)));
                    break;
                case _C_FLT:
                    propertyDict[jsonKey] = @(((float(*)(id,SEL))objc_msgSend)(self, NSSelectorFromString(propertyName)));
                    break;
                case _C_DBL:
                    propertyDict[jsonKey] = @(((double(*)(id,SEL))objc_msgSend)(self, NSSelectorFromString(propertyName)));
                    break;
                default:
                    XTYModelAssert(NO, @"%@ %@ is unknow type", self, propertyName);
                    break;
            }
        }
    }
    
    return [propertyDict copy];
}

- (void)rebuildJsonFromProperties
{
    NSDictionary *dict = [self __recursiveBuildDictionaryFromPropertiesByClass:self.class];
    _json = [XTYJson jsonWithObject:dict];
}

#pragma mark - parse with json
- (void)parseProperties
{
    [self __recursiveParsePropertyByClass:[self class]];
}

- (void)__recursiveParsePropertyByClass:(Class)aClass
{
    @autoreleasepool
    {
        if (aClass && aClass != [XTYModelItem superclass])
        {
            [self __recursiveParsePropertyByClass:[aClass superclass]];
        }
        else
        {
            return;
        }
        
        [self __parsePropertyByClass:aClass];
    }
}

- (void)__parsePropertyByClass:(Class)aClazz
{
    NSDictionary *keyMap =  [self.class recursiveKeyMap];
    NSDictionary *arrayElementMap = [self.class recursiveElementKeys];
    NSSet *ignoredSet = [self.class recursiveIgnoredProperties];
    NSDictionary *maps = [aClazz classMapOfProperties];
    
    for (NSString *propertyName in maps)
    {
        if ([ignoredSet containsObject:propertyName])
        {
            continue;
        }
        
        __PropertyAttribute *attr = maps[propertyName];
        NSString *jsonKey = keyMap[propertyName];
        if (jsonKey.length == 0)
            jsonKey = propertyName;
        
        if (![_json originValueForKey:jsonKey])
        {
            continue;
        }
        
        const char *aRetType = [attr.returnValueType UTF8String];
        Class propertyClazz = [[self class] classFromRetType:aRetType];
        
        /** item subClass*/
        if ([propertyClazz isSubclassOfClass:[XTYModelItem class]]) {
            XTYJson *json = [_json jsonForKey:jsonKey];
            if (json) {
                XTYModelItem *item = [[propertyClazz alloc] initWithJson:json];
                [self __setValue:item forProperty:propertyName retType:aRetType[0]
                  inPropertyMaps:maps];
            }
        }
        /** string*/
        else if (propertyClazz == [NSString class] || [propertyClazz isSubclassOfClass:[NSString class]])
        {
            NSString *value = [_json stringValueForKey:jsonKey];
            [self __setValue:value forProperty:propertyName retType:aRetType[0]
              inPropertyMaps:maps];
        }
        /** array*/
        else if (propertyClazz == [NSArray class] || [propertyClazz isSubclassOfClass:[NSArray class]]
                 || propertyClazz == [NSSet class] || [propertyClazz isSubclassOfClass:[NSSet class]])
        {
            
            Class elementClass = arrayElementMap[propertyName];
            if (elementClass == nil)
            {
                XTYModelAssert(NO, @"%@ is unkown type", propertyName);
                continue;
            }
            
            XTYJson *jsonArray = [_json jsonForKey:jsonKey];
            if ([jsonArray.jsonObj isKindOfClass:[NSArray class]])
            {
                id value = nil;
                
                if ([elementClass isSubclassOfClass:[XTYModelItem class]])
                {
                    NSMutableArray *elements =
                    [elementClass _arrayWithArrayDictionary:(NSArray *)jsonArray.jsonObj mutable:YES];
                    value = elements;
                }
                /** NSString*/
                else if ([elementClass isSubclassOfClass:[NSString class]])
                {
                    NSMutableArray* elements = [NSMutableArray arrayWithCapacity:[jsonArray count]];
                    
                    for (int idx = 0; idx < jsonArray.count; idx++)
                    {
                        id item = [jsonArray stringValueAtIndex:idx];
                        if ([item isKindOfClass:elementClass])
                        {
                            [elements addObject:item];
                        }
                        else
                        {
                            XTYModelAssert(NO, @"%@ json array，has valuse is not %@ class", jsonKey, elementClass);
                        }
                    }
                    
                    value = elements;
                }
                /** NSNumber & NSDictionary & NSArray*/
                else if ([elementClass isSubclassOfClass:[NSNumber class]]
                         || [elementClass isSubclassOfClass:[NSDictionary class]]
                         || [elementClass isSubclassOfClass:[NSArray class]])
                {
                    NSMutableArray* elements = [NSMutableArray arrayWithCapacity:[jsonArray count]];
                    
                    for (int idx = 0; idx < jsonArray.count; idx++)
                    {
                        id item = [jsonArray originValueAtIndex:idx];
                        if ([item isKindOfClass:elementClass])
                        {
                            [elements addObject:item];
                        }
                        else
                        {
                            XTYModelAssert(NO, @"%@ json array，has valuse is not %@ class", jsonKey, elementClass);
                        }
                    }
                    
                    value = elements;
                }
                /** (NSArray<XTYJson *> *)*/
                else if ([elementClass isSubclassOfClass:[XTYJson class]])
                {
                    NSMutableArray* elements = [NSMutableArray arrayWithCapacity:[jsonArray count]];
                    
                    for (int idx = 0; idx < jsonArray.count; idx++)
                    {
                        id item = [jsonArray jsonAtIndex:idx];
                        if ([item isKindOfClass:elementClass])
                        {
                            [elements addObject:item];
                        }
                        else
                        {
                            XTYModelAssert(NO, @"%@ json array，has valuse is not %@ class", jsonKey, elementClass);
                        }
                    }
                    
                    value = elements;
                }
                else
                {
                    value = jsonArray.jsonObj;
                }
                
                BOOL mutable = [propertyClazz isSubclassOfClass:[NSMutableArray class]] || [propertyClazz isSubclassOfClass:[NSMutableSet class]];
                if (propertyClazz == [NSSet class] || [propertyClazz isSubclassOfClass:[NSSet class]])
                {
                    value = [[NSSet alloc] initWithArray:value];
                }
                if (mutable)
                {
                    value = mutable ? [value mutableCopy] : [value copy] ;
                }
                
                [self __setValue:value forProperty:propertyName retType:aRetType[0]
                  inPropertyMaps:maps];
            }
            else if (jsonArray)
            {
                XTYModelAssert(NO, @"%@ in the json with the property %@ is not array", propertyName, jsonKey);
            }
        }
        /** XTYjson*/
        else if (propertyClazz == [XTYJson class] || [propertyClazz isSubclassOfClass:[XTYJson class]])
        {
            XTYJson *json = [_json jsonForKey:jsonKey];
            [self __setValue:json forProperty:propertyName retType:aRetType[0]
              inPropertyMaps:maps];
        }
        else
        {
            switch (aRetType[0])
            {
                case _C_CHR:
                {
                    char value = [_json charValueForKey:jsonKey];
                    [self __setValue:@(value) forProperty:propertyName retType:aRetType[0]
                      inPropertyMaps:maps];
                }
                case _C_BOOL:
                {
                    BOOL value = [_json booleanValueForKey:jsonKey];
                    [self __setValue:@(value) forProperty:propertyName retType:aRetType[0]
                      inPropertyMaps:maps];
                }
                    break;
                case _C_INT:
                case _C_UINT:
                {
                    NSInteger value = [_json integerValueForKey:jsonKey];
                    [self __setValue:@(value) forProperty:propertyName retType:aRetType[0]
                      inPropertyMaps:maps];
                }
                    break;
                case _C_LNG_LNG:
                case _C_ULNG_LNG:
                {
                    long long value = [_json longlongValueForKey:jsonKey];
                    [self __setValue:@(value) forProperty:propertyName retType:aRetType[0]
                      inPropertyMaps:maps];
                }
                    break;
                case _C_FLT:
                {
                    float value = [_json floatValueForKey:jsonKey];
                    [self __setValue:@(value) forProperty:propertyName retType:aRetType[0]
                      inPropertyMaps:maps];
                }
                    break;
                case _C_DBL:
                {
                    double value = [_json doubleValueForKey:jsonKey];
                    [self __setValue:@(value) forProperty:propertyName retType:aRetType[0]
                      inPropertyMaps:maps];
                }
                    break;
                default:
                {
                    id value = [_json originValueForKey:propertyName];
                    [self __setValue:value forProperty:propertyName retType:aRetType[0]
                      inPropertyMaps:maps];
                }
                    break;
            }
        }
    }
}


- (void)__setValue:(id)value forProperty:(NSString *)propertyName retType:(char)retType inPropertyMaps:(NSDictionary *)propertyMap
{
    __PropertyAttribute *attr = propertyMap[propertyName];
    if (!attr) return;
    
    if (attr.readonly)
    {
        if (attr.hasVariable)
        {
            [self setValue:value forKey:propertyName];
        }
    }
    else
    {
        SEL sel = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[[propertyName uppercaseString] substringToIndex:1], [propertyName substringFromIndex:1]]);
        if ([self respondsToSelector:sel])
        {
            
            switch (retType) {
                case _C_CHR:
                {
                    ((void(*)(id,SEL,char))objc_msgSend)(self,sel,[value charValue]);
                }
                    break;
                case _C_BOOL:
                {
                    ((void(*)(id,SEL,BOOL))objc_msgSend)(self,sel,[value boolValue]);
                }
                    break;
                case _C_INT:
                {
                    ((void(*)(id,SEL,NSInteger))objc_msgSend)(self,sel,[value integerValue]);
                }
                    break;
                case _C_UINT:
                {
                    ((void(*)(id,SEL,NSUInteger))objc_msgSend)(self,sel,[value unsignedIntegerValue]);
                }
                    break;
                case _C_LNG_LNG:
                {
                    ((void(*)(id,SEL,long long))objc_msgSend)(self,sel,[value longLongValue]);
                }
                    break;
                case _C_ULNG_LNG:
                {
                    ((void(*)(id,SEL,unsigned long long))objc_msgSend)(self,sel,[value unsignedLongLongValue]);
                }
                    break;
                case _C_FLT:
                {
                    ((void(*)(id,SEL,float))objc_msgSend)(self,sel,[value floatValue]);
                }
                    break;
                case _C_DBL:
                {
                    ((void(*)(id,SEL,double))objc_msgSend)(self,sel,[value doubleValue]);
                }
                    break;
                default:
                {
                    ((void(*)(id,SEL,id))objc_msgSend)(self, sel, value);
                }
                    break;
            }
        }
    }
}

+ (void)initialize
{
    if (self == [XTYModelItem class])
    {
        return;
    }
    
    NSMutableDictionary *classMap = [[NSMutableDictionary alloc] init];
    
    unsigned int count = 0;
    objc_property_t *propertys = class_copyPropertyList(self, &count);
    for (NSUInteger i = 0 ; i < count ;i ++) {
        const char *c_propertyName = property_getName(propertys[i]);
        
        /** get all properties*/
        unsigned int pCount = 0;
        objc_property_attribute_t *list = property_copyAttributeList(propertys[i], &pCount);
        
        /** getter name*/
        const char *c_getterName = NULL;
        const char *c_returnType = NULL;
        BOOL readonly = NO;
        BOOL hasVariable = NO;
        for (NSUInteger j = 0 ;j < pCount ; j++)
        {
            const char *name = list[j].name;
            const char *value = list[j].value;

            /** getter*/
            if (strcmp(name, "G") == 0)
            {
                c_getterName = value;
            }
            /** return*/
            else if (strcmp(name, "T") == 0)
            {
                c_returnType = value;
            }
            /** readonly*/
            else if (strcmp(name, "R") == 0)
            {
                readonly = YES;
            }
            /** has variable*/
            else if (strcmp(name, "V") == 0)
            {
                hasVariable = YES;
            }
        }
        if (NULL == c_getterName)
        {
            c_getterName = property_getName(propertys[i]);
        }
        
        NSString *propertyName = [NSString stringWithUTF8String:c_propertyName];
        NSString *returnValueType = [NSString stringWithUTF8String:c_returnType];
        
        __PropertyAttribute *attr = [[__PropertyAttribute alloc] init];
        attr.propertyName = propertyName;
        attr.returnValueType = returnValueType;
        attr.readonly = readonly;
        attr.hasVariable = hasVariable;
        
        classMap[propertyName] = attr;
        
        free(list);
    }
    free(propertys);
    
    [self _setClassMapOfProperties:[classMap copy]];
}

+ (Class)classFromRetType:(const char*)returnType
{
    NSUInteger len = strlen(returnType);
    if (len > 3 &&
        returnType[0] =='@' &&
        returnType[1] == '"' &&
        returnType[len-1] == '"' )
    {
        NSUInteger newLen = len - 3;
        char name[newLen+1];
        memcpy(name, returnType + 2, newLen);
        name[newLen] = '\0';
        NSString *classname = [NSString stringWithUTF8String:name];
        return NSClassFromString(classname);
    }
    
    return Nil;
}

+ (NSArray*)arrayWithArrayDictionary:(NSArray<NSDictionary *>*)arrayDict
{
    return [self _arrayWithArrayDictionary:arrayDict mutable:NO];
}

+ (NSMutableArray*)mutableArrayWithArrayDictionary:(NSArray<NSDictionary *>*)arrayDict
{
    return (NSMutableArray *)[self _arrayWithArrayDictionary:arrayDict mutable:YES];
}

+ (__kindof NSArray *)_arrayWithArrayDictionary:(NSArray*)arrayDict mutable:(BOOL)mutable
{
    NSMutableArray* arrayItem = [NSMutableArray arrayWithCapacity:arrayDict.count];
    [arrayDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id item = [[[self class] alloc] initWithDictionary:obj];
        [arrayItem addObject:item];
    }];
    
    return mutable ? [arrayItem mutableCopy] : arrayItem;
}

static void *class_classMapOfPropertiesKey = nil;
+ (NSDictionary *)classMapOfProperties
{
    return objc_getAssociatedObject(self, &class_classMapOfPropertiesKey);
}

+ (void)_setClassMapOfProperties:(NSDictionary *)classMap
{
    objc_setAssociatedObject(self, &class_classMapOfPropertiesKey, classMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSMutableDictionary *)__recursiveJSONKeyMapByClass:(Class)aClass
{
    NSDictionary *selfMap = [aClass JSONKeyMapForProperties];
    
    if (aClass && aClass != [XTYModelItem class])
    {
        NSMutableDictionary *recursiveMap = [self __recursiveJSONKeyMapByClass:[aClass superclass]];
        [recursiveMap setValuesForKeysWithDictionary:selfMap?selfMap:@{}];  // 重载父类结构
        return recursiveMap;
    }
    else
    {
        return [selfMap mutableCopy];
    }
}

static void *class_recursiveKeyMap = nil;
+ (NSDictionary *)recursiveKeyMap
{
    NSDictionary *keyMap = objc_getAssociatedObject(self, &class_recursiveKeyMap);
    if (keyMap == nil)
    {
        keyMap = [self __recursiveJSONKeyMapByClass:[self class]];
        objc_setAssociatedObject(self, &class_recursiveKeyMap, keyMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return keyMap;
}

+ (NSMutableDictionary *)__recursiveElementClassMapForNSArrayPropertiesByClass:(Class)aClass
{
    NSDictionary *selfMap = [aClass elementClassMapForNSArrayProperties];
    
    if (aClass && aClass != [XTYModelItem class])
    {
        NSMutableDictionary *recursiveMap = [self __recursiveElementClassMapForNSArrayPropertiesByClass:[aClass superclass]];
        [recursiveMap setValuesForKeysWithDictionary:selfMap?selfMap:@{}];
        return recursiveMap;
    }
    else
    {
        return [selfMap mutableCopy];
    }
}

static void *class_recursiveElementKeys = nil;
+ (NSDictionary *)recursiveElementKeys
{
    NSDictionary *elementMap = objc_getAssociatedObject(self, &class_recursiveElementKeys);
    if (elementMap == nil)
    {
        elementMap = [self __recursiveElementClassMapForNSArrayPropertiesByClass:[self class]];
        objc_setAssociatedObject(self, &class_recursiveElementKeys, elementMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return elementMap;
}

+ (NSMutableSet *)__recursiveIngoredPropertiesByClass:(Class)aClass
{
    NSArray *selfSet = [aClass ignoredProperties];
    
    if (aClass && aClass != [XTYModelItem class])
    {
        NSMutableSet *recursiveSet = [self __recursiveIngoredPropertiesByClass:[aClass superclass]];
        [recursiveSet addObjectsFromArray:selfSet?selfSet:@[]];  // 重载父类结构
        return recursiveSet;
    }
    else
    {
        return [selfSet mutableCopy];
    }
}

static void *class_ignoredProperties = nil;
+ (NSSet *)recursiveIgnoredProperties
{
    NSSet *ignoredSet = objc_getAssociatedObject(self, &class_ignoredProperties);
    if (ignoredSet == nil)
    {
        ignoredSet = [self __recursiveIngoredPropertiesByClass:[self class]];
        objc_setAssociatedObject(self, &class_ignoredProperties, [ignoredSet copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return ignoredSet;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    XTYModelItem *copyItem = [[[self class] alloc] initWithJson:_json];
    return copyItem;
}

@end