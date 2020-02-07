//
//  FirstViewController.swift
//  Thesis
//
//  Created by Angel Henderson on 2/4/20.
//  Copyright © 2020 Angel Henderson. All rights reserved.
//

import UIKit

import AVKit
import AVFoundation
import FDSoundActivatedRecorder

import MapKit
import CoreLocation

import Vision
import ImageIO

import CoreML
import SoundAnalysis



class FirstViewController: UIViewController {
    
    //Map Frameworks
    @IBOutlet weak var mapView: MKMapView!
    var myLatitude = ""
    var myLongitude = ""
    var locationManager: CLLocationManager!
    let annotation = MKPointAnnotation()
    var places = PredictionLocationList().place
    typealias Prediction = (String, Double)

    
    //Recording Frameworks
    let audioEngine = AVAudioEngine()
    var recorder = FDSoundActivatedRecorderMock()
    var savedURL: URL? = nil
    var player = AVPlayer()
    var sampleSquares: [UIView] = [] //Most recent are added to end
    let sampleSize: CGFloat = 10.0
    var audioFileAnalyzer: SNAudioFileAnalyzer!
    var inputFormat: AVAudioFormat!
    var analyzer: SNAudioStreamAnalyzer!
    var soundAnalyzer: SNAudioStreamAnalyzer!

    var resultsObserver = ResultsObserver()
    var genderResultsObserver = GenderResultsObserver()

    let analysisQueue = DispatchQueue(label: "com.custom.AnalysisQueue")

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var microphoneLevel: UILabel!
    
    //Bert Document
    var document: Document? {
        didSet {
            configureTextView()
        }
    }
    
    //User Interface
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var snappedImageView: UIImageView?
    @IBOutlet weak var mainImageView: UIImageView?
    @IBOutlet weak var heatmapView: DrawingHeatmapView!

    lazy var percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    
    //AI Views
    @IBOutlet var ageView: SegmentView?
    @IBOutlet var genderView: SegmentView?
    @IBOutlet var emotionView: SegmentView?
    @IBOutlet var classificationView: SegmentView?
    @IBOutlet var topicView: SegmentView?
    @IBOutlet var languageView: SegmentView?
    @IBOutlet var locationView: SegmentView?
    @IBOutlet var sentimentView: SegmentView?
    @IBOutlet var foodView: SegmentView?
    @IBOutlet var physicalView: SegmentView?
    @IBOutlet var placeView: SegmentView?
    @IBOutlet var soundAnalysisView: SegmentView?
    @IBOutlet var catDogAnalysisView: SegmentView?

    @IBOutlet var ageContainerView: UIView?
    @IBOutlet var genderContainerView: UIView?
    @IBOutlet var emotionContainerView: UIView?
    @IBOutlet var classificationContainerView: UIView?
    @IBOutlet var topicContainerView: UIView?
    @IBOutlet var languageContainerView: UIView?
    @IBOutlet var locationContainerView: UIView?
    @IBOutlet var sentimentContainerView: UIView?
    @IBOutlet var foodContainerView: UIView?
    @IBOutlet var physicalContainerView: UIView?
    @IBOutlet var placeContainerView: UIView?
    @IBOutlet var soundAnalysisContainerView: UIView?
    @IBOutlet var catDogContainerView: UIView?


    
    //TextView
    @IBOutlet weak var documentTextView: UITextView?
    @IBOutlet weak var inputTextView: DSTextView!
    
    //Buttons
    @IBOutlet weak var answerButton: UIButton?
    @IBOutlet weak var knowledgeButton: UIButton?
    @IBOutlet weak var analyzeButton: UIButton?
    
    @IBOutlet weak var micButton: UIBarButtonItem?
    @IBOutlet weak var photoButton: UIBarButtonItem?
    @IBOutlet weak var videoButton: UIBarButtonItem?




    //Classification Module
    public let classificationService: ClassificationService = ClassificationService.init()

    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: MobileNet().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    

    //CoreML Models
    let bert = BERT() //BERT

    let documentClassifier = DocumentClassifier() //Category
    let RN1015k500Classifier = RN1015k500() //Location Prediction and Classification
    typealias EstimationModel = model_cpm  //PoseNet
    var postProcessor: HeatmapPostProcessor = HeatmapPostProcessor() //HeatMap
    
    // Deep Residual Learning for Image Recognition
    // https://arxiv.org/abs/1512.03385
    let resnetModel = Resnet50()
    let mnistModel  = SimpleMnist()
    
