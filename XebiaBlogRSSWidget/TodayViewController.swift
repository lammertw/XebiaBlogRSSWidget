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
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

                completionHandler(.NewData)
            },
            failure: { error in
                println(error)
                completionHandler(.Failed)
                
        })
    }
    
}
