//
//  PagingContainerItemProvider.swift
//  PagingMenu
//
//  Created by LC on 2023/11/8.
//

import UIKit

public protocol PagingContainerItemProvider {
    var container: UIView { get }
    func addToSuper(_ superView: UIView, pagingMenuController: PagingMenuController)
    func removeFromSuper()
}

extension UIViewController: PagingContainerItemProvider {
    public var container: UIView {
        view
    }
    
    public func addToSuper(_ superView: UIView, pagingMenuController: PagingMenuController)  {
        pagingMenuController.addChild(self)
        superView.addSubview(view)
        pagingMenuController.didMove(toParent: self)
    }
    
    public func removeFromSuper() {
        removeFromParent()
        view.removeFromSuperview()
    }
}

extension UIView: PagingContainerItemProvider {
    public var container: UIView {
        self
    }
    
    public func addToSuper(_ superView: UIView, pagingMenuController: PagingMenuController) {
        superView.addSubview(self)
    }
    
    public func removeFromSuper() {
        removeFromSuperview()
    }
}