    //Sound Analysis
    var soundClassifierModel: MLModel!
    var genderSoundClassifier = GenderSoundClassification()

    
    //On-Device Training

    var updatableModel : MLModel?
    
    @IBOutlet weak var btnTrainImages: UIButton?
    @IBOutlet weak var trainingImagesCount: UILabel?
    @IBOutlet weak var predicatedClassLabel: UILabel?
    @IBOutlet weak var btnToggleClassLabel: UIButton?
    var imageLabelDictionary : [UIImage:String] = [:]
    var imageConstraint: MLImageConstraint?

    var retrainImageCount = 0{
        didSet{
            if retrainImageCount == 0{
                trainingImagesCount?.text = ""
                btnTrainImages?.alpha = 0
            }
        }
    }
    
    // MARK: - Lifecycle


    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        
        answerButton?.onTap { [weak self] in
            self?.answerQuestion()
        }
        
        photoButton?.onTap { [weak self] in
            self?.hideAllSections()
            self?.handleSelectPhotoTap()
        }
        
        analyzeButton?.onTap { [weak self] in
            self?.hideAllSections()
            guard let text = self?.documentTextView?.text else {return}
            self?.predictTopic(text)
            if let sentiment = self?.classificationService.predictSentiment(from: text){
                self?.predictSentiment(sentiment: sentiment, text: text)
            }
            text.languageAnalysisMLKit(){ string in
                self?.languageView?.subtitleLabel?.text = string
            }
        }
        
        
        do{
        
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
            let fileURL = documentDirectory.appendingPathComponent("CatDog.mlmodelc")
            if let model = loadModel(url: fileURL){
                updatableModel = model
            }
            else{
                if let modelURL = Bundle.main.url(forResource: "CatDogUpdatable", withExtension: "mlmodelc"){
                    if let model = loadModel(url: modelURL){
                        updatableModel = model
                    }
                }
            }

            if let updatableModel = updatableModel{
                imageConstraint = self.getImageConstraint(model: updatableModel)
            }
    
        }catch(let error){
            print("initial error is \(error.localizedDescription)")
        }
        
