//
//  RootViewController.swift
//  SportsRssReader
//
//  Created by Jiaxin.L on 4/14/15.
//  Copyright (c) 2015 jl6467. All rights reserved.
//

import UIKit

class RootViewController: ViewPagerController, ViewPagerDataSource, ViewPagerDelegate {
    
    let categoryTitle = ["Top", "NFL", "NBA", "MLB", "NHL", "Racing"]
    
    let categories = ["Top" : "http://sports.espn.go.com/espn/rss/news",
        "NFL" : "http://sports.espn.go.com/espn/rss/nfl/news",
        "NBA" : "http://sports.espn.go.com/espn/rss/nba/news",
        "MLB" : "http://sports.espn.go.com/espn/rss/mlb/news",
        "NHL" : "http://sports.espn.go.com/espn/rss/nhl/news",
        "Racing" : "http://sports.espn.go.com/espn/rss/rpm/news"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
    }
    
    func numberOfTabsForViewPager(viewPager: ViewPagerController!) -> UInt {
        return UInt(categories.count)
    }
    
    
    func viewPager(viewPager: ViewPagerController!, viewForTabAtIndex index: UInt) -> UIView! {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Bold", size: 16)
        label.textAlignment = .Center
        label.backgroundColor = UIColor.clearColor()
        label.text = categoryTitle[Int(index)]
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        
        return label
    }
    
    func viewPager(viewPager: ViewPagerController!, contentViewControllerForTabAtIndex index: UInt) -> UIViewController! {
        
        
        let viewController = NewsListViewController(nibName: nil, bundle: nil)

        viewController.url = categories[categoryTitle[Int(index)]]
        viewController.category = categoryTitle[(Int(index))]
        viewController.navigator = self.navigationController
        
        return viewController
    }
}
