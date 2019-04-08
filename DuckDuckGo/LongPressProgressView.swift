//
//  LongPressProgressView.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 08/04/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import UIKit
import Lottie

class LongPressProgressView: UIView {
    
    let lottie = AnimationView(name: "long_press_progress")
    let progressIcon = UIImageView(frame: .zero)
    
    var image: UIImage? {
        didSet {
            progressIcon.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        lottie.logHierarchyKeypaths()
        
        lottie.frame = frame
        lottie.animationSpeed = 10
        
        lottie.setValueProvider(ColorValueProvider(Color(r: 0, g: 0, b: 0, a: 1)),
                                keypath: AnimationKeypath(keypath: "circle Outlines.Group 1.Fill 1.Color"))
        addSubview(lottie)

        progressIcon.frame = frame
        progressIcon.contentMode = .center
        progressIcon.tintColor = UIColor.white
        addSubview(progressIcon)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func play() {
        lottie.currentTime = 0.0
        lottie.play()
    }
    
}