        btnToggleClassLabel?.alpha = 0

            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAudioEngine()

    }
    
    
    // MARK: - Actions

    @objc func handleSelectPhotoTap() {
      let sourcePicker = PhotoSourceController()
      sourcePicker.delegate = self
      present(sourcePicker, animated: true)
    }
    
    // MARK: - Functions
    
    func hideAllSections(){
//        ageContainerView?.isHidden = true
//        genderContainerView?.isHidden = true
//        emotionContainerView?.isHidden = true
//        classificationContainerView?.isHidden = true
//        topicContainerView?.isHidden = true
//        languageContainerView?.isHidden = true
//        locationContainerView?.isHidden = true
//        sentimentContainerView?.isHidden = true
//        foodContainerView?.isHidden = true
//        physicalContainerView?.isHidden = true
//        placeContainerView?.isHidden = true
//        soundAnalysisContainerView?.isHidden = true

    }
    
    func answerQuestion(){
        guard let document = document else {return}
        
        // Update UI to indicate the app is searching for an answer.
        let searchText = inputTextView.textView.text ?? ""
        let placeholder = inputTextView.placeholder
        inputTextView.placeholder = "Searching..."
        inputTextView.textView.text = ""

        // Run the search in the background to keep the UI responsive.
        DispatchQueue.global(qos: .userInitiated).async {
            // Use the BERT model to search for the answer.
            let answer = self.bert.findAnswer(for: searchText, in: document.body)

            // Update the UI on the main queue.
            DispatchQueue.main.async {
                if answer.base == document.body, let textView = self.documentTextView {
                    // Highlight the answer substring in the original text.
                    let semiTextColor = UIColor(named: "Semi Text Color")!
                    let mutableAttributedText = NSMutableAttributedString(string: document.body,attributes: [.foregroundColor: semiTextColor, .font: UIFont.systemFont(ofSize: 15)])
                    let location = answer.startIndex.utf16Offset(in: document.body)
                    let length = answer.endIndex.utf16Offset(in: document.body) - location
                    let answerRange = NSRange(location: location, length: length)
                    let fullTextColor = UIColor(named: "Full Text Color")!
                    mutableAttributedText.addAttributes([.foregroundColor: fullTextColor], range: answerRange)
                    textView.attributedText = mutableAttributedText
                }
                
                self.inputTextView.textView.text = String(answer)
                self.inputTextView.placeholder = placeholder
            }
        }
    }
    
    // MARK: - User Interface
    
    func configureInterface() {
        configureTextView()
        configureInputTextView()
        configureRecorder()
        configureLocation()
        configureClassification()
    }


    func configureTextView() {
        guard let document = document else {return}
        guard let textView = documentTextView else {return}
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 15)]
        textView.attributedText = NSAttributedString(string: document.body, attributes: attributes)
    }
    
    func configureInputTextView() {
        // Accessible Properties
        inputTextView.padding = 12 // Same padding will be used for all sides | by default padding is 12
        inputTextView.font = UIFont.systemFont(ofSize: 15) // Font for placeholder and DSTextView | by defaulr system font of size 15
        inputTextView.editingAllowed = true // Editing is allowed or not | by default allowed
        inputTextView.emojiAllowed = true // Emojis are allowed or not | by default allowed
        inputTextView.maxLength = 200 // Max length of text | default is 200
        inputTextView.returnKeyType = .default // Return type of the keyboard
        inputTextView.keyboardType = .default // Keyboard type of the DSTextView
        inputTextView.showDoneButton = true // Show toolbar or not with done button to dismiss DSTextView

        // Designable Properties
        inputTextView.placeholder = "Write Something..." // Placeholder Text
        inputTextView.placeholderColor = UIColor(white: 0.6, alpha: 1.0) // Placeholder Text
        inputTextView.textColor = UIColor(white: 0.1, alpha: 1.0) // DSTextView Color
        
        inputTextView.delegate = self // You can set through Storyboard also
        
        // Add border and rounded corner
        inputTextView.layer.cornerRadius = 10
        inputTextView.layer.borderColor = UIColor.darkGray.cgColor
        inputTextView.layer.borderWidth = 0
    }
    
    func configureRecorder() {

        
//        soundAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)

        recorder.delegate = self
        recorder.addObserver(self, forKeyPath: "microphoneLevel", options:.new, context: nil)
        recorder.intervalCallback = {currentLevel in self.drawSample(currentLevel: currentLevel)}
        recorder.microphoneLevelSilenceThreshold = -60
        
        let audioSession = AVAudioSession.sharedInstance()
        _ = try? audioSession.setCategory(.playAndRecord)
        _ = try? audioSession.setActive(true)
        
        genderResultsObserver.delegate = self
        inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        analyzer = SNAudioStreamAnalyzer(format: inputFormat)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch change![NSKeyValueChangeKey.newKey] {
        case let level as Float:
            progressView.progress = level
            microphoneLevel.text = String(format: "%0.2f", level)
        default:
            break
        }
    }
    
    func drawSample(currentLevel: Float) {

    }

}


// MARK: - UITextFieldDelegate

extension FirstViewController: UITextFieldDelegate, UITextViewDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        document = Document(title: document?.title ?? "Document", body: textView.text)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        configureTextView()
        return true
    }
    
}

// MARK: - Image Classification

extension FirstViewController {

     func updateClassifications(for image: UIImage) {
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
         guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
         
         DispatchQueue.global(qos: .userInitiated).async {
             let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
             do {
                 try handler.perform([self.classificationRequest])
             } catch {
                 print("Failed to perform classification.\n\(error.localizedDescription)")
             }
         }
     }
     
     /// Updates the UI with the results of the classification.
     func processClassifications(for request: VNRequest, error: Error?) {
         DispatchQueue.main.async {
             guard let results = request.results else {
                self.classificationView?.subtitleLabel?.text = "Unable to classify image.\n\(error!.localizedDescription)"
                 return
             }
             // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
             let classifications = results as! [VNClassificationObservation]
         
             if classifications.isEmpty {
                self.classificationView?.subtitleLabel?.text = "Nothing recognized."
             } else {
                 // Display top classifications ranked by confidence in the UI.
                 let topClassifications = classifications.prefix(2)
                 let descriptions = topClassifications.map { classification in
                     // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
//                    return String(format: " %@ (%.2f)", classification.identifier, classification.confidence * 100)
                    return "\(classification.identifier) \(Int(classification.confidence * 100))%"

                 }
                self.classificationView?.subtitleLabel?.text = descriptions.joined(separator: "\n")
             }
         }
     }
     
}

// MARK: - Sentiment Analysis

extension FirstViewController {

    func predictSentiment(sentiment: Sentiment, text: String) {
        sentimentView?.subtitleLabel?.text = "\(sentiment.emoji) \(sentimentAnalysis(text: text))"
    }
}

