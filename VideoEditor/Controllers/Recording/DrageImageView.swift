//
//  DrageImageView.swift
//  VideoEditor
//
//  Copyright © 2018 Ark Inc. All rights reserved.
//

import Foundation
import UIKit

class DrageImageView: UIImageView, UIGestureRecognizerDelegate {
    
    var lastLocation = CGPoint(x: 0, y: 0)
    var identity = CGAffineTransform.identity

    func addDashedBorder() {
        let color = UIColor.red.cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 3
        shapeLayer.lineJoin = kCALineCapSquare
        shapeLayer.lineDashPattern = [6,6]
        shapeLayer.path = UIBezierPath(rect: shapeRect).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    func AddGestureForOverlayImage()
    {
//        let yourViewBorder = CAShapeLayer()
//        yourViewBorder.strokeColor = UIColor.red.cgColor
//        yourViewBorder.lineDashPattern = [2, 2]
//        yourViewBorder.frame = self.bounds
//        yourViewBorder.fillColor = nil
//        yourViewBorder.path = UIBezierPath(rect: self.bounds).cgPath
//        self.layer.addSublayer(yourViewBorder)
        self.addDashedBorder()
        self.isUserInteractionEnabled = true
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(DrageImageView.detectPan(_:)))
        self.gestureRecognizers = [panRecognizer]
        
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(DrageImageView.pinchScale(_:)))
        pinchGesture.delegate = self
        self.addGestureRecognizer(pinchGesture)

//        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(DrageImageView.longPress(_:)))
//        longGesture.minimumPressDuration = 0.5
//        self.addGestureRecognizer(longGesture)
    }
    @objc func longPress(_ sender: UILongPressGestureRecognizer)
    {
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        actionSheet.addAction(UIAlertAction.init(title: "Delete", style: UIAlertActionStyle.default, handler: { (action) in
            
            self.image = nil
            
        }))
        actionSheet.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            
        }))
        actionSheet.popoverPresentationController?.sourceView = sender.view // works for both iPhone & iPad

        //Present the controller
        self.window?.rootViewController?.present(actionSheet, animated: true, completion: nil)
        
        //        self.present(alertC, animated: true, completion: nil)
    }
    @objc func detectPan(_ recognizer:UIPanGestureRecognizer) {
        let translation  = recognizer.translation(in: self.superview)
        
        var newCenter: CGPoint = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
        
        if (newCenter.x + self.frame.size.width/2) > (self.superview?.frame.size.width)! || (newCenter.x - self.frame.size.width/2) < 0
        {
            newCenter.x = self.center.x
        }
        if (newCenter.y + self.frame.size.height/2) > (self.superview?.frame.size.height)! || ((self.superview?.frame.size.height)! - (newCenter.y + self.frame.size.height/2)) < 0
        {
            newCenter.y = self.center.y
        }
        
        self.center = newCenter
        
        //        if newCenter
    }
    
    override func touchesBegan(_ touches: (Set<UITouch>!), with event: UIEvent!) {
        // Promote the touched view
        self.superview?.bringSubview(toFront: self)
        
        // Remember original location
        lastLocation = self.center
    }
    @objc func pinchScale(_ gesture:UIPinchGestureRecognizer)
    {
        switch gesture.state {
        case .began:
            identity = self.transform
        case .changed,.ended:
            self.transform = identity.scaledBy(x: gesture.scale, y: gesture.scale)
        case .cancelled:
            break
        default:
            break
        }
    }
}
