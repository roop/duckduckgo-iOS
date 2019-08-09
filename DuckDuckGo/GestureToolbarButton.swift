//
//  BookmarksButton.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

protocol GestureToolbarButtonDelegate: NSObjectProtocol {
    
    func singleTapDetected(in sender: GestureToolbarButton)
    func longPressStarted(in sender: GestureToolbarButton)
    func longPressCanceled(in sender: GestureToolbarButton)
    func longPressDetected(in sender: GestureToolbarButton)
    
}

class GestureToolbarButton: UIView {
    
    struct Constants {
        static let startLongPressDuration = 0.3
        static let minLongPressDuration = 0.8
        static let maxTouchDeviationPoints = 20.0
        static let animationDuration = 0.3
    }
    
    // UIToolBarButton size would be 29X44 and it's imageview size would be 24X24
    struct ToolbarButton {
        static let Width = 29.0
        static let Height = 44.0
        static let ImageWidth = 24.0
        static let ImageHeight = 24.0
    }
    
    weak var delegate: GestureToolbarButtonDelegate?

    let iconImageView = UIImageView(frame: CGRect(x: 2.5, y: 10, width: ToolbarButton.ImageWidth, height: ToolbarButton.ImageHeight))
    let progressView = LongPressProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

    var image: UIImage? {
        didSet {
            iconImageView.image = image
            progressView.image = image
        }
    }
    
    var touching = false
    var longPressStarted = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(iconImageView)
    }

    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: ToolbarButton.Width, height: ToolbarButton.Height))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    fileprivate func imposePressAnimation() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.iconImageView.alpha = 0.2
        }
    }
    
    fileprivate func imposeReleaseAnimation() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.iconImageView.alpha = 1.0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("***", #function, touching)
        longPressStarted = false
        imposePressAnimation()
        touching = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.startLongPressDuration, execute: handleLongPressStarted)
    }
    
    func handleLongPressStarted() {
        print("***", #function, touching)
        guard touching else { return }
        longPressStarted = true
        delegate?.longPressStarted(in: self)
        
        let deadline = Constants.minLongPressDuration - Constants.startLongPressDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + deadline, execute: handleLongPressTriggered)
    }

    func handleLongPressTriggered() {
        print("***", #function, touching)
        guard touching else { return }
        longPressStarted = false
        touching = false
        delegate?.longPressDetected(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("***", #function, touching)
        
        guard !longPressStarted else {
            longPressStarted = false
            touching = false
            delegate?.longPressCanceled(in: self)
            imposeReleaseAnimation()
            return
        }
        
        guard touching else {
            imposeReleaseAnimation()
            longPressStarted = false
            return
        }
        
        touching = false
        
        guard let touch = touches.first else {
            imposeReleaseAnimation()
            return
        }
        
        guard point(inside: touch.location(in: self), with: event) else {
            imposeReleaseAnimation()
            return
        }
        delegate?.singleTapDetected(in: self)
        imposeReleaseAnimation()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.longPressCanceled(in: self)
        imposeReleaseAnimation()
    }
    
}

extension GestureToolbarButton: Themable {
    
    func decorate(with theme: Theme) {
        backgroundColor = theme.barBackgroundColor
        tintColor = theme.barTintColor
    }
    
}
