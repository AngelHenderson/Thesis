#!/bin/sh
set -e
set -u
set -o pipefail

if [ -z ${FRAMEWORKS_FOLDER_PATH+x} ]; then
    # If FRAMEWORKS_FOLDER_PATH is not set, then there's nowhere for us to copy
    # frameworks to, so exit 0 (signalling the script phase was successful).
    exit 0
fi

echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

COCOAPODS_PARALLEL_CODE_SIGN="${COCOAPODS_PARALLEL_CODE_SIGN:-false}"
SWIFT_STDLIB_PATH="${DT_TOOLCHAIN_DIR}/usr/lib/swift/${PLATFORM_NAME}"

# Used as a return value for each invocation of `strip_invalid_archs` function.
STRIP_BINARY_RETVAL=0

# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

# Copies and strips a vendored framework
install_framework()
{
  if [ -r "${BUILT_PRODUCTS_DIR}/$1" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$1"
  elif [ -r "${BUILT_PRODUCTS_DIR}/$(basename "$1")" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$(basename "$1")"
  elif [ -r "$1" ]; then
    local source="$1"
  fi

  local destination="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

  if [ -L "${source}" ]; then
      echo "Symlinked..."
      source="$(readlink "${source}")"
  fi

  # Use filter instead of exclude so missing patterns don't throw errors.
  echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${source}\" \"${destination}\""
  rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${source}" "${destination}"

  local basename
  basename="$(basename -s .framework "$1")"
  binary="${destination}/${basename}.framework/${basename}"
  if ! [ -r "$binary" ]; then
    binary="${destination}/${basename}"
  fi

  # Strip invalid architectures so "fat" simulator / device frameworks work on device
  if [[ "$(file "$binary")" == *"dynamically linked shared library"* ]]; then
    strip_invalid_archs "$binary"
  fi

  # Resign the code if required by the build settings to avoid unstable apps
  code_sign_if_enabled "${destination}/$(basename "$1")"

  # Embed linked Swift runtime libraries. No longer necessary as of Xcode 7.
  if [ "${XCODE_VERSION_MAJOR}" -lt 7 ]; then
    local swift_runtime_libs
    swift_runtime_libs=$(xcrun otool -LX "$binary" | grep --color=never @rpath/libswift | sed -E s/@rpath\\/\(.+dylib\).*/\\1/g | uniq -u  && exit ${PIPESTATUS[0]})
    for lib in $swift_runtime_libs; do
      echo "rsync -auv \"${SWIFT_STDLIB_PATH}/${lib}\" \"${destination}\""
      rsync -auv "${SWIFT_STDLIB_PATH}/${lib}" "${destination}"
      code_sign_if_enabled "${destination}/${lib}"
    done
  fi
}

# Copies and strips a vendored dSYM
install_dsym() {
  local source="$1"
  if [ -r "$source" ]; then
    # Copy the dSYM into a the targets temp dir.
    echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${source}\" \"${DERIVED_FILES_DIR}\""
    rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${source}" "${DERIVED_FILES_DIR}"

    local basename
    basename="$(basename -s .framework.dSYM "$source")"
    binary="${DERIVED_FILES_DIR}/${basename}.framework.dSYM/Contents/Resources/DWARF/${basename}"

    # Strip invalid architectures so "fat" simulator / device frameworks work on device
    if [[ "$(file "$binary")" == *"Mach-O dSYM companion"* ]]; then
      strip_invalid_archs "$binary"
    fi

    if [[ $STRIP_BINARY_RETVAL == 1 ]]; then
      # Move the stripped file into its final destination.
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${DERIVED_FILES_DIR}/${basename}.framework.dSYM\" \"${DWARF_DSYM_FOLDER_PATH}\""
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${DERIVED_FILES_DIR}/${basename}.framework.dSYM" "${DWARF_DSYM_FOLDER_PATH}"
    else
      # The dSYM was not stripped at all, in this case touch a fake folder so the input/output paths from Xcode do not reexecute this script because the file is missing.
      touch "${DWARF_DSYM_FOLDER_PATH}/${basename}.framework.dSYM"
    fi
  fi
}

# Signs a framework with the provided identity
code_sign_if_enabled() {
  if [ -n "${EXPANDED_CODE_SIGN_IDENTITY}" -a "${CODE_SIGNING_REQUIRED:-}" != "NO" -a "${CODE_SIGNING_ALLOWED}" != "NO" ]; then
    # Use the current code_sign_identitiy
    echo "Code Signing $1 with Identity ${EXPANDED_CODE_SIGN_IDENTITY_NAME}"
    local code_sign_cmd="/usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} ${OTHER_CODE_SIGN_FLAGS:-} --preserve-metadata=identifier,entitlements '$1'"

    if [ "${COCOAPODS_PARALLEL_CODE_SIGN}" == "true" ]; then
      code_sign_cmd="$code_sign_cmd &"
    fi
    echo "$code_sign_cmd"
    eval "$code_sign_cmd"
  fi
}

# Strip invalid architectures
strip_invalid_archs() {
  binary="$1"
  # Get architectures for current target binary
  binary_archs="$(lipo -info "$binary" | rev | cut -d ':' -f1 | awk '{$1=$1;print}' | rev)"
  # Intersect them with the architectures we are building for
  intersected_archs="$(echo ${ARCHS[@]} ${binary_archs[@]} | tr ' ' '\n' | sort | uniq -d)"
  # If there are no archs supported by this binary then warn the user
  if [[ -z "$intersected_archs" ]]; then
    echo "warning: [CP] Vendored binary '$binary' contains architectures ($binary_archs) none of which match the current build architectures ($ARCHS)."
    STRIP_BINARY_RETVAL=0
    return
  fi
  stripped=""
  for arch in $binary_archs; do
    if ! [[ "${ARCHS}" == *"$arch"* ]]; then
      # Strip non-valid architectures in-place
      lipo -remove "$arch" -output "$binary" "$binary" || exit 1
      stripped="$stripped $arch"
    fi
  done
  if [[ "$stripped" ]]; then
    echo "Stripped $binary of architectures:$stripped"
  fi
  STRIP_BINARY_RETVAL=1
}


if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_framework "${BUILT_PRODUCTS_DIR}/AAObnoxiousFilter/AAObnoxiousFilter.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AAProfanityFilter/AAProfanityFilter.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AEAppVersion/AEAppVersion.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AFNetworking/AFNetworking.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AISphereView/AISphereView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ARCL/ARCL.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ASPCircleChart/ASPCircleChart.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ActiveLabel/ActiveLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Alamofire/Alamofire.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AlamofireImage/AlamofireImage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AppAuth/AppAuth.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/BRYXBanner/BRYXBanner.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/BadgeSwift/BadgeSwift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Bartinter/Bartinter.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/BoringSSL-GRPC/openssl_grpc.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Cache/Cache.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/CircleProgressView/CircleProgressView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Closures/Closures.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Comets/Comets.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Cosmos/Cosmos.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/DWAnimatedLabel/DWAnimatedLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/DeckTransition/DeckTransition.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/EFAutoScrollLabel/EFAutoScrollLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/EKCollectionLayout/EKCollectionLayout.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/EKLongPress/EKLongPress.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/EasySocialButton/EasySocialButton.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/EmptyStateKit/EmptyStateKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FBSDKCoreKit/FBSDKCoreKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FBSDKLoginKit/FBSDKLoginKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FBSDKShareKit/FBSDKShareKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FaceAware/FaceAware.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FaveButton/FaveButton.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GTMAppAuth/GTMAppAuth.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GTMSessionFetcher/GTMSessionFetcher.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleAPIClientForREST/GoogleAPIClientForREST.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleToolboxForMac/GoogleToolboxForMac.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleUtilities/GoogleUtilities.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/IQKeyboardManagerSwift/IQKeyboardManagerSwift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Imaginary/Imaginary.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/IoniconsKit/IoniconsKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/KeychainSwift/KeychainSwift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Kingfisher/Kingfisher.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/LTMorphingLabel/LTMorphingLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Lumina/Lumina.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MDFInternationalization/MDFInternationalization.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MDFTextAccessibility/MDFTextAccessibility.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MKRingProgressView/MKRingProgressView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MSPeekCollectionViewDelegateImplementation/MSPeekCollectionViewDelegateImplementation.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Magnetic/Magnetic.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MaterialComponents/MaterialComponents.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Menu/Menu.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MetalPetal/MetalPetal.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/NDAudioSuite/NDAudioSuite.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/NSFWDetector/NSFWDetector.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/NVPictureInPicture/NVPictureInPicture.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/NextGrowingTextView/NextGrowingTextView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Observable/Observable.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PictureInPicture/PictureInPicture.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PixelEditor/PixelEditor.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PixelEngine/PixelEngine.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PromisesObjC/FBLPromises.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Protobuf/protobuf.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/RadarChart/RadarChart.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ReachabilitySwift/Reachability.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Repeat/Repeat.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ResizingTokenField/ResizingTokenField.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/RingGraph/RingGraph.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SFSymbol/SFSymbol.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SPAlert/SPAlert.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SizeClasser/SizeClasser.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SnapKit/SnapKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SnapLikeCollectionView/SnapLikeCollectionView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftChart/SwiftChart.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftConfettiView/SwiftConfettiView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftDate/SwiftDate.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftSiriWaveformView/SwiftSiriWaveformView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwifterSwift/SwifterSwift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyJSON/SwiftyJSON.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyMenu/SwiftyMenu.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TKSwitcherCollection/TKSwitcherCollection.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TagListView/TagListView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TemporaryAlert/TemporaryAlert.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Times/Times.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TransitionCoordinator/TransitionCoordinator.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TransitionPatch/TransitionPatch.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TransitionableTab/TransitionableTab.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/UIImageColors/UIImageColors.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/VegaScrollFlowLayoutX/VegaScrollFlowLayoutX.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ViewAnimator/ViewAnimator.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/WeScan/WeScan.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/WhatsNewKit/WhatsNewKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/YUDisplacementTransition/YUDisplacementTransition.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/abseil/absl.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/gRPC-C++/grpcpp.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/gRPC-Core/grpc.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/gooey-cell/gooey_cell.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/imglyKit2/imglyKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/leveldb-library/leveldb.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/lottie-ios/Lottie.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/nanopb/nanopb.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/pop/pop.framework"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_framework "${BUILT_PRODUCTS_DIR}/AAObnoxiousFilter/AAObnoxiousFilter.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AAProfanityFilter/AAProfanityFilter.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AEAppVersion/AEAppVersion.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AFNetworking/AFNetworking.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AISphereView/AISphereView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ARCL/ARCL.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ASPCircleChart/ASPCircleChart.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ActiveLabel/ActiveLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Alamofire/Alamofire.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AlamofireImage/AlamofireImage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AppAuth/AppAuth.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/BRYXBanner/BRYXBanner.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/BadgeSwift/BadgeSwift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Bartinter/Bartinter.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/BoringSSL-GRPC/openssl_grpc.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Cache/Cache.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/CircleProgressView/CircleProgressView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Closures/Closures.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Comets/Comets.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Cosmos/Cosmos.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/DWAnimatedLabel/DWAnimatedLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/DeckTransition/DeckTransition.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/EFAutoScrollLabel/EFAutoScrollLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/EKCollectionLayout/EKCollectionLayout.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/EKLongPress/EKLongPress.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/EasySocialButton/EasySocialButton.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/EmptyStateKit/EmptyStateKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FBSDKCoreKit/FBSDKCoreKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FBSDKLoginKit/FBSDKLoginKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FBSDKShareKit/FBSDKShareKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FaceAware/FaceAware.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FaveButton/FaveButton.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GTMAppAuth/GTMAppAuth.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GTMSessionFetcher/GTMSessionFetcher.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleAPIClientForREST/GoogleAPIClientForREST.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleToolboxForMac/GoogleToolboxForMac.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleUtilities/GoogleUtilities.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/IQKeyboardManagerSwift/IQKeyboardManagerSwift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Imaginary/Imaginary.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/IoniconsKit/IoniconsKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/KeychainSwift/KeychainSwift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Kingfisher/Kingfisher.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/LTMorphingLabel/LTMorphingLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Lumina/Lumina.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MDFInternationalization/MDFInternationalization.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MDFTextAccessibility/MDFTextAccessibility.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MKRingProgressView/MKRingProgressView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MSPeekCollectionViewDelegateImplementation/MSPeekCollectionViewDelegateImplementation.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Magnetic/Magnetic.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MaterialComponents/MaterialComponents.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Menu/Menu.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MetalPetal/MetalPetal.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/NDAudioSuite/NDAudioSuite.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/NSFWDetector/NSFWDetector.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/NVPictureInPicture/NVPictureInPicture.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/NextGrowingTextView/NextGrowingTextView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Observable/Observable.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PictureInPicture/PictureInPicture.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PixelEditor/PixelEditor.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PixelEngine/PixelEngine.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PromisesObjC/FBLPromises.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Protobuf/protobuf.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/RadarChart/RadarChart.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ReachabilitySwift/Reachability.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Repeat/Repeat.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ResizingTokenField/ResizingTokenField.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/RingGraph/RingGraph.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SFSymbol/SFSymbol.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SPAlert/SPAlert.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SizeClasser/SizeClasser.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SnapKit/SnapKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SnapLikeCollectionView/SnapLikeCollectionView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftChart/SwiftChart.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftConfettiView/SwiftConfettiView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftDate/SwiftDate.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftSiriWaveformView/SwiftSiriWaveformView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwifterSwift/SwifterSwift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyJSON/SwiftyJSON.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyMenu/SwiftyMenu.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TKSwitcherCollection/TKSwitcherCollection.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TagListView/TagListView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TemporaryAlert/TemporaryAlert.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Times/Times.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TransitionCoordinator/TransitionCoordinator.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TransitionPatch/TransitionPatch.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TransitionableTab/TransitionableTab.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/UIImageColors/UIImageColors.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/VegaScrollFlowLayoutX/VegaScrollFlowLayoutX.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ViewAnimator/ViewAnimator.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/WeScan/WeScan.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/WhatsNewKit/WhatsNewKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/YUDisplacementTransition/YUDisplacementTransition.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/abseil/absl.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/gRPC-C++/grpcpp.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/gRPC-Core/grpc.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/gooey-cell/gooey_cell.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/imglyKit2/imglyKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/leveldb-library/leveldb.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/lottie-ios/Lottie.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/nanopb/nanopb.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/pop/pop.framework"
fi
if [ "${COCOAPODS_PARALLEL_CODE_SIGN}" == "true" ]; then
  wait
fi
