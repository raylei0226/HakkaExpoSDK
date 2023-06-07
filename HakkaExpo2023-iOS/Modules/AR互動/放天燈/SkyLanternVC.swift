//
//  SkyLanternVC.swift
//  OmniArTaipei
//
//  Created by Dong on 2022/11/21.
//

import UIKit

class SkyLanternVC: UIViewController {
    
    enum SkyLanternType {
        case canvas
        case text
    }

    @IBOutlet weak var indicatorView: UIView!
    //DIY
    @IBOutlet weak var diyView: UIView!
    @IBOutlet weak var contentBackgroundView: UIView!
    @IBOutlet weak var canvasView: SkyLanternCanvasView!
    
    //Text
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var textBackgroundView: UIView!
    @IBOutlet weak var inputTextView: UITextView!
    
    //Buttons
    @IBOutlet weak var switchBtn: UIButton!
    
    private var currentType = SkyLanternType.canvas
    
    //Test
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var testImageView: UIImageView!
    private let isTestImage = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initResources()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setContentBorder()
        checkResources()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputTextView.resignFirstResponder()
    }
    
    //MARK: - IBAction
    @IBAction func nextBtnPressed(_ sender: Any) {
        guard let image = getUserImage() else {return}
        //Test Image
        if isTestImage {
            if let testImage = getTestImage(image) {
                testImageView.image = testImage
                testView.isHidden = false
            }
            return
        }
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SkyLanternARVC") as? SkyLanternARVC {
            vc.userImage = image
            navigationController?.pushViewController(vc, animated: true)
            clear()
        }
    }
    
    @IBAction func switchBtnPressed(_ sender: Any) {
        diyView.isHidden.toggle()
        textView.isHidden.toggle()
        updateSwitchBtn()
    }
    
    @IBAction func testViewDidTapped(_ sender: Any) {
        testView.isHidden = true
    }
    
    //MARK: - Action
    @objc private func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func clear() {
        if currentType == .canvas {
            canvasView.clearCanvas()
        }else if currentType == .text {
            inputTextView.resignFirstResponder()
            inputTextView.text = nil
        }
    }
    
    private func updateSwitchBtn() {
        if diyView.isHidden {
            switchBtn.setTitle("切換 - 繪畫DIY", for: .normal)
            currentType = .text
        }else {
            switchBtn.setTitle("切換 - 文字輸入", for: .normal)
            currentType = .canvas
        }
    }

    //MARK: - Init
    private func setupViews() {
        setupNavigationBar()
        title = "DIY天燈製作"
        let backBtn = UIBarButtonItem(image: Asset.back.image, style: .plain, target: self, action: #selector(back))
        backBtn.tintColor = .white
        navigationItem.leftBarButtonItem = backBtn
        let clearBtn = UIBarButtonItem(title: "清除", style: .plain, target: self, action: #selector(clear))
        clearBtn.tintColor = .white
        navigationItem.rightBarButtonItem = clearBtn
        textBackgroundView.layer.cornerRadius = 9
        textBackgroundView.layer.borderWidth = 0.7
        textBackgroundView.layer.borderColor = Configs.Colors.themePurple.cgColor
//        textBackgroundView.layer.borderColor = UIColor(hex: "#2eb6c7")?.cgColor
        diyView.isHidden = false
        textView.isHidden = true
    }
    
    private func setupNavigationBar() {
        guard let navigationController else {return}
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            appearance.titleTextAttributes = textAttributes
            appearance.backgroundColor = Configs.Colors.themePurple
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = navigationController.navigationBar.standardAppearance
        }else {
            let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationController.navigationBar.titleTextAttributes = textAttributes
            navigationController.navigationBar.tintColor = .black
        }
    }
    
    private func setContentBorder() {
        let border = CAShapeLayer()
//        border.strokeColor = UIColor(red: 0.2008167505, green: 0.7600806355, blue: 0.8216403127, alpha: 1).cgColor
        border.strokeColor = Configs.Colors.themePurple.cgColor
        border.fillColor = UIColor.clear.cgColor
        let path = UIBezierPath(roundedRect: contentBackgroundView.bounds, cornerRadius: 10)
        border.path = path.cgPath
        border.frame = contentBackgroundView.bounds
        border.lineWidth = 2
        border.lineDashPattern = [16, 16]
        contentBackgroundView.layer.cornerRadius = 10
        contentBackgroundView.layer.masksToBounds = true
        contentBackgroundView.layer.addSublayer(border)
    }
}