// MARK: - Topic Category Analysis

extension FirstViewController {
    func predictTopic(_ text: String) {
        guard let classification = documentClassifier.classify(text) else { return }
        let prediction = classification.prediction
        guard let percent = percentFormatter.string(from: NSNumber(value: prediction.probability)) else { return }
        topicView?.subtitleLabel?.text = prediction.category.rawValue + " " + "(\(percent))"
    }
}

// MARK: - Image Classification


extension FirstViewController {
    
    func processImage(image: UIImage) {
        let model = Food101()
        let size = CGSize(width: 299, height: 299)

        guard let buffer = image.resize(to: size)?.pixelBuffer() else {
            fatalError("Scaling or converting to pixel buffer failed!")
        }

        guard let result = try? model.prediction(image: buffer) else {
            fatalError("Prediction failed!")
        }

        let confidence = result.foodConfidence["\(result.classLabel)"]! * 100.0
        let converted = String(format: "%.2f", confidence)
        print("Food Classifications \(result.classLabel) (\(converted)%)")
        DispatchQueue.main.async {
            self.foodView?.subtitleLabel?.text = "\(result.classLabel) (\(converted)%)"
        }
        
    }
    
    func recognizePlace(image: UIImage) {

        let model = try! VNCoreMLModel(for: GoogLeNetPlaces().model)
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Results Error")
            }
            
            DispatchQueue.main.async {
                var result = ""
                for classification in results {
                    result += "\(classification.identifier) \(classification.confidence * 100)％\n"
                }
                print(result)
                self.placeView?.subtitleLabel?.text = result
            }

        }
        
    }
    
    func ResNet50Prediction(ref: CVPixelBuffer) {
         do {
             
             // prediction
             let output = try resnetModel.prediction(image: ref)
             
             // sort classes by probability
             let sorted = output.classLabelProbs.sorted(by: { (lhs, rhs) -> Bool in
                 return lhs.value > rhs.value
             })
             
            classificationView?.subtitleLabel2?.text = output.classLabel

//             resultLabel.text = output.classLabel
//             probsLabel.text  = "\(sorted[0].key): \(NSString(format: "%.2f", sorted[0].value))\n\(sorted[1].key): \(NSString(format: "%.2f", sorted[1].value))\n\(sorted[2].key): \(NSString(format: "%.2f", sorted[2].value))\n\(sorted[3].key): \(NSString(format: "%.2f", sorted[3].value))\n\(sorted[4].key): \(NSString(format: "%.2f", sorted[4].value))"
//
            print("ResNet50 Prediction")
             print(output.classLabel)
             print(output.classLabelProbs)
             
         } catch {
             
             print(error)
         }
    }
    
    func predictHeatMap(image: UIImage) {

        guard let visionModel = try? VNCoreMLModel(for: EstimationModel().model) else {
            fatalError("Something went wrong")
        }

        let request = VNCoreMLRequest(model: visionModel) { request, error in
            if let observations = request.results as? [VNCoreMLFeatureValueObservation],
                let heatmaps = observations.first?.featureValue.multiArrayValue {
                
                // convert heatmap to Array<Array<Double>>
                let heatmap3D = self.postProcessor.convertTo2DArray(from: heatmaps)

                DispatchQueue.main.async { [weak self] in
                    self?.heatmapView.heatmap3D = heatmap3D

                    
                }
                // must run on main thread
            }
        }

        request.imageCropAndScaleOption = .scaleFill

        let handler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: image.convertImageOrientation())
        try? handler.perform([request])
    }
    
    func predictUsingVision(image: UIImage) {
        guard let RN1015k500Model = try? VNCoreMLModel(for: RN1015k500Classifier.model) else {
            fatalError("Something went wrong")
        }

        let request = VNCoreMLRequest(model: RN1015k500Model) { request, error in
            if let observations = request.results as? [VNClassificationObservation] {
                let top3 = observations.prefix(through: 2)
                    .map { ($0.identifier, Double($0.confidence)) }
                self.showResults(results: top3)
            }
        }

        request.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(cgImage: image.cgImage!)
        try? handler.perform([request])
    }
    
    func animalPredict(image: UIImage) -> Animal? {
        
        do{
        
            let imageOptions: [MLFeatureValue.ImageOption: Any] = [
                .cropAndScale: VNImageCropAndScaleOption.scaleFill.rawValue
            ]
            let featureValue = try MLFeatureValue(cgImage: image.cgImage!, constraint: imageConstraint!, options: imageOptions)
            let featureProviderDict = try MLDictionaryFeatureProvider(dictionary: ["image" : featureValue])
            let prediction = try updatableModel?.prediction(from: featureProviderDict)
            let value = prediction?.featureValue(for: "classLabel")?.stringValue
            if value == "Dog"{
                return .dog
            }
            else{
                return .cat
            }
        }catch(let error){
            print("error is \(error.localizedDescription)")
        }
        return nil
    }
    
    
    
}


