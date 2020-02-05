//
//  MLKit.swift
//  Alpha
//
//  Created by Angel Henderson on 7/15/19.
//  Copyright © 2019 ArcDNA Inc. All rights reserved.
//

import Foundation
import NSFWDetector
import AVKit
import Vision
import AAObnoxiousFilter
import AAProfanityFilter
import NaturalLanguage
import Firebase
import FirebaseMLNLLanguageID
import FirebaseMLNLSmartReply
import FirebaseMLVisionObjectDetection
import UIImageColors


//MARK: - COMPUTER VISION

//MARK: - Image Color

func fetchImageColors(image: UIImage, completion: @escaping (_ result: UIImageColors) -> ()){
    image.getColors { colors in
        if let colors = colors {
            completion(colors)
        }
    }
}


//MARK: - Image Sentiment


//MARK: - Object Tracking with Firebase MLKit

//https://firebase.google.com/docs/ml-kit/ios/detect-objects

func liveDetectionOfObjectStreamMLKit(image: UIImage){
    // Live detection and tracking
    let options = VisionObjectDetectorOptions()
    options.detectorMode = .stream
    options.shouldEnableMultipleObjects = true
    options.shouldEnableClassification = true
    
    // Define the metadata for the image.
    let imageMetadata = VisionImageMetadata()
    imageMetadata.orientation = UIUtilities.visionImageOrientation(from: image.imageOrientation)
    
    // Initialize a VisionImage object with the given UIImage.
    let visionImage = VisionImage(image: image)
    visionImage.metadata = imageMetadata

    detectObjectsOnDevice(visionImage: visionImage, options: options)
}

func liveDetectionOfObjectImageMLKit(image: UIImage){
    // Live detection and tracking
    let options = VisionObjectDetectorOptions()
    options.detectorMode = .singleImage
    options.shouldEnableMultipleObjects = true
    options.shouldEnableClassification = true
    
    // Define the metadata for the image.
    let imageMetadata = VisionImageMetadata()
    imageMetadata.orientation = UIUtilities.visionImageOrientation(from: image.imageOrientation)
    
    // Initialize a VisionImage object with the given UIImage.
    let visionImage = VisionImage(image: image)
    visionImage.metadata = imageMetadata
    
    detectObjectsOnDevice(visionImage: visionImage, options: options)
}

func liveDetectionOfObjectStreamMLKit(buffer: CMSampleBuffer){
    // Live detection and tracking
    let options = VisionObjectDetectorOptions()
    options.detectorMode = .stream
    options.shouldEnableMultipleObjects = true
    options.shouldEnableClassification = true
   
    // Define the metadata for the image.
    let imageMetadata = VisionImageMetadata()
    let cameraPosition = AVCaptureDevice.Position.back  // Set to the capture device you used.
    imageMetadata.orientation = imageOrientation(deviceOrientation: UIDevice.current.orientation,cameraPosition: cameraPosition)
    
    // Initialize a VisionImage object with the given UIImage.
    let visionImage = VisionImage(buffer: buffer)
    visionImage.metadata = imageMetadata
    
    detectObjectsOnDevice(visionImage: visionImage, options: options)
}

func liveDetectionOfObjectImageMLKit(buffer: CMSampleBuffer){
    // Live detection and tracking
    let options = VisionObjectDetectorOptions()
    options.detectorMode = .singleImage
    options.shouldEnableMultipleObjects = true
    options.shouldEnableClassification = true
    
    // Define the metadata for the image.
    let imageMetadata = VisionImageMetadata()
    let cameraPosition = AVCaptureDevice.Position.back  // Set to the capture device you used.
    imageMetadata.orientation = imageOrientation(deviceOrientation: UIDevice.current.orientation,cameraPosition: cameraPosition)
    
    // Initialize a VisionImage object with the given UIImage.
    let visionImage = VisionImage(buffer: buffer)
    visionImage.metadata = imageMetadata
    
    detectObjectsOnDevice(visionImage: visionImage, options: options)
}

func detectObjectsOnDevice(visionImage: VisionImage, options: VisionObjectDetectorOptions){
    let objectDetector = Vision.vision().objectDetector(options: options)
    
    objectDetector.process(visionImage) { detectedObjects, error in
      guard error == nil else {
        // Error.
        return
      }
      guard let detectedObjects = detectedObjects, !detectedObjects.isEmpty else {
        // No objects detected.
        return
      }

      // Success. Get object info here.
      // detectedObjects contains one item if multiple object detection wasn't enabled.
      for obj in detectedObjects {
        let frame = obj.frame
        let id = obj.trackingID

        // If classification was enabled:
        let category = obj.classificationCategory
        let confidence = obj.confidence
      }
    }
}


