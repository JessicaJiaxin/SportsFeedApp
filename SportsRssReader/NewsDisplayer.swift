//
//  NewsDisplayer.swift
//  SportsRssReader
//
//  Created by Jiaxin.L on 4/14/15.
//  Copyright (c) 2015 jl6467. All rights reserved.
//

import UIKit

class NewsDisplayer: UIViewController {
    @IBOutlet var webView: UIWebView!
    
    var url: String!
    var titleText: String!
    var newsURL: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsURL = NSURL(string: self.url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        let newsRequest = NSURLRequest(URL: newsURL!)
        
        self.webView.loadRequest(newsRequest)
        self.title = titleText
        
        //add sharing feature
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareFeature")
    }
    
    func shareFeature() {
        let activityController = UIActivityViewController(activityItems: [url, newsURL], applicationActivities: nil)
        self.presentViewController(activityController, animated: true, completion: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