// MARK: - ClassificationServiceDelegate

extension FirstViewController: ClassificationServiceDelegate {
    func configureClassification(){
        classificationService.delegate = self
        classificationService.setup()
        
        let soundClassifier = ESC_10_Sound_Classifier()
        soundClassifierModel = soundClassifier.model
    }
    
    func classificationService(_ service: ClassificationService, didDetectGender gender: String) {
      DispatchQueue.main.async { [weak self] in
          self?.genderView?.subtitleLabel?.text = gender
      }
    }

    func classificationService(_ service: ClassificationService, didDetectAge age: String) {
      DispatchQueue.main.async { [weak self] in
          self?.ageView?.subtitleLabel?.text = age
      }
    }

    func classificationService(_ service: ClassificationService, didDetectEmotion emotion: String) {
      DispatchQueue.main.async { [weak self] in
          self?.emotionView?.subtitleLabel?.text = emotion
      }
    }

}

// MARK: - Sound Analysis

extension FirstViewController {

    func startAudioEngine(audioFileURL: URL) {
            
        // Create a new audio file analyzer.
        do {
            audioFileAnalyzer = try SNAudioFileAnalyzer(url: audioFileURL)
        } catch {
            print("audioFileAnalyzer \(error)")
        }

        print("audioFileAnalyzer Active")
        // Create a new observer that will be notified of analysis results.
        
        // Prepare a new request for the trained model.
        do {
            let request = try SNClassifySoundRequest(mlModel: soundClassifierModel)
            try audioFileAnalyzer.add(request, withObserver: resultsObserver)

        } catch {
            print("SNClassifySoundRequest \(error)")
        }
        
        // Analyze the audio data.
        audioFileAnalyzer.analyze()
        
        //Update the UI
        DispatchQueue.main.async {
            print("AudioFileAnalyzer Prediction \(self.resultsObserver.classificationResult)")
            let percent = String(format: "%.2f%%", self.resultsObserver.classificationConfidence)
            self.soundAnalysisView?.subtitleLabel?.text = "Prediction: " + self.resultsObserver.classificationResult + " \(percent) confidence."
        }
            
    }
    
    func startAudioEngine() {
        do {

            let genderRequest = try SNClassifySoundRequest(mlModel: genderSoundClassifier.model)
            let soundRequest = try SNClassifySoundRequest(mlModel: soundClassifierModel)

            try analyzer.add(genderRequest, withObserver: genderResultsObserver)
            try analyzer.add(soundRequest, withObserver: resultsObserver)

//            try soundAnalyzer.add(soundRequest, withObserver: resultsObserver)
        } catch {
            print("Unable to prepare request: \(error.localizedDescription)")
            return
        }
       
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 8000, format: inputFormat) { buffer, time in
            self.analysisQueue.async {
                self.analyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
                DispatchQueue.main.async {
                    print("AudioFileAnalyzer Prediction \(self.resultsObserver.classificationResult)")
                    self.soundAnalysisView?.subtitleLabel?.text = "" + self.resultsObserver.classificationResult + " (\(Int(self.resultsObserver.classificationConfidence))%)"

                    if self.resultsObserver.classificationConfidence > 0.99 {
                        self.soundAnalysisView?.subtitleLabel?.textColor = .systemGreen
                    }
                    else {
                        self.soundAnalysisView?.subtitleLabel?.textColor = .label
                    }
                    let percent = String(format: "%.2f%%", self.resultsObserver.classificationConfidence)
                    
                    
                }
            }
        }
        
        do{
        try audioEngine.start()
        }catch( _){
            print("error in starting the Audio Engin")
        }
        

    }
    
}

protocol GenderClassifierDelegate {
    func displayPredictionResult(identifier: String, confidence: Double)
}


// MARK: - UITextFieldDelegate

extension FirstViewController: DSTextViewDelegate {

       //MARK: Delegate Methods of DSTextView
    
        func dsTextViewDidChange(_ textView: UITextView) {
            print("Text Did Change")
        }
        
