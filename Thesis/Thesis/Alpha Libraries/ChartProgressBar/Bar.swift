import UIKit


//https://github.com/hadiidbouk/ChartProgressBar-iOS

class Bar: UIView {
    // MARK: - Private Variables
    fileprivate var backgroundImage: UIView!
    fileprivate var progressView: UIImageView!
    fileprivate let animationDuration: Double = 0.6
    fileprivate var barRadius: Float? = nil
    public var isDisabled: Bool = false
    
    // MARK: - Overriden Methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initBar()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initBar()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.size.width, height: frame.size.height)
    }
    // MARK: - Public Methods
    /**
     Initializes the progress bar background and also the progress level view.
     The background is equal to the parent view frame.
     */
    func initBar() {
        // make the container with rounded corners and clear background.
        let radius = barRadius == nil ? self.frame.size.width / 2 : CGFloat(barRadius!)
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.clear
        
        // background image / this view being the same width and height as the parent doesn't need to round the corners. It will take the parent frame.
        let backgroundRect = CGRect(x: 0.0, y: 0.0, width: Double(frame.size.width), height: Double(frame.size.height))
        backgroundImage = UIView(frame: backgroundRect)
        backgroundImage.clipsToBounds = true
        backgroundImage.backgroundColor = UIColor.yellow
        addSubview(backgroundImage)
        
        //level of progress
        let progressRect = CGRect(x: 0.0, y: Double(frame.size.height), width: Double(frame.size.width), height: 0.0)
        progressView = UIImageView(frame: progressRect)
        progressView.layer.cornerRadius = radius
        progressView.layer.masksToBounds = true
        progressView.backgroundColor = UIColor.blue
        addSubview(progressView)
    }
    /**
     Sets the progress level from a value, animated.
     - Parameter currentValue : The value that needs to be displayed as a progress bar.
     - Parameter threshold : Optional. The max percentage that the progress bar will display.
     */
    func setProgressValue(_ currentValue: CGFloat, threshold: CGFloat = 100.0) {
        let yOffset = ((threshold - currentValue) / threshold) * frame.size.height / 1
        
        UIView.animate(withDuration: self.animationDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.progressView.frame.size.height = self.frame.size.height - yOffset
            self.progressView.frame.origin.y = yOffset
        }, completion: nil)
    }
    /**
     Sets the background color of the progress view.
     This color will be displayed underneath the progress view.
     */
    func setBackColor(_ color: UIColor) {
        backgroundImage.backgroundColor = color
    }
    /**
     Sets the background color of the progress view.
     This is the color that will display the value you have inserted.
     */
    func setProgressColor(_ color: UIColor) {
        progressView.backgroundColor = color
    }
    
    /*
     Set the radius of the bar
     */
    
    func setBarRadius(radius barRadius: Float?) {
        self.barRadius = barRadius
    }
}





//
//import UIKit
//import ChartProgressBar
//
//class ViewController: UIViewController, ChartProgressBarDelegate {
//
//    @IBOutlet weak var chart: ChartProgressBar!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//
//        var data: [BarData] = []
//
//        data.append(BarData.init(barTitle: "Jan", barValue: 1.4, pinText: "1.4 €"))
//        data.append(BarData.init(barTitle: "Feb", barValue: 10, pinText: "10 €"))
//        data.append(BarData.init(barTitle: "Mar", barValue: 3.1, pinText: "3.1 €"))
//        data.append(BarData.init(barTitle: "Apr", barValue: 4.8, pinText: "4.8 €"))
//        data.append(BarData.init(barTitle: "May", barValue: 6.6, pinText: "6.6 €"))
//        data.append(BarData.init(barTitle: "Jun", barValue: 7.4, pinText: "7.4 €"))
//        data.append(BarData.init(barTitle: "Jul", barValue: 5.5, pinText: "5.5 €"))
//
//        chart.data = data
//        chart.barsCanBeClick = true
//        chart.maxValue = 10.0
//        chart.emptyColor = UIColor.clear
//        chart.barWidth = 7
//        chart.progressColor = UIColor.init(hexString: "99ffffff")
//        chart.progressClickColor = UIColor.init(hexString: "F2912C")
//        chart.pinBackgroundColor = UIColor.init(hexString: "E2335E")
//        chart.pinTxtColor = UIColor.init(hexString: "ffffff")
//        chart.barTitleColor = UIColor.init(hexString: "B6BDD5")
//        chart.barTitleSelectedColor = UIColor.init(hexString: "FFFFFF")
//        chart.pinMarginBottom = 15
//        chart.pinWidth = 70
//        chart.pinHeight = 29
//        chart.pinTxtSize = 17
//        chart.delegate = self
//        chart.build()
//
//        chart.disableBar(at: 3)
//
//        let when = DispatchTime.now() + 6 // change 2 to desired number of seconds
//        DispatchQueue.main.asyncAfter(deadline: when) {
//            self.chart.enableBar(at: 3)
//        }
//    }
//}
//
//extension MainViewController: ChartProgressBarDelegate {
//    func ChartProgressBar(_ chartProgressBar: ChartProgressBar, didSelectRowAt rowIndex: Int) {
//        print(rowIndex)
//    }
//}
