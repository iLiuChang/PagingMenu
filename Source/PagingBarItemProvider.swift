//
//  PagingBarItemProvider.swift
//  PagingMenu
//
//  Created by LC on 2023/9/15.
//

import UIKit

public protocol PagingBarItemProvider {
    var normalAttributedTitle: NSAttributedString { get }
    var selectedAttributedTitle: NSAttributedString { get }
}

public struct PagingBarItemStyle {
    public var color: UIColor?
    public var font: UIFont?
    public var backgroundImage: UIImage?
    public var cornerRadius: CGFloat?
    public var contentEdgeInsets: UIEdgeInsets?
    public var alpha: CGFloat? // The alpha of the UIButton's imageView and titleLabel.

    public init(color: UIColor? = nil, font: UIFont? = nil, backgroundImage: UIImage? = nil, cornerRadius: CGFloat? = nil, contentEdgeInsets: UIEdgeInsets? = nil, alpha: CGFloat? = nil) {
        self.color = color
        self.font = font
        self.backgroundImage = backgroundImage
        self.cornerRadius = cornerRadius
        self.contentEdgeInsets = contentEdgeInsets
        self.alpha = alpha
    }
    
}

public struct PagingBarItemTitle: PagingBarItemProvider {
    public var normal: String
    public var select: String
    
    public init(normal: String, select: String) {
        self.normal = normal
        self.select = select
    }
    
    public var normalAttributedTitle: NSAttributedString {
        return OnlyStringAttributedTitle(normal)
    }
    
    public var selectedAttributedTitle: NSAttributedString {
        return OnlyStringAttributedTitle(select)
    }
}

public struct PagingBarItemAttributedTitle: PagingBarItemProvider {
    public var normal: NSAttributedString
    public var select: NSAttributedString
    
    public init(normal: NSAttributedString, select: NSAttributedString) {
        self.normal = normal
        self.select = select
    }
    
    public var normalAttributedTitle: NSAttributedString {
        return normal
    }
    
    public var selectedAttributedTitle: NSAttributedString {
        return select
    }
}


extension String: PagingBarItemProvider {
    public var normalAttributedTitle: NSAttributedString {
        OnlyStringAttributedTitle(self)
    }
    
    public var selectedAttributedTitle: NSAttributedString {
        OnlyStringAttributedTitle(self)
    }
}

class OnlyStringAttributedTitle: NSAttributedString {
    private let title: String
    
    override var string: String { title }
    
    init(_ title: String) {
        self.title = title
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
