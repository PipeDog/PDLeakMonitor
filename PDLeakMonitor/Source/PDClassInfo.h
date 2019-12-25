//
//  PDClassInfo.h
//  PDLeakMonitor
//
//  Created by liang on 2019/12/24.
//  Copyright © 2019 liang. All rights reserved.
//
//  The following code is from 'YYModel', thanks.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, PDEncodingType) {
    PDEncodingTypeMask       = 0xFF, ///< mask of type value
    PDEncodingTypeUnknown    = 0, ///< unknown
    PDEncodingTypeVoid       = 1, ///< void
    PDEncodingTypeBool       = 2, ///< bool
    PDEncodingTypeInt8       = 3, ///< char / BOOL
    PDEncodingTypeUInt8      = 4, ///< unsigned char
    PDEncodingTypeInt16      = 5, ///< short
    PDEncodingTypeUInt16     = 6, ///< unsigned short
    PDEncodingTypeInt32      = 7, ///< int
    PDEncodingTypeUInt32     = 8, ///< unsigned int
    PDEncodingTypeInt64      = 9, ///< long long
    PDEncodingTypeUInt64     = 10, ///< unsigned long long
    PDEncodingTypeFloat      = 11, ///< float
    PDEncodingTypeDouble     = 12, ///< double
    PDEncodingTypeLongDouble = 13, ///< long double
    PDEncodingTypeObject     = 14, ///< id
    PDEncodingTypeClass      = 15, ///< Class
    PDEncodingTypeSEL        = 16, ///< SEL
    PDEncodingTypeBlock      = 17, ///< block
    PDEncodingTypePointer    = 18, ///< void*
    PDEncodingTypeStruct     = 19, ///< struct
    PDEncodingTypeUnion      = 20, ///< union
    PDEncodingTypeCString    = 21, ///< char*
    PDEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    PDEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    PDEncodingTypeQualifierConst  = 1 << 8,  ///< const
    PDEncodingTypeQualifierIn     = 1 << 9,  ///< in
    PDEncodingTypeQualifierInout  = 1 << 10, ///< inout
    PDEncodingTypeQualifierOut    = 1 << 11, ///< out
    PDEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    PDEncodingTypeQualifierByref  = 1 << 13, ///< byref
    PDEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    PDEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    PDEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    PDEncodingTypePropertyCopy         = 1 << 17, ///< copy
    PDEncodingTypePropertyRetain       = 1 << 18, ///< retain
    PDEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    PDEncodingTypePropertyWeak         = 1 << 20, ///< weak
    PDEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    PDEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    PDEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

PDEncodingType PDEncodingGetType(const char *typeEncoding);

@interface PDClassIvarInfo : NSObject

@property (nonatomic, assign, readonly) Ivar ivar;              ///< ivar opaque struct
@property (nonatomic, strong, readonly) NSString *name;         ///< Ivar's name
@property (nonatomic, assign, readonly) ptrdiff_t offset;       ///< Ivar's offset
@property (nonatomic, strong, readonly) NSString *typeEncoding; ///< Ivar's type encoding
@property (nonatomic, assign, readonly) PDEncodingType type;    ///< Ivar's type

/**
 Creates and returns an ivar info object.
 
 @param ivar ivar opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithIvar:(Ivar)ivar;

@end

@interface PDClassPropertyInfo : NSObject

@property (nonatomic, assign, readonly) objc_property_t property; ///< property's opaque struct
@property (nonatomic, strong, readonly) NSString *name;           ///< property's name
@property (nonatomic, assign, readonly) PDEncodingType type;      ///< property's type
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< property's encoding value
@property (nonatomic, strong, readonly) NSString *ivarName;       ///< property's ivar name
@property (nullable, nonatomic, assign, readonly) Class cls;      ///< may be nil
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *protocols; ///< may nil
@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)
@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

/**
 Creates and returns a property info object.
 
 @param property property opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithProperty:(objc_property_t)property;

@end

@interface PDClassInfo : NSObject

@property (nonatomic, assign, readonly) Class cls; ///< class object
@property (nullable, nonatomic, assign, readonly) Class superCls; ///< super class object
@property (nullable, nonatomic, assign, readonly) Class metaCls;  ///< class's meta class object
@property (nonatomic, readonly) BOOL isMeta; ///< whether this class is meta class
@property (nonatomic, strong, readonly) NSString *name; ///< class name
@property (nullable, nonatomic, strong, readonly) PDClassInfo *superClassInfo; ///< super class's class info
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, PDClassIvarInfo *> *ivarInfos; ///< ivars
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, PDClassPropertyInfo *> *propertyInfos; ///< properties

/**
 If the class is changed (for example: you add a method to this class with
 'class_addMethod()'), you should call this method to refresh the class info cache.
 
 After called this method, `needUpdate` will returns `YES`, and you should call
 'classInfoWithClass' or 'classInfoWithClassName' to get the updated class info.
 */
- (void)setNeedUpdate;

/**
 If this method returns `YES`, you should stop using this instance and call
 `classInfoWithClass` or `classInfoWithClassName` to get the updated class info.
 
 @return Whether this class info need update.
 */
- (BOOL)needUpdate;

/**
 Get the class info of a specified Class.
 
 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 
 @param cls A class.
 @return A class info, or nil if an error occurs.
 */
+ (nullable instancetype)classInfoWithClass:(Class)cls;

/**
 Get the class info of a specified Class.
 
 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 
 @param className A class name.
 @return A class info, or nil if an error occurs.
 */
+ (nullable instancetype)classInfoWithClassName:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
