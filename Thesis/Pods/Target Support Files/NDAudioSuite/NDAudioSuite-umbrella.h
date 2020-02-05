#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Constants.h"
#import "NDAudioDownloadManager.h"
#import "NDAudioPlayer.h"
#import "NSMutableArray+Shuffling.h"

FOUNDATION_EXPORT double NDAudioSuiteVersionNumber;
FOUNDATION_EXPORT const unsigned char NDAudioSuiteVersionString[];

