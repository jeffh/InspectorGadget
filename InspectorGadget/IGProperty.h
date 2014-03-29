#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

@class IGProperty;

@protocol IGPropertyEncodingTypeVisitor <NSObject>
@required
- (void)propertyWasInt64:(IGProperty *)property;
- (void)propertyWasInt32:(IGProperty *)property;
- (void)propertyWasInt16:(IGProperty *)property;
- (void)propertyWasFloat:(IGProperty *)property;
- (void)propertyWasDouble:(IGProperty *)property;
- (void)propertyWasBool:(IGProperty *)property;
- (void)propertyWasObjCObject:(IGProperty *)property;
- (void)propertyWasUnknownType:(IGProperty *)property;

@optional
// CoreGraphics
- (void)propertyWasCGPoint:(IGProperty *)property;
- (void)propertyWasCGSize:(IGProperty *)property;
- (void)propertyWasCGRect:(IGProperty *)property;
// UIKit - iOS Only
- (void)propertyWasUIEdgeInsets:(IGProperty *)property;
- (void)propertyWasUIOffset:(IGProperty *)property;
// AppKit - OSX Only
- (void)propertyWasNSPoint:(IGProperty *)property;
- (void)propertyWasNSSize:(IGProperty *)property;
- (void)propertyWasNSRect:(IGProperty *)property;
@end

@interface IGProperty : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic, readonly) NSString *encodingType;
@property (strong, nonatomic, readonly) NSString *ivarName;
@property (strong, nonatomic, readonly) Class classType;
@property (assign, nonatomic, readonly) BOOL isObjCObjectType;
@property (assign, nonatomic, readonly) BOOL isWeak;
@property (assign, nonatomic, readonly) BOOL isNonAtomic;
@property (assign, nonatomic, readonly) BOOL isReadOnly;

- (id)initWithName:(NSString *)name attributes:(NSDictionary *)attributes;

- (BOOL)isEncodingType:(const char *)encoding;
- (void)visitEncodingType:(id<IGPropertyEncodingTypeVisitor>)visitor;

@end