//MARK: - Image Labels with Firebase MLKit

//https://firebase.google.com/docs/ml-kit/ios/label-images

extension UIImage {
    
    //You can use ML Kit to label objects recognized in an image, using either an on-device model or a cloud model.
    
    func detectImageLabelsMLKit(){
//      let labeler = Vision.vision().onDeviceImageLabeler()
        let options = VisionOnDeviceImageLabelerOptions()
        options.confidenceThreshold = 0.7
        let onDeviceLabeler = Vision.vision().onDeviceImageLabeler(options: options)
        
        // Define the metadata for the image.
        let imageMetadata = VisionImageMetadata()
        imageMetadata.orientation = UIUtilities.visionImageOrientation(from: self.imageOrientation)
        
        // Initialize a VisionImage object with the given UIImage.
        let visionImage = VisionImage(image: self)
        visionImage.metadata = imageMetadata
        
        onDeviceLabeler.process(visionImage) { labels, error in
            guard error == nil, let labels = labels else { return }

            // Task succeeded.
            for label in labels {
                let labelText = label.text
                let entityId = label.entityID
                let confidence = label.confidence
            }
        }
    }
}

extension CMSampleBuffer {
    
    //You can use ML Kit to label objects recognized in an image, using either an on-device model or a cloud model.

    func detectImageLabelsMLKit(){
//      let labeler = Vision.vision().onDeviceImageLabeler()
        let options = VisionOnDeviceImageLabelerOptions()
        options.confidenceThreshold = 0.7
        let onDeviceLabeler = Vision.vision().onDeviceImageLabeler(options: options)
        
        // Define the metadata for the image.
        let imageMetadata = VisionImageMetadata()
        let cameraPosition = AVCaptureDevice.Position.back  // Set to the capture device you used.
        imageMetadata.orientation = imageOrientation(deviceOrientation: UIDevice.current.orientation,cameraPosition: cameraPosition)
        
        // Initialize a VisionImage object with the given UIImage.
        let visionImage = VisionImage(buffer: self)
        visionImage.metadata = imageMetadata
                
        onDeviceLabeler.process(visionImage) { labels, error in
            guard error == nil, let labels = labels else { return }

            // Task succeeded.
            for label in labels {
                let labelText = label.text
                let entityId = label.entityID
                let confidence = label.confidence
            }
        }
    }
}

func imageOrientation(
    deviceOrientation: UIDeviceOrientation,
    cameraPosition: AVCaptureDevice.Position
    ) -> VisionDetectorImageOrientation {
    switch deviceOrientation {
    case .portrait:
        return cameraPosition == .front ? .leftTop : .rightTop
    case .landscapeLeft:
        return cameraPosition == .front ? .bottomLeft : .topLeft
    case .portraitUpsideDown:
        return cameraPosition == .front ? .rightBottom : .leftBottom
    case .landscapeRight:
        return cameraPosition == .front ? .topRight : .bottomRight
    case .faceDown, .faceUp, .unknown:
        return .leftTop
    @unknown default:
        return .leftTop
    }
}

//MARK: - Food Classification

func foodClassificationwithCoreML(image: UIImage, completion: @escaping (_ result: Food101Output) -> ()) {

    let resizableImage = CoreMLHelper.resizableImageForModel(image: image, size: CGSize(width: 299, height: 299))
    guard let pixelBuffer = resizableImage.pixelBuffer else {return}
    
    let model = Food101()

    // Get model prediction
    guard let prediction = try? model.prediction(image: pixelBuffer) else {return}
    
    // Display results
    print("I think this is a \(prediction.classLabel)")
    
    completion(prediction)
}


//MARK: - Animal Classification

//https://github.com/dingtianran/CatDog
//https://medium.com/swlh/ios-vision-cat-vs-dog-image-classifier-in-5-minutes-f9fd6f264762

func animalClassificationwithCoreML() -> VNRecognizeAnimalsRequest {

    let request = VNRecognizeAnimalsRequest(completionHandler:  {(request, error) in
        guard let observations = request.results as? [VNRecognizedObjectObservation] else {return}
    })
    
    return request
}


//MARK: - Face Detection

//https://github.com/Willjay90/AppleFaceDetection


//MARK: - AAProfanityFilter

extension String {
    func mlFilterProfanity() -> String {
        return self.aa_profanityFiltered()
    }
}

//MARK: - AAObnoxiousFilter

