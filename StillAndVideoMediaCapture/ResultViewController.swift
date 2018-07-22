//
//  ResultViewController.swift
//  StillAndVideoMediaCapture
//
//  Created by 홍창남 on 2018. 7. 22..
//  Copyright © 2018년 홍창남. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var images: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.animationImages = images
        imageView.animationDuration = Double(images.count) * 0.2
        imageView.animationRepeatCount = 0
        imageView.startAnimating()
    }
    
    @IBAction func cancelBtnTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
