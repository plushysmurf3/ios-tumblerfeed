//
//  PhotosViewController.swift
//  tumblerFeed
//
//  Created by Savio Tsui on 10/13/16.
//  Copyright © 2016 Savio Tsui. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var posts:Array<AnyObject> = Array<AnyObject>()
    
    let refreshControl = UIRefreshControl()
    private let apiKey = "Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
    private var offset = 0
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.rowHeight = 320
        tableView.dataSource = self
        tableView.delegate = self
        
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let rootResponse = try! JSONSerialization.jsonObject(with: data, options:[]) as? Dictionary<String, AnyObject> {
                    let response = rootResponse["response"] as? Dictionary<String, AnyObject>
                    self.posts = (response?["posts"] as? Array<AnyObject>)!
                    NSLog("posts: \(self.posts)")
                    self.offset = self.posts.count
                    self.tableView.reloadData()
                }
            }
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PhotoDetailsViewController
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
        let post = self.posts[(indexPath?.row)!]
        
        let url = (((((post as! Dictionary<String, AnyObject>)["photos"] as! Array<AnyObject>)[0] as! Dictionary<String, AnyObject>)["alt_sizes"] as! Array<AnyObject>)[1] as? Dictionary<String, AnyObject>)?["url"] as? String
        
        // let url = ((((((post as? NSDictionary)?.value(forKey: "photos") as? NSArray?)??[0] as? NSDictionary)?.value(forKey: "alt_sizes") as? NSArray?)??[1] as? NSDictionary)?.value(forKey: "url") as? String?)!

        vc.url = url
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "com.saviotsui.TableViewCellPrototype", for: indexPath as IndexPath) as! TableViewCellPrototype
        let post = self.posts[indexPath.row]
        // let slug = ((post as? NSDictionary)?.value(forKey: "slug") as? String?)!
        let slug = (post as! Dictionary<String, AnyObject>)["slug"] as! String
        // let url = ((((((post as? NSDictionary)?.value(forKey: "photos") as? NSArray?)??[0] as? NSDictionary)?.value(forKey: "alt_sizes") as? NSArray?)??[1] as? NSDictionary)?.value(forKey: "url") as? String?)!
        let url = (((((post as! Dictionary<String, AnyObject>)["photos"] as! Array<AnyObject>)[0] as! Dictionary<String, AnyObject>)["alt_sizes"] as! Array<AnyObject>)[1] as? Dictionary<String, AnyObject>)?["url"] as? String
        cell.cellLabel.text = slug
        cell.cellImage.setImageWith(URL(string: url!)!)
        cell.cellImage.contentMode = .scaleAspectFit
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // ... Create the NSURLRequest (myRequest) ...
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=\(apiKey)&offset=\(offset)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let rootResponse = try! JSONSerialization.jsonObject(with: data, options:[]) as? Dictionary<String, AnyObject> {
                    let response = rootResponse["response"] as? Dictionary<String, AnyObject>
                    let newPosts = (response?["posts"] as? Array<AnyObject>)!
                    NSLog("new posts: \(newPosts)")
                    
                    self.posts.insert(contentsOf: newPosts, at: 0)
                    
                    // self.posts = self.posts.addingObjects(from: newPosts as! [Any]) as NSArray
                    self.offset += newPosts.count
                    
                    // Reload the tableView now that there is new data
                    self.tableView.reloadData()
                    
                    // Tell the refreshControl to stop spinning
                    refreshControl.endRefreshing()
                }
            }
        });
        task.resume()
    }
}