//https://github.com/EngrAhsanAli/AAObnoxiousFilter

extension UIImage {

    func detectPhoto(image: UIImage)  -> String {
        if let prediction = self.predictImage() {
            return String(format: "%.6f", prediction)
        }
        else {
            return "Something went wrong with the provided image"
        }
    }
    
    public func predictImage() -> Double? {
        return AAObnoxiousFilter.shared.predict(self)
    }
    
    func buffer() -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer? = nil
        
        let width = 224
        let height = 224
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue:0))
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let bitmapContext = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer!), width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: colorspace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)!
        
        bitmapContext.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return pixelBuffer
    }
    
        
    //MARK: - Nudity Engine

    //https://github.com/ph1ps/Nudity-CoreML

    func nudityEngineDetection() -> String {
        let model = Nudity()
        let size = CGSize(width: 224, height: 224)

        guard let buffer = self.resize(to: size)?.pixelBuffer() else {
            fatalError("Scaling or converting to pixel buffer failed!")
        }
        
        guard let result = try? model.prediction(data: buffer) else {
            fatalError("Prediction failed!")
        }
        
        let confidence = result.prob["\(result.classLabel)"]! * 100.0
        let converted = String(format: "%.2f", confidence)
        
        //SFW - 54.04%
        //NSFW - 54.04%
        return "\(result.classLabel) - \(converted) %"
    }
}


//MARK: - NSFWDetector

//https://github.com/lovoo/NSFWDetector

var subsequentPositiveDetections = 0

func nsfwDetectorEngineDetection(image: UIImage) {
    
    NSFWDetector.shared.check(image: image, completion: { result in
        switch result {
        case let .success(nsfwConfidence: confidence):
            if confidence > 0.9 {
                let string = String(format: "%.1f %% porn", confidence * 100.0)
                print("\(string)")
                // 😱🙈😏
            } else {
                let string = String(format: "%.1f %% porn", confidence * 100.0)
                print("\(string)")
                // ¯\_(ツ)_/¯
            }
        default:
            break
        }
    })
}

func nsfwDetectorEngineDetection(sampleBuffer: CMSampleBuffer) {
    
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
    
    NSFWDetector.shared.check(cvPixelbuffer: pixelBuffer) { result in
        if case let .success(nsfwConfidence: confidence) = result {
            DispatchQueue.main.async {
                didDetectNSFW(confidence: confidence)
            }
        }
    }
}

func didDetectNSFW(confidence: Float) {
    if confidence > 0.8 {
        subsequentPositiveDetections += 1
        guard subsequentPositiveDetections > 3 else {return}
        //self.showAlarmView()
    } else {
        subsequentPositiveDetections = 0
        //self.hideAlarmView()
    }
    
    let string = String(format: "%.1f %% porn", confidence * 100.0)
    print("\(string)")

}


//MARK: - Text Sentiment Analysis (Apple)

//https://www.hackingwithswift.com/example-code/naturallanguage/how-to-perform-sentiment-analysis-on-a-string-using-nltagger

extension String {
    
    func sentimentAnalysis(text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore, .language]) // feed it into the NaturalLanguage framework
        tagger.string = text
        
        let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore) // ask for the results

        // read the sentiment back and print it
        let score = Double(sentiment?.rawValue ?? "0") ?? 0
        print(score)
        
        //The end result will be a score value that is somewhere between -1.0 (very negative) and 1.0 (very positive), or 0.0 if the text is neutral or nothing could be read.
        return score
    }
}

func sentimentAnalysis(text: String) -> Double {
    let tagger = NLTagger(tagSchemes: [.sentimentScore, .language]) // feed it into the NaturalLanguage framework
    tagger.string = text
    
    let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore) // ask for the results

    // read the sentiment back and print it
    let score = Double(sentiment?.rawValue ?? "0") ?? 0
    print(score)
    
    //The end result will be a score value that is somewhere between -1.0 (very negative) and 1.0 (very positive), or 0.0 if the text is neutral or nothing could be read.
    return score
}

//MARK: Text Sentiment Analysis


//https://github.com/VamshiIITBHU14/VKSentimentAnalysis


//MARK: - Language Analysis by CoreML

//https://nshipster.com/nllanguagerecognizer/


extension String {
    //In order to be understood, we first must seek to understand. And the first step to understanding natural language is to determine its language.

    //, completion: @escaping (_ result: UIImageColors) -> ()
    
    func languageAnalysisCoreML() -> NLLanguage? {
        print("languageAnalysisCoreML: \(self)")
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(self)
        //recognizer.languageHints = [.danish: 0.25, .norwegian: 0.75] //Optional Hints, creates bias
        return recognizer.dominantLanguage
    }
    
