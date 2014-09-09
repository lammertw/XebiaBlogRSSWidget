//
//  TodayViewController.swift
//  XebiaBlogRSSWidget
//
//  Created by Lammert Westerhoff on 09/09/14.
//  Copyright (c) 2014 Lammert Westerhoff. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UITableViewController, NCWidgetProviding {

    var items : [RSSItem]?

    let dateFormatter :NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()

    let expandButton = UIButton()

    let userDefaults = NSUserDefaults.standardUserDefaults()

    var expanded : Bool {
        get {
            return userDefaults.boolForKey("expanded")
        }
        set (newExpanded) {
            userDefaults.setBool(newExpanded, forKey: "expanded")
            userDefaults.synchronize()
        }
    }

    let defaultNumRows = 3
    let maxNumberOfRows = 6

    var cachedItems : [RSSItem]? {
        get {
            return TMCache.sharedCache().objectForKey("feed") as? [RSSItem]
        }
        set (newItems) {
            TMCache.sharedCache().setObject(newItems, forKey: "feed")
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        updateExpandButtonTitle()
        expandButton.addTarget(self, action: "toggleExpand", forControlEvents: .TouchUpInside)
        tableView.sectionFooterHeight = 44

        items = cachedItems
    }
    
    func updatePreferredContentSize() {
        preferredContentSize = CGSizeMake(CGFloat(0), CGFloat(tableView(tableView, numberOfRowsInSection: 0)) * CGFloat(tableView.rowHeight) + tableView.sectionFooterHeight)
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ context in
            self.tableView.frame = CGRectMake(0, 0, size.width, size.height)
        }, completion: nil)
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        loadFeed(completionHandler)
    }

    func loadFeed(completionHandler: ((NCUpdateResult) -> Void)!) {

        let url = NSURL(string: "http://blog.xebia.com/feed/")
        let req = NSURLRequest(URL: url)

        RSSParser.parseRSSFeedForRequest(req,
            success: { feedItems in
                self.items = feedItems as? [RSSItem]
                self.tableView .reloadData()
                self.updatePreferredContentSize()
                completionHandler(.NewData)

                self.cachedItems = self.items
            },
            failure: { error in
                println(error)
                completionHandler(.Failed)
                
        })
    }

    // MARK: Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = items {
            return min(items.count, expanded ? maxNumberOfRows : defaultNumRows)
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RSSItem", forIndexPath: indexPath) as RSSItemTableViewCell

        if let item = items?[indexPath.row] {
            cell.titleLabel.text = item.title
            cell.authorLabel.text = item.author
            cell.dateLabel.text = dateFormatter.stringFromDate(item.pubDate)
        }

        return cell
    }

    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return expandButton
    }

    // MARK: expand

    func updateExpandButtonTitle() {
        expandButton.setTitle(expanded ? "Show less" : "Show more", forState: .Normal)
    }

    func toggleExpand() {
        expanded = !expanded
        updateExpandButtonTitle()
        updatePreferredContentSize()
        tableView.reloadData()
    }
}
