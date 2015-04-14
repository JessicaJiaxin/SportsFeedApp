//
//  NewsCell.swift
//  SportsRssReader
//
//  Created by Cunqi.X on 4/13/15.
//  Copyright (c) 2015 jl6467. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {
    @IBOutlet var canvas: UIView!
    @IBOutlet var title: UILabel!
    @IBOutlet var desc: UILabel!
    @IBOutlet var author: UILabel!
    @IBOutlet var publicDate: UILabel!

    var link: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.canvas.layer.masksToBounds = false
        self.canvas.layer.cornerRadius = 1.8
        self.canvas.layer.borderColor = UIColor.grayColor().CGColor
        self.canvas.layer.borderWidth = 1.0
        self.canvas.layer.backgroundColor = UIColor.whiteColor().CGColor
        self.canvas.layer.shadowColor = UIColor.blackColor().CGColor
        self.canvas.layer.shadowRadius = 1.5
        self.canvas.layer.shadowOpacity = 0.8
        self.canvas.layer.shadowOffset = CGSizeMake(0, 1)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configNews(news: News) {
        self.title.text = news.title
        self.desc.text = news.desc
        
        if (news.author != nil) {
            self.author.text = news.author
        }
        self.publicDate.text = news.publicDate
        self.link = news.link
    }
    
}
