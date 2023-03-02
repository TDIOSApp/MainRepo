import UIKit
import Amplitude
import WebKit

class LandingViewController: UIViewController, UIScrollViewDelegate, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var backvieww: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var web: WKWebView!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func nextButton(_ sender: Any) {
        Amplitude.instance().logEvent("free_confirmation_success")
        UserDefaults.standard.setValue(true, forKey: "confirmed")
        dismiss(animated: true)
    }
    
    var scrollWidth: CGFloat! = 0.0
    var scrollHeight: CGFloat! = 0.0
    
    //get dynamic width and height of scrollview and save it
    override func viewDidLayoutSubviews() {
        scrollWidth = scrollView.frame.size.width
        scrollHeight = scrollView.frame.size.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        
        self.scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        guard let configModel = configModel else { return }
        
        if configModel.fmode ?? true {
            web.isHidden = true
            nextButton.layer.cornerRadius = 15
            nextButton.isHidden = false
        } else {
            web.isHidden = true
            nextButton.isHidden = true
            web.scrollView.isScrollEnabled = false
            web.scrollView.bounces = false
            web.uiDelegate = self
            web.navigationDelegate = self
            web.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
            
            guard let plink = configModel.alternateLink else { return }
            guard let url = URL(string: plink) else { return }
            web.load(URLRequest(url: url))
        }
        
        //crete the slides and add them
        var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        if let pages = configModel.pages {
            for (index, page) in pages.enumerated() {
                frame.origin.x = scrollWidth * CGFloat(index)
                frame.size = CGSize(width: scrollWidth, height: scrollHeight)
                
                let slide = UIView(frame: frame)
                
                //subviews
                let imageView = UIImageView()
                imageView.downloaded(from: page.image ?? "")
                imageView.frame = CGRect(x:0,y:0,width: scrollWidth,height: scrollHeight * 0.4)
                imageView.contentMode = .scaleAspectFit
                imageView.center = CGPoint(x:scrollWidth/2,y: 150)
                
                let txt1 = UILabel.init(frame: CGRect(x:32,y:imageView.frame.maxY,width:scrollWidth-64,height: scrollHeight * 0.2))
                txt1.numberOfLines = 0
                txt1.adjustsFontSizeToFitWidth = true
                txt1.minimumScaleFactor = 0.2
                txt1.textAlignment = .left
                txt1.font = UIFont.systemFont(ofSize: 25, weight: .bold)
                txt1.text = page.title
                txt1.textColor = UIColor.black
                
                let txt2 = UILabel.init(frame: CGRect(x:32,y:txt1.frame.maxY,width:scrollWidth-64,height: scrollHeight * 0.3))
                txt2.textAlignment = .left
                txt2.numberOfLines = 0
                txt2.adjustsFontSizeToFitWidth = true
                txt2.minimumScaleFactor = 0.2
                txt2.font = UIFont.systemFont(ofSize: 22, weight: .regular)
                txt2.textColor = UIColor.black
                txt2.text = page.desc
                
                slide.addSubview(imageView)
                slide.addSubview(txt1)
                slide.addSubview(txt2)
                scrollView.addSubview(slide)
            }
        }
        
        
        //set width of scrollview to accomodate all the slides
        scrollView.contentSize = CGSize(width: scrollWidth * CGFloat(configModel.pages?.count ?? 0), height: scrollHeight)
        
        //disable vertical scroll/bounce
        self.scrollView.contentSize.height = 1.0
        
        //initial state
        pageControl.numberOfPages = configModel.pages?.count ?? 0
        pageControl.currentPage = 0
        if let buttonText = configModel.buttonText {
            nextButton.setTitle(buttonText, for: .normal)
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.url) {
            if web.url != nil {
                let link = "\(web.url!)"
                guard let confirmationLink = configModel?.alternateConfirmation else { return }
                if link.contains(confirmationLink) {
//                    Amplitude.instance().logEvent("confirmation_success", withEventProperties: ["campaign": "\(camp)"])
                    UserDefaults.standard.setValue(true, forKey: "confirmed")
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        var scrollPoint = self.view.convert(CGPoint(x: 0, y: 0), to: web.scrollView)
        scrollPoint = CGPoint(x: 0, y: 310)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.web.scrollView.setContentOffset(scrollPoint, animated: false)
            self.web.isHidden = false
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let frame = navigationAction.targetFrame,
            frame.isMainFrame {
            return nil
        }
        webView.load(navigationAction.request)
        return nil
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if isConfirmed() {
            self.dismiss(animated: true)
        }
    }
    
    private func isConfirmed() -> Bool{
        return UserDefaults.standard.bool(forKey: "confirmed")
    }
    
    //indicator
    @IBAction func pageChanged(_ sender: Any) {
        scrollView!.scrollRectToVisible(CGRect(x: scrollWidth * CGFloat ((pageControl?.currentPage)!), y: 0, width: scrollWidth, height: scrollHeight), animated: true)
    }
    
    @objc func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setIndiactorForCurrentPage()
    }
    
    func setIndiactorForCurrentPage()  {
        let page = (scrollView?.contentOffset.x)!/scrollWidth
        pageControl?.currentPage = Int(page)
    }
    
}