        func dsTextViewDidEndEditing(_ textView: UITextView) {
            print("Text Did End")
            // The user pressed the `Search` button.
        }
        
        func dsTextViewDidBeginEditing(_ textView: UITextView) {
            print("Text Did Begin Editing")
        }
        
        func dsTextViewCharactersCount(_ count: Int) {
            print("Characters Count : \(count)")
        }
        

    // MARK:- Other Methods of DSTextView
        @IBAction func resignAction(_ sender: Any) {
            inputTextView.removeFirstResponder()
        }
        
        @IBAction func bocomeAction(_ sender: Any) {
            inputTextView.makeFirstResponder()
        }

    
}

// MARK: - PhotoSourceControllerDelegate

extension FirstViewController: PhotoSourceControllerDelegate, UINavigationControllerDelegate {
    
    public func photoSourceController(_ controller: PhotoSourceController, didSelectSourceType sourceType: UIImagePickerController.SourceType) {
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.allowsEditing = true
      imagePicker.sourceType = sourceType
      present(imagePicker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate


extension FirstViewController: UIImagePickerControllerDelegate {
    
      public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var editedImage : UIImage!
        
        if let image = info[.editedImage] as? UIImage {
            editedImage = image
        }else if let image = info[.originalImage] as? UIImage {
            editedImage = image
        }
      
        guard let image = editedImage, let ciImage = CIImage(image: image) else {
            print("Can't analyze selected photo")
            return
        }

        
        DispatchQueue.main.async { [weak self] in
            self?.snappedImageView?.image = image
            self?.mainImageView?.image = image
        }
        
      picker.dismiss(animated: true)

      // Run Core ML classifier
      DispatchQueue.global(qos: .userInteractive).async { [weak self] in
        self?.classificationService.classify(image: ciImage)
        self?.updateClassifications(for: image)
        self?.predictUsingVision(image: image)
        self?.processImage(image: image)
        self?.predictHeatMap(image: image)
        self?.recognizePlace(image: image)
        
        let animal = self?.animalPredict(image: image)
        DispatchQueue.main.async { [weak self] in
            if let animal = animal{
                if animal == .dog{
                    self?.predicatedClassLabel?.text = "Dog"
                    self?.btnToggleClassLabel?.alpha = 1
                    self?.btnToggleClassLabel?.tag = 0
                    self?.btnToggleClassLabel?.setTitle("Assestment Incorrection: It's a Cat", for: .normal)
                }
                else if animal == .cat{
                    self?.btnToggleClassLabel?.alpha = 1
                    self?.predicatedClassLabel?.text = "Cat"
                    self?.btnToggleClassLabel?.tag = 1
                    self?.btnToggleClassLabel?.setTitle("Assestment Incorrection: It's a Dog!", for: .normal)
                }
            }
            else{
                self?.predicatedClassLabel?.text = "Neither dog nor cat."
            }
            
        }


        if let ref = image.bufferToPixelBuffer {
            self?.ResNet50Prediction(ref: ref)
        }
      }
    }
    
}

// MARK: - FDSoundActivatedRecorderDelegate

extension FirstViewController: FDSoundActivatedRecorderDelegate {
    /// A recording was triggered or manually started
    func soundActivatedRecorderDidStartRecording(_ recorder: FDSoundActivatedRecorder) {
        micButton?.tintColor = UIColor.red
        progressView.progressTintColor = UIColor.red

    }
    
    /// No recording has started or been completed after listening for `TOTAL_TIMEOUT_SECONDS`
    func soundActivatedRecorderDidTimeOut(_ recorder: FDSoundActivatedRecorder) {
        micButton?.tintColor = UIColor.link
        progressView.progressTintColor = UIColor.link

    }
    
    /// The recording and/or listening ended and no recording was captured
    func soundActivatedRecorderDidAbort(_ recorder: FDSoundActivatedRecorder) {
        micButton?.tintColor = UIColor.link
        progressView.progressTintColor = UIColor.link

    }
    
    /// A recording was successfully captured
    func soundActivatedRecorderDidFinishRecording(_ recorder: FDSoundActivatedRecorder, andSaved file: URL) {
        micButton?.tintColor = UIColor.link
        progressView.progressTintColor = UIColor.link

        print("soundActivatedRecorderDidFinishRecording \(file)")

        savedURL = file
        
        if let savedURL = savedURL {
            startAudioEngine(audioFileURL: savedURL)
        }
    }
    
    @IBAction func pressedStartListening() {
        print("pressedStartListening")
        resetGraph()

        recorder.startListening()
    }
    
    @IBAction func pressedStartRecording() {
        print("pressedStartRecording")
        resetGraph()

        recorder.startRecording()
    }
    
    @IBAction func pressedStopAndSaveRecording() {
        print("pressedStopAndSaveRecording")
        recorder.stopAndSaveRecording()
    }
    
    @IBAction func pressedAbort() {
        print("pressedAbort")
        recorder.abort()
    }
    
    @IBAction func pressedPlayBack() {
        if let savedURL = savedURL {
            player = AVPlayer(url: savedURL)
            player.play()
        }
    }
    
    func resetGraph() {
        sampleSquares.forEach { sampleSquare in
            sampleSquare.removeFromSuperview()
        }
        sampleSquares = []
    }
}

// MARK: - MapKit and Location

extension FirstViewController: CLLocationManagerDelegate {
    
    func configureLocation(){
      if (CLLocationManager.locationServicesEnabled()){
           locationManager = CLLocationManager()
           locationManager.delegate = self
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.requestAlwaysAuthorization()
           locationManager.startUpdatingLocation()
       }
    }
    
    func showResults(results: [Prediction]) {
        var s: [String] = []
        for (i, pred) in results.enumerated() {
            let latLongArr = pred.0.components(separatedBy: "\t")
            myLatitude = latLongArr[1]
            myLongitude = latLongArr[2]
            s.append(String(format: "%d: %@ %@ (%3.2f%%)", i + 1, myLatitude, myLongitude, pred.1 * 100))
            places[i].title = String(i+1)
            places[i].coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(myLatitude)!, longitude: CLLocationDegrees(myLongitude)!)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.locationView?.subtitleLabel?.text = s.joined(separator: "\n")

            // Map reset
            self?.resetRegion()
            // Center on first prediction
            
            if let coordinate = self?.places[0].coordinate {
                self?.mapView.centerCoordinate = coordinate
            }
            
            if let places = self?.places {
                self?.mapView.addAnnotations(places)
            }
            // Show annotations for the predictions on the map
            // Zoom map to fit all annotations
            self?.zoomMapFitAnnotations()
        }
    }
        

    func zoomMapFitAnnotations() {
        var zoomRect = MKMapRect.null
        for annotation in mapView.annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
            if (zoomRect.isNull) {
                zoomRect = pointRect
            } else {
                zoomRect = zoomRect.union(pointRect)
            }
        }
        self.mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation

        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        self.mapView.setRegion(region, animated: true)
       // locationView?.subtitleLabel?.text = "locations = \(location.coordinate.latitude) \(location.coordinate.longitude)"

        print("Latitude \(location.coordinate.latitude) Longitude \(location.coordinate.longitude)")
        
        let geocoder = CLGeocoder()
           geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
               if (error != nil){
                   print("error in reverseGeocode")
               }
               let placemark = placemarks! as [CLPlacemark]
               if placemark.count>0{
                   let placemark = placemarks![0]
                   print(placemark.locality!)
                   print(placemark.administrativeArea!)
                   print(placemark.country!)

                   self.locationView?.subtitleLabel?.text = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
               }
           }
        locationManager.stopUpdatingLocation()

    }

    func resetRegion(){
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
    }
}

