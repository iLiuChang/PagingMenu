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


public class PagingMenuController: UIViewController, UIScrollViewDelegate, PagingBarViewDelegate {
    
    /// bar height
    public var barHeight: CGFloat = 44
    public weak var deledate: PagingMenuControllerDelegate?
    /// spacing between the bar items. default is 15
    public var barItemSpacing: CGFloat { get { barView.spacing } set { barView.spacing = newValue } }
    public var barInset = UIEdgeInsets.zero
    public var barItemNormalStyle:PagingBarItemStyle? { get { barView.normalStyle } set { barView.normalStyle = newValue } }
    public var barItemSelectedStyle:PagingBarItemStyle? { get { barView.selectedStyle } set { barView.selectedStyle = newValue } }
    /// whether the overall content is centered
    public var barContentCenter: Bool { get { barView.contentCenter } set { barView.contentCenter = newValue } }
    /// $0.0: can use `PagingBarItemTitle`,`PagingBarItemAttributedTitle`,`String`. You can also use `PagingBarItemProvider` to customize
    /// $0.1: can use `UIViewController`,`UIView`. You can also use `PagingContainerItemProvider` to customize
    public var items: ([PagingBarItemProvider],[PagingContainerItemProvider])? {
        didSet {
            oldValue?.1.forEach({  $0.removeFromSuper(self) })
            barView.items = items?.0
            if let w = contentWidth {
                NSLayoutConstraint.deactivate([w])
                contentWidth = contentView.widthAnchor.constraint(equalTo: view.widthAnchor ,multiplier: CGFloat(items?.1.count ?? 1))
                contentWidth?.isActive = true
                scrollView.contentOffset = .zero
            }
            showSelectedViewController(selectedIndex)
        }
    }
    public var selectedIndex: Int {
        get {
            barView.selectedIndex
        }
        set {
            barView.setSelectedIndex(newValue, animated: false)
            showSelectedViewController(newValue)
            scrollView.setContentOffset(CGPoint(x: scrollView.frame.width * CGFloat(newValue), y: 0), animated: false)
        }
    }

    /// after setting, the frame is equal to the frame of the currently selected bar item.
    public var barItemSelectedBackgroundView: UIView? {
        get { barView.selectedBackgroundView }
        set { barView.selectedBackgroundView = newValue }
    }

    private let barView = PagingBarView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var contentWidth: NSLayoutConstraint?
    private var isPageItemActionScroll = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        barView.delegate = self
        barView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(barView)
        NSLayoutConstraint.activate([
            barView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -barInset.right),
            barView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: barInset.left),
            barView.topAnchor.constraint(equalTo: view.topAnchor, constant: barInset.top),
            barView.heightAnchor.constraint(equalToConstant: barHeight)
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
            scrollView.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: barInset.bottom),
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
        if UIView.appearance().semanticContentAttribute == .forceRightToLeft {
            scrollView.transform = CGAffineTransform(scaleX:-1,y: 1)
            contentView.transform = CGAffineTransform(scaleX:-1,y: 1)
        }
    }

    public func updateItem(_ item: PagingBarItemProvider, at index: Int) {
        barView.updateItem(item, at: index)
    }
    
    public func pagingBarView(_ pageMenu: PagingBarView, didSelectAt index: Int) {
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.width * CGFloat(index), y: 0), animated: false)
        showSelectedViewController(index)
    }
    
    private func showSelectedViewController(_ selectedIndex: Int) {
        
        let width = scrollView.bounds.width

        guard let vcs = items?.1 else {
            return
        }

        let selectedController = vcs[selectedIndex]
        if selectedController.pagingContainerItemView.superview == nil {
            selectedController.addToSuper(contentView, pagingMenuController: self)
            selectedController.pagingContainerItemView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                selectedController.pagingContainerItemView.widthAnchor.constraint(equalTo: view.widthAnchor),
                selectedController.pagingContainerItemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: width * CGFloat(selectedIndex)),
                selectedController.pagingContainerItemView.topAnchor.constraint(equalTo: contentView.topAnchor),
                selectedController.pagingContainerItemView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

        }
        self.deledate?.pagingMenuController(self, didSelectAt: selectedIndex)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        barView.setSelectedIndex(Int(scrollView.contentOffset.x/scrollView.bounds.width), animated: true)
        showSelectedViewController(barView.selectedIndex)
    }
}
