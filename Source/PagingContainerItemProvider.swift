//
//  PagingContainerItemProvider.swift
//  PagingMenu
//
//  Created by LC on 2023/11/8.
//

import UIKit

public protocol PagingContainerItemProvider {
    var pagingContainerItemView: UIView { get }
    func addToSuper(_ superView: UIView, pagingMenuController: PagingMenuController)
    func removeFromSuper(_ pagingMenuController: PagingMenuController)
}

extension UIViewController: PagingContainerItemProvider {
    public var pagingContainerItemView: UIView {
        view
    }
    
    public func addToSuper(_ superView: UIView, pagingMenuController: PagingMenuController)  {
        pagingMenuController.addChild(self)
        superView.addSubview(view)
        pagingMenuController.didMove(toParent: self)
    }
    
    public func removeFromSuper(_ pagingMenuController: PagingMenuController) {
        removeFromParent()
        view.removeFromSuperview()
    }
}

extension UIView: PagingContainerItemProvider {
    public var pagingContainerItemView: UIView {
        self
    }
    
    public func addToSuper(_ superView: UIView, pagingMenuController: PagingMenuController) {
        superView.addSubview(self)
    }
    
    public func removeFromSuper(_ pagingMenuController: PagingMenuController) {
        removeFromSuperview()
    }
}