//MARK:- On-Device Training

extension FirstViewController {
    //MARK:- Get MLImageConstraints

    func getImageConstraint(model: MLModel) -> MLImageConstraint {
      return model.modelDescription.inputDescriptionsByName["image"]!.imageConstraint!
    }
    
    //MARK:- Load Model From URL
    
    private func loadModel(url: URL) -> MLModel? {
      do {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        return try MLModel(contentsOf: url, configuration: config)
      } catch {
        print("Error loading model: \(error)")
        return nil
      }
    }

    //MARK:- Image Label Dictionary for training
    
    @IBAction func btnAddToTraining(_ sender: UIButton) {
        btnToggleClassLabel?.alpha = 0
        
        if btnTrainImages?.alpha == 0{
            btnTrainImages?.alpha = 1
        }
        retrainImageCount = retrainImageCount + 1
        trainingImagesCount?.text = "\(retrainImageCount)"
        
        if let image = snappedImageView?.image{
            var label = "Dog"
            if sender.tag == 0{
                label = "Cat"
            }
            imageLabelDictionary[image] = label
        }
    }
    
    //MARK:- MLArrayBatchProvider
    
    private func batchProvider() -> MLArrayBatchProvider
    {

        var batchInputs: [MLFeatureProvider] = []
        let imageOptions: [MLFeatureValue.ImageOption: Any] = [
          .cropAndScale: VNImageCropAndScaleOption.scaleFill.rawValue
        ]
        for (image,label) in imageLabelDictionary {
            
            do{
                let featureValue = try MLFeatureValue(cgImage: image.cgImage!, constraint: imageConstraint!, options: imageOptions)
              
                if let pixelBuffer = featureValue.imageBufferValue{
                    let x = CatDogUpdatableTrainingInput(image: pixelBuffer, classLabel: label)
                    batchInputs.append(x)
                }
            }
            catch(let error){
                print("error description is \(error.localizedDescription)")
            }
        }
     return MLArrayBatchProvider(array: batchInputs)
    }

    
    //MARK:- Training the Model Using MLUpdateTask
    
