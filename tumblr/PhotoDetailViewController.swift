//
//  PhotoDetailViewController.swift
//  tumblr
//
//  Created by Ming Horn on 6/16/16.
//  Copyright © 2016 Ming Horn. All rights reserved.
//

import UIKit


class PhotoDetailViewController: UIViewController {
    
    var imageURLViaSegue = ""

    @IBOutlet weak var detailImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageUrl = NSURL(string: imageURLViaSegue)
        detailImageView.setImageWithURL(imageUrl!)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
