//
//  PDClassInfo.m
//  PDLeakMonitor
//
//  Created by liang on 2019/12/24.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDClassInfo.h"

PDEncodingType PDEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return PDEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return PDEncodingTypeUnknown;
    
    PDEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= PDEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= PDEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= PDEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= PDEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= PDEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= PDEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= PDEncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }

    len = strlen(type);
    if (len == 0) return PDEncodingTypeUnknown | qualifier;

    switch (*type) {
        case 'v': return PDEncodingTypeVoid | qualifier;
        case 'B': return PDEncodingTypeBool | qualifier;
        case 'c': return PDEncodingTypeInt8 | qualifier;
        case 'C': return PDEncodingTypeUInt8 | qualifier;
        case 's': return PDEncodingTypeInt16 | qualifier;
        case 'S': return PDEncodingTypeUInt16 | qualifier;
        case 'i': return PDEncodingTypeInt32 | qualifier;
        case 'I': return PDEncodingTypeUInt32 | qualifier;
        case 'l': return PDEncodingTypeInt32 | qualifier;
        case 'L': return PDEncodingTypeUInt32 | qualifier;
        case 'q': return PDEncodingTypeInt64 | qualifier;
        case 'Q': return PDEncodingTypeUInt64 | qualifier;
        case 'f': return PDEncodingTypeFloat | qualifier;
        case 'd': return PDEncodingTypeDouble | qualifier;
        case 'D': return PDEncodingTypeLongDouble | qualifier;
        case '#': return PDEncodingTypeClass | qualifier;
        case ':': return PDEncodingTypeSEL | qualifier;
        case '*': return PDEncodingTypeCString | qualifier;
        case '^': return PDEncodingTypePointer | qualifier;
        case '[': return PDEncodingTypeCArray | qualifier;
        case '(': return PDEncodingTypeUnion | qualifier;
        case '{': return PDEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return PDEncodingTypeBlock | qualifier;
            else
                return PDEncodingTypeObject | qualifier;
        }
        default: return PDEncodingTypeUnknown | qualifier;
    }
}

@implementation PDClassIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) return nil;
    self = [super init];
    _ivar = ivar;
    const char *name = ivar_getName(ivar);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    _offset = ivar_getOffset(ivar);
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        _type = PDEncodingGetType(typeEncoding);
    }
    return self;
}

@end

@implementation PDClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) return nil;
    self = [super init];
    _property = property;
    const char *name = property_getName(property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    
    PDEncodingType type = 0;
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    for (unsigned int i = 0; i < attrCount; i++) {
        switch (attrs[i].name[0]) {
            case 'T': { // Type encoding
                if (attrs[i].value) {
                    _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                    type = PDEncodingGetType(attrs[i].value);
                    
                    if ((type & PDEncodingTypeMask) == PDEncodingTypeObject && _typeEncoding.length) {
                        NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                        if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                        
                        NSString *clsName = nil;
                        if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                            if (clsName.length) _cls = objc_getClass(clsName.UTF8String);
                        }
                        
                        NSMutableArray *protocols = nil;
                        while ([scanner scanString:@"<" intoString:NULL]) {
                            NSString* protocol = nil;
                            if ([scanner scanUpToString:@">" intoString: &protocol]) {
                                if (protocol.length) {
                                    if (!protocols) protocols = [NSMutableArray new];
                                    [protocols addObject:protocol];
                                }
                            }
                            [scanner scanString:@">" intoString:NULL];
                        }
                        _protocols = protocols;
                    }
                }
            } break;
            case 'V': { // Instance variable
                if (attrs[i].value) {
                    _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;
            case 'R': {
                type |= PDEncodingTypePropertyReadonly;
            } break;
            case 'C': {
                type |= PDEncodingTypePropertyCopy;
            } break;
            case '&': {
                type |= PDEncodingTypePropertyRetain;
            } break;
            case 'N': {
                type |= PDEncodingTypePropertyNonatomic;
            } break;
            case 'D': {
                type |= PDEncodingTypePropertyDynamic;
            } break;
            case 'W': {
                type |= PDEncodingTypePropertyWeak;
            } break;
            case 'G': {
                type |= PDEncodingTypePropertyCustomGetter;
                if (attrs[i].value) {
                    _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } break;
            case 'S': {
                type |= PDEncodingTypePropertyCustomSetter;
                if (attrs[i].value) {
                    _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } // break; commented for code coverage in next line
            default: break;
        }
    }
    if (attrs) {
        free(attrs);
        attrs = NULL;
    }
    
    _type = type;
    if (_name.length) {
        if (!_getter) {
            _getter = NSSelectorFromString(_name);
        }
        if (!_setter) {
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
        }
    }
    return self;
}

@end

@implementation PDClassInfo {
    BOOL _needUpdate;
}

- (instancetype)initWithClass:(Class)cls {
    if (!cls) return nil;
    self = [super init];
    _cls = cls;
    _superCls = class_getSuperclass(cls);
    _isMeta = class_isMetaClass(cls);
    if (!_isMeta) {
        _metaCls = objc_getMetaClass(class_getName(cls));
    }
    _name = NSStringFromClass(cls);
    [self _update];

    _superClassInfo = [self.class classInfoWithClass:_superCls];
    return self;
}

- (void)_update {
    _ivarInfos = nil;
    _propertyInfos = nil;
    
    Class cls = self.cls;
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if (properties) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        _propertyInfos = propertyInfos;
        for (unsigned int i = 0; i < propertyCount; i++) {
            PDClassPropertyInfo *info = [[PDClassPropertyInfo alloc] initWithProperty:properties[i]];
            if (info.name) propertyInfos[info.name] = info;
        }
        free(properties);
    }
    
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
        _ivarInfos = ivarInfos;
        for (unsigned int i = 0; i < ivarCount; i++) {
            PDClassIvarInfo *info = [[PDClassIvarInfo alloc] initWithIvar:ivars[i]];
            if (info.name) ivarInfos[info.name] = info;
        }
        free(ivars);
    }
    
    if (!_ivarInfos) _ivarInfos = @{};
    if (!_propertyInfos) _propertyInfos = @{};
    
    _needUpdate = NO;
}

- (void)setNeedUpdate {
    _needUpdate = YES;
}

- (BOOL)needUpdate {
    return _needUpdate;
}

+ (instancetype)classInfoWithClass:(Class)cls {
    if (!cls) return nil;
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaCache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    PDClassInfo *info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)(cls));
    if (info && info->_needUpdate) {
        [info _update];
    }
    dispatch_semaphore_signal(lock);
    if (!info) {
        info = [[PDClassInfo alloc] initWithClass:cls];
        if (info) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)(cls), (__bridge const void *)(info));
            dispatch_semaphore_signal(lock);
        }
    }
    return info;
}

+ (instancetype)classInfoWithClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    return [self classInfoWithClass:cls];
}

@end


