//
//  PreviewViewController.swift
//  Deep Sense
//
//  Created by Ahmed Bekhit on 10/22/16.
//  Copyright © 2016 fvergara. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    @IBOutlet var poemScroll: UIScrollView!
    @IBOutlet var prevImage: UIImageView!
    var imagesArray: [Data]! = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loopit()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {

    }
    
    func loopit(){
        prevImage.image = UIImage(data: imagesArray[0])!
        prevImage.animationImages = [UIImage(data: imagesArray[0])!, UIImage(data: imagesArray[1])!, UIImage(data: imagesArray[2])!, UIImage(data: imagesArray[3])!, UIImage(data: imagesArray[4])!, UIImage(data: imagesArray[5])!, UIImage(data: imagesArray[6])!, UIImage(data: imagesArray[7])!, UIImage(data: imagesArray[8])!, UIImage(data: imagesArray[9])!]
        prevImage.animationDuration = 0.5
        prevImage.startAnimating();
    }
    @IBAction func closeImage(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeview")
            self.present(vc!, animated: true, completion: nil)
        })

    }
    
    @IBAction func scrollIt(_ sender: AnyObject) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
