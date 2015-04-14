//
//  NewsListViewController.swift
//  SportsRssReader
//
//  Created by Cunqi.X on 4/13/15.
//  Copyright (c) 2015 jl6467. All rights reserved.
//

import UIKit

class NewsListViewController: UITableViewController, NSFetchedResultsControllerDelegate, NSXMLParserDelegate {
    private let identifer = "news"
    
    var category: String!
    
    var parser: NSXMLParser!
    
    var newsList = [TempNews]()
    var currentElement: String!
    var tempNews: TempNews!
    
    var fetchedResultController: NSFetchedResultsController!
    var url: String!
    var navigator: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .None
        
        //set URL & XMLParser
        let realURL = NSURL(string: url)
        
        parser = NSXMLParser (contentsOfURL: realURL)
        parser.delegate = self
        parser.shouldResolveExternalEntities = false
        
        let nib = UINib(nibName: "NewsCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: identifer)
        
        fetchedResultController = self.initialFetchedResultController()
        //first page load
        if (fetchedResultController.fetchedObjects?.count == 0) {
            parser.parse()
            
            saveData(newsList)
        }
        
        //refreshControl things
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor.purpleColor()
        self.refreshControl?.tintColor = UIColor.whiteColor()
        self.refreshControl?.addTarget(self, action: "updateAndCompareList", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func saveData(list: [TempNews]) {
        var res = [News]()
        
        for news in list {
            let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let resNews = CoreDataManager.createManagedObjectByName(context, managedObjectName: "News") as! News
            
            resNews.title = news.title
            resNews.author = news.author
            resNews.desc = news.desc
            resNews.link = news.link
            resNews.publicDate = news.publicDate
            resNews.category = news.category
            resNews.creationDate = news.creationDate
            
            res.append(resNews)
        }
        
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        CoreDataManager.save(context)
    }
    
    func updateAndCompareList() {
        parser.parse()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.compareSaveAndReload()
        })
    }
    
    func compareSaveAndReload() {
        //compared
        let fetchedNews = fetchedResultController.fetchedObjects as! [News]
        var set = Set<String>()
        for news in fetchedNews {
            set.insert(news.title)
        }
        
        var newNews = [TempNews]()
        
        for news in newsList {
            if (!set.contains(news.title)) {
                newNews.append(news)
            }
        }
        
        //save
        saveData(newNews)
        
        //reload
        self.reloadData()
    }
    
    func reloadData() {
        self.tableView.reloadData()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        
        let text = "Last updated: \(formatter.stringFromDate(NSDate()))"
        let attrDic = NSDictionary(object: UIColor.whiteColor(), forKey: NSForegroundColorAttributeName)
        
        let attrTitle = NSAttributedString(string: text, attributes: attrDic as [NSObject : AnyObject])
        self.refreshControl?.attributedTitle = attrTitle
        
        self.refreshControl?.endRefreshing()
    }
    
    //pragma mark - Fetched result Controller
    func initialFetchedResultController() -> NSFetchedResultsController {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let entity = CoreDataManager.createEntityDescriptionByName(context, managedEntityName: "News")
        let sortDescriptor = CoreDataManager.createSortDescriptorByName("creationDate")
        let fetchRequest = CoreDataManager.createFetchRequest(entity, sortDescriptors: [sortDescriptor])
        
        //add predicate
        let predicate = NSPredicate(format: "category = %@", category)
        fetchRequest.predicate = predicate
        
        let fetchedResultController = CoreDataManager.createFetchedResultsController(context, fetchRequest: fetchRequest, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        var error: NSError? = nil
        
        if (!fetchedResultController.performFetch(&error)) {
            abort()
        }
        
        return fetchedResultController
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch (type) {
        case .Insert:
            self.tableView .insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            break
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            break
        case .Move:
            break
        case .Update:
            break
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        let tableView = self.tableView
        
        switch (type){
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            break
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            break
        case .Update:
            self.configureCell(self.tableView.cellForRowAtIndexPath(indexPath!) as! NewsCell, indexPath: indexPath!)
            break
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    func configureCell(cell: NewsCell, indexPath: NSIndexPath) {
        let news = self.fetchedResultController.objectAtIndexPath(indexPath) as! News
        cell.configNews(news)
    }
    
    //pragma mark - UITableViewController
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultController.sections![section] as! NSFetchedResultsSectionInfo
        
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let newsCell = tableView.dequeueReusableCellWithIdentifier(identifer) as! NewsCell
        self.configureCell(newsCell, indexPath: indexPath)
        
        return newsCell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let newsCell = tableView.cellForRowAtIndexPath(indexPath) as! NewsCell
        
        let viewController = NewsDisplayer(nibName: "NewsDisplayer", bundle: nil)
        viewController.titleText = newsCell.title.text!
        viewController.url = newsCell.link
        self.navigator.pushViewController(viewController, animated: true)
    }
    
    //pragma mark - NSXMLParserDelegate
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        
        currentElement = elementName
        
        if elementName == "item" {
            tempNews = TempNews()
        }
    }
    
    func parser(parser: NSXMLParser, foundCDATA CDATABlock: NSData) {
        let string = NSMutableString(data: CDATABlock, encoding: NSUTF8StringEncoding)?.description
        
        if currentElement == "title" {
            tempNews.title = string!
        }else if currentElement == "author" {
            tempNews.author = string!
        }else if currentElement == "description" {
            tempNews.desc = string!
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        if currentElement == "link" && tempNews.link == nil {
            tempNews.link = string?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }else if currentElement == "pubDate" && tempNews.publicDate == nil {
            tempNews.publicDate = string!
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {

            tempNews.category = self.category
            tempNews.creationDate = NSDate()
            newsList.append(tempNews)
        }
    }
}