    @IBAction func startTraining(_ sender: Any) {
            
        let modelConfig = MLModelConfiguration()
        modelConfig.computeUnits = .cpuAndGPU
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
            
            var modelURL = CatDogUpdatable.urlOfModelInThisBundle
            let pathOfFile = documentDirectory.appendingPathComponent("CatDog.mlmodelc")
            
            if fileManager.fileExists(atPath: pathOfFile.path){
                modelURL = pathOfFile
            }
                        
            let updateTask = try MLUpdateTask(forModelAt: modelURL, trainingData: batchProvider(), configuration: modelConfig,
                             progressHandlers: MLUpdateProgressHandlers(forEvents: [.trainingBegin,.epochEnd],
                              progressHandler: { (contextProgress) in
                                print(contextProgress.event)
                                // you can check the progress here, after each epoch
                                
                             }) { (finalContext) in
                                
                                if finalContext.task.error?.localizedDescription == nil{
                                    let fileManager = FileManager.default
                                    do {

                                        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
                                        let fileURL = documentDirectory.appendingPathComponent("CatDog.mlmodelc")
                                        try finalContext.model.write(to: fileURL)
                                        
                                        self.updatableModel = self.loadModel(url: fileURL)
                            
                                        showSuccessAlert(title: "On-Device Training", subtitle: "Memory System Updated")
                                        DispatchQueue.main.async {
                                            self.btnTrainImages?.alpha = 0
                                            self.imageLabelDictionary = [:]
                                            self.retrainImageCount = 0
                                        }

                                    } catch(let error) {
                                        print("error is \(error.localizedDescription)")
                                    }
                                }
                                
                                
            })
            updateTask.resume()
            
        } catch {
            print("Error while upgrading \(error.localizedDescription)")
        }
    }
}


// MARK: - Additional Classes

extension UIImage {
    func convertImageOrientation() -> CGImagePropertyOrientation  {
        let cgiOrientations : [ CGImagePropertyOrientation ] = [
            .up, .down, .left, .right, .upMirrored, .downMirrored, .leftMirrored, .rightMirrored
        ]
        return cgiOrientations[imageOrientation.rawValue]
    }
}

class PredictionLocation: NSObject, MKAnnotation{
    var identifier = "Prediction location"
    var title: String?
    var coordinate: CLLocationCoordinate2D
    init(name:String,lat:CLLocationDegrees,long:CLLocationDegrees){
        title = name
        coordinate = CLLocationCoordinate2DMake(lat, long)
    }
}

class PredictionLocationList: NSObject {
    var place = [PredictionLocation]()
    override init(){
        place += [PredictionLocation(name:"1",lat: 0, long: 0)]
        place += [PredictionLocation(name:"2",lat: 1, long: 1)]
        place += [PredictionLocation(name:"3",lat: 2, long: 2)]
    }
}

class SegmentView: UIView {
    @IBOutlet weak var headerView: UIView? {
        didSet {
            headerView?.transformToCircle()
        }
    }
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var confidenceLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    
    @IBOutlet weak var confidenceLabel2: UILabel?
    @IBOutlet weak var subtitleLabel2: UILabel?
    
    @IBOutlet weak var confidenceLabel3: UILabel?
    @IBOutlet weak var subtitleLabel3: UILabel?
}


class FDSoundActivatedRecorderMock: FDSoundActivatedRecorder {
    var intervalCallback: (Float)->() = {_ in}
    
    func interval(currentLevel: Float) {
        self.intervalCallback(currentLevel);
    }
    
    override init() {
        super.init();
    }
}

enum Animal {
    case cat
    case dog
}
