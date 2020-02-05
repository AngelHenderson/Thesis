

#import <FirebaseMLNaturalLanguage/FirebaseMLNaturalLanguage.h>



@class FIRSmartReply;

NS_ASSUME_NONNULL_BEGIN

@interface FIRNaturalLanguage (SmartReply)

/**
 * Gets a smart reply instance that provides suggested replies for input text in English. This
 * method is thread safe.
 *
 * @return A `SmartReply` instance that provides suggested replies.
 */
- (FIRSmartReply *)smartReply;

@end

NS_ASSUME_NONNULL_END
