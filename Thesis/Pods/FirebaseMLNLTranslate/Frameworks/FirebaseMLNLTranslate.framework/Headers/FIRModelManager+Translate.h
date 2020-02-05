
#import <FirebaseMLCommon/FirebaseMLCommon.h>


@class FIRTranslateRemoteModel;

NS_ASSUME_NONNULL_BEGIN

/** Extensions to `ModelManager` for Translate-specific functionality. */
@interface FIRModelManager (Translate)

/**
 * A set of already-downloaded translate models (including built-in models, currently only English).
 * These models can be then deleted through `ModelManager`'s `deleteDownloadedModel(_:completion:)`
 * API to manage disk space.
 */
@property(nonatomic, readonly) NSSet<FIRTranslateRemoteModel *> *downloadedTranslateModels;

@end

NS_ASSUME_NONNULL_END
