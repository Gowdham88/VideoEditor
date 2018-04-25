//
//  CameraFocusSquare.swift
//  VideoEditor
//
//  Copyright © 2018 Ark Inc. All rights reserved.
//

import Foundation
import UIKit
class CameraFocusSquare: UIView,CAAnimationDelegate {
    
    var isSliderDragging: Bool!
    var exposureSliderView: UIView!
    var exposureSlider: VerticalSlider!
    
    var focusColorView: UIView!
    internal let kSelectionAnimation:String = "selectionAnimation"
    
    fileprivate var _selectionBlink: CABasicAnimation?
    
    convenience init(touchPoint: CGPoint) {
        self.init()
        isSliderDragging = false
//        self.exposureSliderView = UIView.init()
//
//        self.exposureSlider = VerticalSlider.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 140))
//        self.exposureSlider.minimumTrackTintColor = UIColor.init(hex: "F9CC02", alpha: 1.0)
//        self.exposureSlider.maximumTrackTintColor = UIColor.init(hex: "F9CC02", alpha: 1.0)
        
//        self.exposureSliderView.addSubview(self.exposureSlider)
//        self.addSubview(self.exposureSliderView!)
        
        self.focusColorView = UIView.init()
        self.addSubview(self.focusColorView)
        self.updatePoint(touchPoint)
        self.backgroundColor = UIColor.clear
        self.focusColorView.backgroundColor = UIColor.clear
        self.focusColorView.layer.borderWidth = 1.0
        self.focusColorView.layer.borderColor = UIColor.init(hex: "F9CC02", alpha: 1.0).cgColor

//        self.layer.borderColor = UIColor.yellow.cgColor
        initBlink()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    fileprivate func initBlink() {
        // create the blink animation
        self._selectionBlink = CABasicAnimation(keyPath: "borderColor")
        
//        self._selectionBlink!.toValue = (UIColor.yellow.cgColor as AnyObject)

        self._selectionBlink!.toValue = (UIColor.init(hex: "F9CC02", alpha: 0.7).cgColor as AnyObject)
        self._selectionBlink!.repeatCount = 3
        // number of blinks
        self._selectionBlink!.duration = 0.7
        // this is duration per blink
        self._selectionBlink!.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func isSliderBegan()
    {
        
    }
    func isSliderChanging()
    {
        isSliderDragging = true
        if isSliderDragging
        {
            
        }
        if self.focusColorView.layer.animation(forKey: kSelectionAnimation) != nil
        {
            self.focusColorView.layer.removeAnimation(forKey: kSelectionAnimation)
        }
        
//        self._selectionBlink!.repeatCount = Float(CGFloat.greatestFiniteMagnitude)
//        // number of blinks
//        self._selectionBlink!.duration = 0.0
    }
    func isSliderEnded()
    {
        self.animateFocusingAction()
        isSliderDragging = false
    }
    /**
     Updates the location of the view based on the incoming touchPoint.
     */
    
    func updatePoint(_ touchPoint: CGPoint) {
        let squareWidth: CGFloat = 100
        let frame: CGRect = CGRect(x: touchPoint.x - squareWidth / 2, y: touchPoint.y - squareWidth / 2, width: squareWidth, height: squareWidth)
        self.frame = frame

        self.focusColorView.frame = self.bounds
//        self.exposureSliderView.frame = CGRect.init(x: frame.origin.x + frame.size.width, y: frame.origin.y - 20, width: 50, height: 140)
    }
    /**
     This unhides the view and initiates the animation by adding it to the layer.
     */
    
    func animateFocusingAction() {
        
        if let blink = _selectionBlink {
            // make the view visible
            self.alpha = 1.0
            self.isHidden = false
            // initiate the animation
            self.focusColorView.layer.add(blink, forKey: kSelectionAnimation)
        }
        
    }
    /**
     Hides the view after the animation stops. Since the animation is automatically removed, we don't need to do anything else here.
     */
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool){
        
        
        if flag
        {
            // hide the view
            self.alpha = 0.0
            self.isHidden = true
        }
}
}
