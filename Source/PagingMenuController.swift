//
//  PagingMenuController.swift
//  PagingMenu
//
//  Created by LC on 2023/9/15.
//

import UIKit

public protocol PagingMenuControllerDelegate: AnyObject {
    func pagingMenuController(_ pagingMenuController: PagingMenuController, didSelectAt index: Int)
}


public class PagingMenuController: UIViewController, UIScrollViewDelegate, PagingMenuViewDelegate {
    
    public var menuHeight: CGFloat = 44
    public weak var deledate: PagingMenuControllerDelegate?
    public var itemSpacing: CGFloat { get { menuView.spacing } set { menuView.spacing = newValue } }
    public var menuInset = UIEdgeInsets.zero
    public var normalStyle:PagingBarItemStyle? { get { menuView.normalStyle } set { menuView.normalStyle = newValue } }
    public var selectedStyle:PagingBarItemStyle? { get { menuView.selectedStyle } set { menuView.selectedStyle = newValue } }
    public var menuAlignCenter: Bool { get { menuView.isAlignCenter } set { menuView.isAlignCenter = newValue } }
    public var items: ([PagingBarItemProvider],[PagingContainerItemProvider])? {
        didSet {
            oldValue?.1.forEach({ vc in
                vc.removeFromSuper()
            })
            
            menuView.items = items?.0
            if let w = contentWidth {
                NSLayoutConstraint.deactivate([w])
                contentWidth = contentView.widthAnchor.constraint(equalTo: view.widthAnchor ,multiplier: CGFloat(items?.1.count ?? 1))
                contentWidth?.isActive = true
                scrollView.contentOffset = .zero
            }
        }
    }
    public var selectedIndex: Int {
        get {
            menuView.selectedIndex
        }
        set {
            menuView.setSelectedIndex(newValue, animated: false)
            showSelectedViewController(newValue)
            scrollView.setContentOffset(CGPoint(x: scrollView.frame.width * CGFloat(newValue), y: 0), animated: false)
        }
    }
    public var selectedBackgroundView: UIView? {
        get { menuView.selectedBackgroundView }
        set { menuView.selectedBackgroundView = newValue }
    }

    private let menuView = PagingMenuView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var contentWidth: NSLayoutConstraint?
    private var isPageItemActionScroll = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        menuView.delegate = self
        menuView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuView)
        NSLayoutConstraint.activate([
            menuView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -menuInset.right),
            menuView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: menuInset.left),
            menuView.topAnchor.constraint(equalTo: view.topAnchor, constant: menuInset.top),
            menuView.heightAnchor.constraint(equalToConstant: menuHeight)
        ])

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: menuView.bottomAnchor, constant: menuInset.bottom),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentWidth = contentView.widthAnchor.constraint(equalTo: view.widthAnchor ,multiplier: CGFloat(items?.1.count ?? 1))
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentWidth!
        ])
        showSelectedViewController(selectedIndex)
    }

    public func updateItem(_ item: PagingBarItemProvider, at index: Int) {
        menuView.updateItem(item, at: index)
    }
    
    public func pagingMenuView(_ pageMenu: PagingMenuView, didSelectAt index: Int) {
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.width * CGFloat(index), y: 0), animated: false)
        showSelectedViewController(index)
    }
    
    private func showSelectedViewController(_ selectedIndex: Int) {
        
        let width = scrollView.bounds.width

        guard let vcs = items?.1 else {
            return
        }

        let selectedController = vcs[selectedIndex]
        if selectedController.container.superview == nil {
            selectedController.addToSuper(contentView, pagingMenuController: self)
            selectedController.container.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                selectedController.container.widthAnchor.constraint(equalTo: view.widthAnchor),
                selectedController.container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: width * CGFloat(selectedIndex)),
                selectedController.container.topAnchor.constraint(equalTo: contentView.topAnchor),
                selectedController.container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

        }
        self.deledate?.pagingMenuController(self, didSelectAt: selectedIndex)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        menuView.setSelectedIndex(Int(scrollView.contentOffset.x/scrollView.bounds.width), animated: true)
        showSelectedViewController(menuView.selectedIndex)
    }
}