//MARK: - UITextView Delegate
extension SkyLanternVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n" else {
            textView.resignFirstResponder()
            return false
        }
        
        let newLength = (textView.text + text).replacingOccurrences(of: " ", with: "").count
        return newLength <= 20
    }
}

//MARK: - Other
extension SkyLanternVC {
    private func getUserImage() -> UIImage? {
        if currentType == .canvas {
            let image = canvasView.convertImage()
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            let newView = UIView(frame: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
            newView.addSubview(imageView)
            imageView.center = newView.center
            imageView.transform = CGAffineTransform(rotationAngle: .pi / -2)
            UIGraphicsBeginImageContextWithOptions(newView.bounds.size, false, 0)
            let context = UIGraphicsGetCurrentContext()
            newView.layer.render(in: context!)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }else if currentType == .text {
            let textView = UIView(frame: CGRect(x: 0, y: 0, width: inputTextView.bounds.height, height: inputTextView.bounds.width))
            textToCustomView(textView)
//            textToVerticalLabel(textView)
            UIGraphicsBeginImageContextWithOptions(textView.bounds.size, false, 0)
            let context = UIGraphicsGetCurrentContext()
            textView.layer.render(in: context!)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsGetCurrentContext()
            return newImage
        }
        return nil
    }
    
    private func textToCustomView(_ superView: UIView) {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: superView.bounds.height, height: superView.bounds.width))
        
        let textArr = inputTextView.text.split(separator: " ")
        let setWidth = customView.bounds.width / CGFloat(textArr.count)
        for (index, text) in textArr.enumerated() {
            let setX = CGFloat(index) * setWidth
            let label = UILabel(frame: CGRect(x: setX, y: 0, width: setWidth, height: customView.bounds.height))
            var newText = String(text)
            newText.insert(separator: "\n", every: 1)
            label.text = newText
            label.font = SkyLanternResources.shared.getFont()
            label.textAlignment = .center
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.1
            customView.addSubview(label)
        }
        
        customView.center = superView.center
        customView.transform = CGAffineTransform(rotationAngle: .pi / -2)
        superView.addSubview(customView)
    }
    
    private func textToVerticalLabel(_ superView: UIView) {
        let vLabel = VerticalLabel(frame: CGRect(x: 0, y: 0, width: superView.bounds.height, height: superView.bounds.width))
        vLabel.text = inputTextView.text.replacingOccurrences(of: " ", with: "\n")
        vLabel.transform  = CGAffineTransform(rotationAngle: .pi / -2)
        vLabel.fontSize = 85
        vLabel.xPosition = .center
        vLabel.yPosition = .center
        vLabel.center = superView.center
        superView.addSubview(vLabel)
    }
}

extension StringProtocol where Self: RangeReplaceableCollection {
    mutating func insert(separator: Self, every count: Int) {
        for index in indices.reversed() where index != startIndex &&
            distance(from: startIndex, to: index) % count == 0 {
                insert(contentsOf: separator, at: index)
        }
    }
}

//MARK: - Test
extension SkyLanternVC {
    private func getTestImage(_ image: UIImage) -> UIImage? {
        guard
            let path = SkyLanternResources.materialPath,
            let skyLampImage = UIImage(contentsOfFile: path)
        else {return nil}
        
        let materialView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: skyLampImage.size.width,
            height: skyLampImage.size.height))
        let skyLampImageView = UIImageView(image: skyLampImage)
        skyLampImageView.frame = materialView.bounds
        materialView.addSubview(skyLampImageView)
        
        let contentImageView = UIImageView(frame: CGRect(
            x: skyLampImage.size.width * 0.25,
            y: skyLampImage.size.height * 0.2,
            width: skyLampImage.size.width / 3,
            height: skyLampImage.size.height / 4.8))
        contentImageView.image = image
        contentImageView.contentMode = .scaleAspectFit
        materialView.addSubview(contentImageView)
        
        UIGraphicsBeginImageContextWithOptions(materialView.bounds.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        materialView.layer.render(in: context!)
        let materialImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return materialImage
    }
}

//MARK: - Resources
extension SkyLanternVC {
    private func initResources() {
        SkyLanternResources.shared.setup()
    }
    
    @objc private func checkResources() {
        if SkyLanternResources.isReady {
            indicatorView.isHidden = true
            view.isUserInteractionEnabled = true
            NotificationCenter.default.removeObserver(self, name: .didSkyLanternResourcesUpdate, object: nil)
        }else {
            indicatorView.isHidden = false
            view.isUserInteractionEnabled = false
            NotificationCenter.default.addObserver(self, selector: #selector(checkResources), name: .didSkyLanternResourcesUpdate, object: nil)
        }
    }
}
