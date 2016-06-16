//
//  PhotosViewController.swift
//  tumblr
//
//  Created by Ming Horn on 6/16/16.
//  Copyright © 2016 Ming Horn. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class PhotosViewController: UIViewController, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var posts: [NSDictionary] = [] // Holds the posts
    var isMoreDataLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.rowHeight = 240
        
        //Show HUD before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        sendRequest("hud", refreshControl: nil)
        
        //Initialize a new refresh control instance
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(!isMoreDataLoading)
        {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffSetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            if(scrollView.contentOffset.y > scrollOffSetThreshold && tableView.dragging)
            {
                isMoreDataLoading = true
            }
        }
        
        isMoreDataLoading = true
    }
    
    
    func sendRequest(type: String, refreshControl: UIRefreshControl?) {
        let apiKey = "Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
        let url = NSURL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
            //check what type of request it is and how to display loading
            if(type == "hud") {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            } else if (type == "ref") {
                refreshControl!.endRefreshing()
            }
            
            self.isMoreDataLoading = false
            
            
            //async callback            
            if let data = dataOrNil {
                //Parse JSON into a NSDictionary and load it into a constant "responseDictionary"
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data, options:[]) as? NSDictionary {
                    let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                    let newDictionary = responseFieldDictionary["posts"] as! [NSDictionary]
                    self.posts.appendContentsOf(newDictionary)
                    print(self.posts)
                    //print("response: \(responseDictionary)")
                    self.tableView.reloadData()
                }
            }
        })
        task.resume()
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell") as! PhotoCell
        let post = posts[indexPath.row]
        let timestamp = post["timestamp"] as? String
        if let photos = post.valueForKeyPath("photos") as? [NSDictionary] {
            let imageUrlString = photos[0].valueForKeyPath("original_size.url") as? String
            if let imageUrl = NSURL(string: imageUrlString!) {
                cell.photo.setImageWithURL(imageUrl)
            } else {
                print("No photo")
            }
        } else {
            print("no photos")
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var vc = segue.destinationViewController as! PhotoDetailViewController
        var indexPath1 = tableView.indexPathForCell(sender as! UITableViewCell)
        let post = posts[indexPath1!.row]
        if let photos = post.valueForKeyPath("photos") as? [NSDictionary] {
            let imageUrlString = photos[0].valueForKeyPath("original_size.url") as? String
            if let imageUrl = NSURL(string: imageUrlString!) {
                vc.imageURLViaSegue = imageUrlString!
            } else {
                print("No photo")
            }
        } else {
            print("no photos")
        }

        
        
        
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        sendRequest("ref", refreshControl: refreshControl)
    }
}
