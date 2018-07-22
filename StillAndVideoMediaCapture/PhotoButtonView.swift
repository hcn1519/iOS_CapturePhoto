//
//  PhotoButtonView.swift
//  StillAndVideoMediaCapture
//
//  Created by 홍창남 on 2018. 7. 22..
//  Copyright © 2018년 홍창남. All rights reserved.
//

import UIKit

protocol PhotoButtonDelegate: class {
    func didTapButton()
}
class PhotoButtonView: UIView {

    weak var delegate: PhotoButtonDelegate?

    let progressLayer = CAShapeLayer()
    let prgressTime: CFTimeInterval = 2.0

    func setBorder() {
        progressLayer.lineWidth = 2.0
        progressLayer.frame = self.bounds
        progressLayer.strokeColor = UIColor.yellow.cgColor
        progressLayer.strokeEnd = 0
        progressLayer.fillColor = nil
        progressLayer.path = UIBezierPath(arcCenter: self.center,
                                          radius: self.bounds.width / 2,
                                          startAngle: 0,
                                          endAngle: CGFloat(Double.pi * 2),
                                          clockwise: true).cgPath
//        progressLayer.path = UIBezierPath(ovalIn: self.bounds).cgPath
        self.layer.addSublayer(progressLayer)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setBorder()

        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        self.addGestureRecognizer(gesture)
    }

    @objc func viewTap() {

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = prgressTime
        animation.timingFunction = CAMediaTimingFunction(name: "easeInEaseOut")
        animation.toValue = 1
        progressLayer.add(animation, forKey: "line")
        delegate?.didTapButton()
    }
}
