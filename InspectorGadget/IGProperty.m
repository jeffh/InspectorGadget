#import "IGProperty.h"
#import <objc/runtime.h>


@interface IGProperty ()

@property (strong, nonatomic, readwrite) NSString *encodingType;
@property (strong, nonatomic, readwrite) NSString *ivarName;
@property (strong, nonatomic, readwrite) Class classType;
@property (assign, nonatomic, readwrite) BOOL isObjCObjectType;
@property (assign, nonatomic, readwrite) BOOL isWeak;
@property (assign, nonatomic, readwrite) BOOL isNonAtomic;
@property (assign, nonatomic, readwrite) BOOL isReadOnly;

@end


@implementation IGProperty

- (id)initWithName:(NSString *)name attributes:(NSDictionary *)attributes
{
    if (self = [super init]) {
        self.name = name;
        self.encodingType = attributes[@"T"];
        self.ivarName = attributes[@"V"];
        self.isObjCObjectType = [self.encodingType characterAtIndex:0] == '@';
        self.isWeak = attributes[@"W"] != nil;
        self.isNonAtomic = attributes[@"N"] != nil;
        self.isReadOnly = attributes[@"R"] != nil;
    }
    return self;
}

- (BOOL)isEncodingType:(const char *)encoding
{
    return strcmp(self.encodingType.UTF8String, encoding) == 0;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ name=%@ ivarName=%@ isWeak=%@ isNonAtomic=%@ isReadOnly=%@ encodingType=%@>",
            NSStringFromClass([self class]), self.name, self.ivarName,
            (self.isWeak ? @"YES" : @"NO"),
            (self.isNonAtomic ? @"YES" : @"NO"),
            (self.isReadOnly ? @"YES" : @"NO"),
            self.encodingType];
}

- (NSString *)encodingTypeObjCDeclaration
{
    NSString *encodingType = self.encodingType;
    if (self.isObjCObjectType) {
        if (encodingType.length > 3 &&
            [encodingType characterAtIndex:1] == '"' &&
            [encodingType characterAtIndex:encodingType.length-1] == '"') {
            return [encodingType substringWithRange:NSMakeRange(2, encodingType.length - 3)];
        }
        return @"NSObject";
    }
    return nil;
}

- (Class)classType
{
    if (!self.isObjCObjectType) {
        return nil;
    }
    if (!_classType) {
        NSString *declaration = [self encodingTypeObjCDeclaration];
        NSString *className = @"";
        NSRange protocolStart = [declaration rangeOfString:@"<"];
        if (protocolStart.location == NSNotFound){
            className = declaration;
        } else {
            className = [declaration substringToIndex:protocolStart.location];
        }
        _classType = NSClassFromString(className);
    }
    return _classType;
}

- (void)visitEncodingType:(id<IGPropertyEncodingTypeVisitor>)visitor
{
    SEL selector;
    if ([self isEncodingType:@encode(int64_t)]) {
        selector = @selector(propertyWasInt64:);
    } else if ([self isEncodingType:@encode(int32_t)]) {
        selector = @selector(propertyWasInt32:);
    } else if ([self isEncodingType:@encode(int16_t)]) {
        selector = @selector(propertyWasInt16:);
    } else if ([self isEncodingType:@encode(float)]) {
        selector = @selector(propertyWasFloat:);
    } else if ([self isEncodingType:@encode(double)]) {
        selector = @selector(propertyWasDouble:);
    } else if ([self isEncodingType:@encode(BOOL)]) {
        selector = @selector(propertyWasBool:);
#ifdef CGFLOAT_DEFINED
    } else if ([self isEncodingType:@encode(CGPoint)]) {
        selector = @selector(propertyWasCGPoint:);
    } else if ([self isEncodingType:@encode(CGSize)]) {
        selector = @selector(propertyWasCGSize:);
    } else if ([self isEncodingType:@encode(CGRect)]) {
        selector = @selector(propertyWasCGRect:);
#endif
#if TARGET_OS_IPHONE
    } else if ([self isEncodingType:@encode(UIEdgeInsets)]) {
        selector = @selector(propertyWasUIEdgeInsets:);
    } else if ([self isEncodingType:@encode(UIOffset)]) {
        selector = @selector(propertyWasUIOffset:);
#else
    } else if ([self isEncodingType:@encode(NSPoint)]) {
        selector = @selector(propertyWasNSPoint:);
    } else if ([self isEncodingType:@encode(NSSize)]) {
        selector = @selector(propertyWasNSSize:);
    } else if ([self isEncodingType:@encode(NSRect)]) {
        selector = @selector(propertyWasNSRect:);
#endif
    } else if ([self isObjCObjectType]) {
        selector = @selector(propertyWasObjCObject:);
    } else {
        selector = @selector(propertyWasUnknownType:);
    }

    if ([visitor respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [visitor performSelector:selector withObject:self];
#pragma clang diagnostic pop
    }
}

@end
