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
    public var color: UIColor
    public var font: UIFont
}

public struct PagingBarItemTitle: PagingBarItemProvider {
    public var normal: String
    public var select: String
    
    public var normalAttributedTitle: NSAttributedString {
        return NSAttributedString(string: normal)
    }
    
    public var selectedAttributedTitle: NSAttributedString {
        return NSAttributedString(string: select)
    }
}

public struct PagingBarItemAttributedTitle: PagingBarItemProvider {
    public var normal: NSAttributedString
    public var select: NSAttributedString
    
    public var normalAttributedTitle: NSAttributedString {
        return normal
    }
    
    public var selectedAttributedTitle: NSAttributedString {
        return select
    }
}


extension String: PagingBarItemProvider {
    public var normalAttributedTitle: NSAttributedString {
        return NSAttributedString(string: self)
    }
    
    public var selectedAttributedTitle: NSAttributedString {
        return NSAttributedString(string: self)
    }
}