    func languageHypothesesAnalysisCoreML(text: String) -> [NLLanguage : Double] {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        return recognizer.languageHypotheses(withMaximum: 2)
    }
}

//MARK: - Language Analysis by Firebase MLKit

//https://firebase.google.com/docs/ml-kit/ios/identify-languages

extension String {
    //In order to be understood, we first must seek to understand. And the first step to understanding natural language is to determine its language.
    
    func languageAnalysisMLKit(completion: @escaping (_ result: String) -> ()) {
        let options = LanguageIdentificationOptions(confidenceThreshold: 0.5) //By Default
        let languageId = NaturalLanguage.naturalLanguage().languageIdentification(options: options)
        languageId.identifyLanguage(for: self) { (languageCode, error) in
          if let error = error {
            print("Failed with error: \(error)")
            return
          }
          if let languageCode = languageCode, languageCode != "und" {
            print("Identified Language: \(languageCode)")
            completion("Language Code \(languageCode)")
          } else {
            completion("No language was identified")
            print("No language was identified")
          }
        }
    }
}

//MARK: - Identify Possible languages by Firebase MLKit

extension String {
    //https://firebase.google.com/docs/ml-kit/langid-support
    func languageHypothesesAnalysisMLKit(){
        let options = LanguageIdentificationOptions(confidenceThreshold: 0.4)
        let languageId = NaturalLanguage.naturalLanguage().languageIdentification(options: options)
        
        languageId.identifyPossibleLanguages(for: self) { (identifiedLanguages, error) in
          if let error = error {
            print("Failed with error: \(error)")
            return
          }
          guard let identifiedLanguages = identifiedLanguages,
            !identifiedLanguages.isEmpty,
            identifiedLanguages[0].languageCode != "und" //Unidentified
          else {
            print("No language was identified")
            return
          }

          print("Identified Languages:\n" +
            identifiedLanguages.map {
              String(format: "(%@, %.2f)", $0.languageCode, $0.confidence)
              }.joined(separator: "\n"))
        }
    }
}

//MARK: - On-device Translation by Firebase MLKit

//https://firebase.google.com/docs/ml-kit/ios/translate-text

extension String {
    func translate(inputLanguage: TranslateLanguage, outputLanguage: TranslateLanguage) {
        let options = TranslatorOptions(sourceLanguage: inputLanguage, targetLanguage: outputLanguage)
        let translator: Translator = NaturalLanguage.naturalLanguage().translator(options: options)
        let conditions = ModelDownloadConditions(allowsCellularAccess: false, allowsBackgroundDownloading: true)
        
        translator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
            
            // Model downloaded successfully. Okay to start translating.
            translator.translate(self) { translatedText, error in
                guard error == nil, let translatedText = translatedText else { return }
                // Translation succeeded.
                print("Translated Text \(translatedText)")
            }
        }
        
        
    }
}



//MARK: - Synthesizing Speech with Language Recognition

//https://nshipster.com/nllanguagerecognizer/

extension String {
    func speak() {
        let speechSynthesizer = AVSpeechSynthesizer()
        let language =  self.languageAnalysisCoreML()?.rawValue
        print("SpeechSynthesizer Language: \(language)")
        let utterance = AVSpeechUtterance(string: self)
        utterance.voice = AVSpeechSynthesisVoice(language: language) //Speak in language
        speechSynthesizer.speak(utterance)
        print("SpeechSynthesizer Speaking: \(speechSynthesizer.isSpeaking)")

    }
}


//MARK: - Smart Reply by Firebase MLKit

//https://firebase.google.com/docs/ml-kit/generate-smart-replies

extension String {
    func createTextMessage(userID: String, localUser: Bool) -> TextMessage {
        let message = TextMessage(
        text: self,
        timestamp: Date().timeIntervalSince1970,
        userID: userID,
        isLocalUser: localUser)
        return message
    }
}

func smartReplies(conversation: [TextMessage]) {
    let naturalLanguage = NaturalLanguage.naturalLanguage()
    naturalLanguage.smartReply().suggestReplies(for: conversation) { result, error in
        guard error == nil, let result = result else {return}
        
        if (result.status == .notSupportedLanguage) {
            // The conversation's language isn't supported, so the
            // the result doesn't contain any suggestions.
        } else if (result.status == .success) {
            // Successfully suggested smart replies.
            for suggestion in result.suggestions {
              print("Suggested reply: \(suggestion.text)")
            }
        }
    }
}


