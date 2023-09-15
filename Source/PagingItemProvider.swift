//
//  PagingItemProvider.swift
//  PagingMenu
//
//  Created by LC on 2023/9/15.
//

import UIKit

public protocol PagingItemProvider {
    var normalAttributedTitle: NSAttributedString { get }
    var selectedAttributedTitle: NSAttributedString { get }
}

public struct PagingItemStyle {
    public var color: UIColor
    public var font: UIFont
}

public struct PagingItemTitle: PagingItemProvider {
    public var normal: String
    public var select: String
    
    public var normalAttributedTitle: NSAttributedString {
        return NSAttributedString(string: normal)
    }
    
    public var selectedAttributedTitle: NSAttributedString {
        return NSAttributedString(string: select)
    }
}

public struct PagingItemAttributedTitle: PagingItemProvider {
    public var normal: NSAttributedString
    public var select: NSAttributedString
    
    public var normalAttributedTitle: NSAttributedString {
        return normal
    }
    
    public var selectedAttributedTitle: NSAttributedString {
        return select
    }
}


extension String: PagingItemProvider {
    public var normalAttributedTitle: NSAttributedString {
        return NSAttributedString(string: self)
    }
    
    public var selectedAttributedTitle: NSAttributedString {
        return NSAttributedString(string: self)
    }
}
