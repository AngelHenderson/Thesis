#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A suggested reply for the given input text.
 */
NS_SWIFT_NAME(SmartReplySuggestion)
@interface FIRSmartReplySuggestion : NSObject

/**
 * String representation of the suggested reply.
 */
@property(nonatomic, readonly, copy) NSString *text;

/**
 * Unavailable.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
