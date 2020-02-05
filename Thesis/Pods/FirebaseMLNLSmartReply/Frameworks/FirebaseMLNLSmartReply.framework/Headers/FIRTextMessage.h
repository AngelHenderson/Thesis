#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A single chat message, to be used as an array element for input to Smart Reply.
 */
NS_SWIFT_NAME(TextMessage)
@interface FIRTextMessage : NSObject

/**
 * Text of the chat message.
 */
@property(nonatomic, readonly) NSString *text;

/**
 * Timestamp of the chat message.
 */
@property(nonatomic, readonly) NSTimeInterval timestamp;

/**
 * User id of the message sender.
 */
@property(nonatomic, readonly) NSString *userID;

/**
 * Indicates whether this message is from the user that the suggestions are generated for.
 */
@property(nonatomic, readonly) BOOL isLocalUser;

/**
 * Constructs a chat message.
 *
 * @param text Chat message text
 * @param timestamp Time of message in seconds calculated from Unix Time.
 * @param userID User ID of the message sender.
 * @param isLocalUser Whether this message is from the user that the suggestions are generated for.
 */
- (instancetype)initWithText:(NSString *)text
                   timestamp:(NSTimeInterval)timestamp
                      userID:(NSString *)userID
                 isLocalUser:(BOOL)isLocalUser NS_DESIGNATED_INITIALIZER;

/**
 * Unavailable.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
