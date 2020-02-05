#import <Foundation/Foundation.h>

@class FIRSmartReplySuggestionResult;
@class FIRTextMessage;

NS_ASSUME_NONNULL_BEGIN

/**
 * A block containing a suggestion result or `nil` if there's an error.
 *
 * @param result A suggestion result for the text or `nil` if there's an error.
 * @param error The error or `nil`.
 */
typedef void (^FIRSmartReplyCallback)(FIRSmartReplySuggestionResult *_Nullable result,
                                      NSError *_Nullable error) NS_SWIFT_NAME(SmartReplyCallback);

/**
 * An object that suggests smart replies for given input text.
 */
NS_SWIFT_NAME(SmartReply)
@interface FIRSmartReply : NSObject

/**
 * Unavailable.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Suggests replies in the context of a chat conversation.
 *
 * @param messages The sequence of chat messages to generate a suggestion for.
 * @param completion Handler to call back on the main queue with the suggestion result or error.
 */
- (void)suggestRepliesForMessages:(NSArray<FIRTextMessage *> *)messages
                completion:(FIRSmartReplyCallback)completion
    NS_SWIFT_NAME(suggestReplies(for:completion:));

@end

NS_ASSUME_NONNULL_END
