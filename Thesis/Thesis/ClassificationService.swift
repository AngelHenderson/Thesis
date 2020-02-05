import CoreML
import Vision

/// Delegate protocol used for `ClassificationService`
protocol ClassificationServiceDelegate: class {
  func classificationService(_ service: ClassificationService, didDetectGender gender: String)
  func classificationService(_ service: ClassificationService, didDetectAge age: String)
  func classificationService(_ service: ClassificationService, didDetectEmotion emotion: String)
}

/// Service used to perform gender, age and emotion classification
final class ClassificationService: ClassificationServiceProtocol {
  /// The service's delegate
  weak var delegate: ClassificationServiceDelegate?
  /// Array of vision requests
  private var requests = [VNRequest]()

  /// Create CoreML model and classification requests
  func setup() {
    do {
      // Gender request
      requests.append(VNCoreMLRequest(
        model: try VNCoreMLModel(for: GenderNet().model),
        completionHandler: handleGenderClassification
      ))
      // Age request
      requests.append(VNCoreMLRequest(
        model: try VNCoreMLModel(for: AgeNet().model),
        completionHandler: handleAgeClassification
      ))
      // Emotions request
      requests.append(VNCoreMLRequest(
        model: try VNCoreMLModel(for: CNNEmotions().model),
        completionHandler: handleEmotionClassification
      ))
        
//      requests.append(VNCoreMLRequest(
//        model: try VNCoreMLModel(for: Oxford102().model),
//        completionHandler: handleClassification
//      ))
    } catch {
      assertionFailure("Can't load Vision ML model: \(error)")
    }
  }

  /// Run individual requests one by one.
  func classify(image: CIImage) {
    do {
      for request in self.requests {
        let handler = VNImageRequestHandler(ciImage: image)
        try handler.perform([request])
      }
    } catch {
      print(error)
    }
  }


    private let model = SentimentPolarity()
    private let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther]
    private lazy var tagger: NSLinguisticTagger = .init( tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"), options: Int(self.options.rawValue))

    // MARK: - Prediction

    func predictSentiment(from text: String) -> Sentiment {
      do {
        let inputFeatures = features(from: text)
        // Make prediction only with 2 or more words
        guard inputFeatures.count > 1 else {
          return .neutral
        }

        let output = try model.prediction(input: inputFeatures)

        switch output.classLabel {
        case "Pos":
          return .positive
        case "Neg":
          return .negative
        default:
          return .neutral
        }
      } catch {
        return .neutral
      }
    }
    
    
  // MARK: - Handling

  @objc private func handleGenderClassification(request: VNRequest, error: Error?) {
    let result = extractClassificationResult(from: request, count: 1)
    delegate?.classificationService(self, didDetectGender: result)
  }

  @objc private func handleAgeClassification(request: VNRequest, error: Error?) {
    let result = extractClassificationResult(from: request, count: 1)
    delegate?.classificationService(self, didDetectAge: result)
  }

  @objc private func handleEmotionClassification(request: VNRequest, error: Error?) {
    let result = extractClassificationResult(from: request, count: 1)
    delegate?.classificationService(self, didDetectEmotion: result)
  }
}


// MARK: - Features

private extension ClassificationService {
  func features(from text: String) -> [String: Double] {
    var wordCounts = [String: Double]()

    tagger.string = text
    let range = NSRange(location: 0, length: text.utf16.count)

    // Tokenize and count the sentence
    tagger.enumerateTags(in: range, scheme: .nameType, options: options) { _, tokenRange, _, _ in
      let token = (text as NSString).substring(with: tokenRange).lowercased()
      // Skip small words
      guard token.count >= 3 else {
        return
      }

      if let value = wordCounts[token] {
        wordCounts[token] = value + 1.0
      } else {
        wordCounts[token] = 1.0
      }
    }

    return wordCounts
  }
}

enum Sentiment {
  case neutral
  case positive
  case negative

  var emoji: String {
    switch self {
    case .neutral:
      return "Neutral"
    case .positive:
      return "Positive"
    case .negative:
      return "Negative"
    }
  }

  var color: UIColor? {
    switch self {
    case .neutral:
      return UIColor(named: "NeutralColor")
    case .positive:
      return UIColor(named: "PositiveColor")
    case .negative:
      return UIColor(named: "NegativeColor")
    }
  }
}
