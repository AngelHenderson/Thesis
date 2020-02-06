//
//  FirstViewController.swift
//  Thesis
//
//  Created by Angel Henderson on 2/4/20.
//  Copyright © 2020 Angel Henderson. All rights reserved.
//

import UIKit
import CoreML

class FirstViewController: UIViewController {
    
    @IBOutlet weak var documentTextView: UITextView?
    @IBOutlet weak var inputTextView: DSTextView!
    
    @IBOutlet weak var answerButton: UIButton?
    @IBOutlet weak var knowledgeButton: UIButton?
    @IBOutlet weak var analyzeButton: UIButton?

    var document: Document? {
        didSet {
            configureTextView()
        }
    }

    //CoreML Models
    let bert = BERT()

    // MARK: - Lifecycle


    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        
        answerButton?.onTap { [weak self] in
            self?.answerQuestion()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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



// MARK: - UITextFieldDelegate

extension FirstViewController: DSTextViewDelegate {

       //MARK:- Delegate Methods of DSTextView
    
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


