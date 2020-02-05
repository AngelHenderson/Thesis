//
//  DoubleChoiceViewController.swift

//
//  Created by Angel Henderson on 8/13/18.

//

import UIKit
import SwifterSwift
import SwiftyJSON
import Alamofire
import SwifterSwift
import Times

import Firebase
import Closures

protocol ChoiceDelegate: class {
    func firstButtonClicked()
    func secondButtonClicked()
}


class DoubleChoiceViewController: UIViewController {

    var titleString: String?
    var subjectString: String?
    var imageUrlString: String?

    var firstButtonString: String?
    var secondButtonString: String?
    var cancelButtonString: String?

    var choiceImage: UIImage?
    weak var delegate: ChoiceDelegate?

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subjectLabel: UILabel?
    @IBOutlet weak var choiceImageView: UIImageView?
    @IBOutlet weak var firstButton: UIButton?
    @IBOutlet weak var secondButton: UIButton?
    @IBOutlet weak var cancelButton: UIButton?
    
    override var preferredContentSize: CGSize {
        get { return CGSize(width: UIScreen.main.bounds.width-20, height: 310) }
        set {}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let titleStr = titleString {
            titleLabel?.text = titleStr
        }
        
        if let subjectStr = subjectString {
            subjectLabel?.text = subjectStr
        }
        
        if let choice = choiceImage {
            choiceImageView?.image = choice
        }
        
        if let imageUrl = imageUrlString {
            choiceImageView?.setImage(url: URL(string: imageUrl)!, placeholder:  UIImage(color: .groupTableViewBackground, size: (choiceImageView?.frame.size)!))
        }
        
        
        if let firstString = firstButtonString {
            firstButton?.setTitleForAllStates(firstString)
        }
        if let secondString = secondButtonString {
            secondButton?.setTitleForAllStates(secondString)
        }
        if let cancelString = cancelButtonString {
            cancelButton?.setTitleForAllStates(cancelString)
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.backgroundColor = .primaryBackgroundColor
        titleLabel?.textColor = .primaryTextColor
        subjectLabel?.textColor = .primaryTextColor
        
        //firstButton?.backgroundColor = ColorKit.themeColor
        //secondButton?.backgroundColor = ColorKit.themeColor

        firstButton?.onTap {
            self.dismiss(animated: true, completion: {
                self.delegate?.firstButtonClicked()
            })
        }
        
        secondButton?.onTap {
            self.dismiss(animated: true, completion: {
                self.delegate?.secondButtonClicked()
            })
        }
    }

    @IBAction func dismissView(_ sender: UIButton) {
        cancelButtonFunction()
    }
    
    @IBAction func firstButtonAction(_ sender: UIButton) {
        delegate?.firstButtonClicked()
    }

    @IBAction func secondButtonAction(_ sender: UIButton) {
        delegate?.secondButtonClicked()
    }
    
    func cancelButtonFunction(){
        dismiss(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
