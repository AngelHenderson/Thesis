#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FIRSmartReplySuggestion;

/**
 * @enum SmartReplyResultStatus
 * This enum specifies the status of the smart reply result.
 */
typedef NS_ENUM(NSInteger, FIRSmartReplyResultStatus) {
  /** Smart Reply successfully generated non-empty reply suggestions. */
  FIRSmartReplyResultStatusSuccess,
  /** Smart Reply currently doesn't support the language used in the conversation. */
  FIRSmartReplyResultStatusNotSupportedLanguage,
  /** Smart Reply cannot figure out a good enough suggestion. */
  FIRSmartReplyResultStatusNoReply
} NS_SWIFT_NAME(SmartReplyResultStatus);

/** An object that contains the smart reply suggestion results. */
NS_SWIFT_NAME(SmartReplySuggestionResult)
@interface FIRSmartReplySuggestionResult : NSObject

/** A list of the suggestions. */
@property(nonatomic, readonly, copy) NSArray<FIRSmartReplySuggestion *> *suggestions;

/** Status of the smart reply suggestions result. */
@property(nonatomic, readonly) FIRSmartReplyResultStatus status;

/**
 * Unavailable.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
