//
//  SwipeActionButton.swift
//
//  Created by Jeremy Koch.
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

class SwipeActionButton: UIButton {
    var spacing: CGFloat = 8
    var shouldHighlight = true
    var highlightedBackgroundColor: UIColor?

    var maximumImageHeight: CGFloat = 0
    var verticalAlignment: SwipeVerticalAlignment = .centerFirstBaseline
    
    var currentSpacing: CGFloat {
        return (currentTitle?.isEmpty == false && maximumImageHeight > 0) ? spacing : 0
    }
    
    var alignmentRect: CGRect {
        let contentRect = self.contentRect(forBounds: bounds)
        let titleHeight = titleBoundingRect(with: verticalAlignment == .centerFirstBaseline ? CGRect.infinite.size : contentRect.size).integral.height
        let totalHeight = maximumImageHeight + titleHeight + currentSpacing

        return contentRect.center(size: CGSize(width: contentRect.width, height: totalHeight))
    }
    
    convenience init(action: SwipeAction) {
        self.init(frame: .zero)

        contentHorizontalAlignment = .center
        
        tintColor = action.textColor ?? .white
        let highlightedTextColor = action.highlightedTextColor ?? tintColor
        highlightedBackgroundColor = action.highlightedBackgroundColor ?? UIColor.black.withAlphaComponent(0.1)

        titleLabel?.font = action.font ?? UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        titleLabel?.textAlignment = .center
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.numberOfLines = 0
        
        accessibilityLabel = action.accessibilityLabel
        
        setTitle(action.title, for: .normal)
        setTitleColor(tintColor, for: .normal)
        setTitleColor(highlightedTextColor, for: .highlighted)
        setImage(action.image, for: .normal)
        setImage(action.highlightedImage ?? action.image, for: .highlighted)
        
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1).cgColor
    }
    
    override var isHighlighted: Bool {
        didSet {
            guard shouldHighlight else { return }
            
            backgroundColor = isHighlighted ? highlightedBackgroundColor : .clear
        }
    }
    
    func preferredWidth(maximum: CGFloat) -> CGFloat {
        let width = maximum > 0 ? maximum : CGFloat.greatestFiniteMagnitude
        let textWidth = titleBoundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).width
        let imageWidth = currentImage?.size.width ?? 0
        
        return min(width, max(textWidth, imageWidth) + contentEdgeInsets.left + contentEdgeInsets.right)
    }
    
    func titleBoundingRect(with size: CGSize) -> CGRect {
        guard let title = currentTitle, let font = titleLabel?.font else { return .zero }
        
        return title.boundingRect(with: size,
                                  options: [.usesLineFragmentOrigin],
                                  attributes: [NSAttributedStringKey.font: font],
                                  context: nil).integral
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = contentRect.center(size: titleBoundingRect(with: contentRect.size).size)
        rect.origin.y = alignmentRect.minY + maximumImageHeight + currentSpacing
        return rect.integral
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = contentRect.center(size: currentImage?.size ?? .zero)
        rect.origin.y = alignmentRect.minY + (maximumImageHeight - rect.height) / 2
        return rect
    }
}

extension CGRect {
    func center(size: CGSize) -> CGRect {
        let dx = width - size.width
        let dy = height - size.height
        return CGRect(x: origin.x + dx * 0.5, y: origin.y + dy * 0.5, width: size.width, height: size.height)
    }
}
