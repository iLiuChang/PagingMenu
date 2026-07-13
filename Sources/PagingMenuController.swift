//
//  PagingMenuController.swift
//  PagingMenu
//
//  Created by LC on 2023/9/15.
//

import UIKit

public protocol PagingMenuControllerDelegate: AnyObject {
    func pagingMenuController(_ pagingMenuController: PagingMenuController, didSelectAt index: Int, actionBehavior: PagingMenuController.ActionBehavior)
    func pagingMenuController(_ pagingMenuController: PagingMenuController, didAddBarItemView view: UIView, forIndex index: Int)
    /// This only takes effect when `isScrollEnabled` is false.
    func pagingMenuController(_ pagingMenuController: PagingMenuController, shouldSelectAt index: Int) -> Bool
}

public extension PagingMenuControllerDelegate {
    func pagingMenuController(_ pagingMenuController: PagingMenuController, didAddBarItemView view: UIView, forIndex index: Int) { }
    func pagingMenuController(_ pagingMenuController: PagingMenuController, shouldSelectAt index: Int) -> Bool { true }
}

public class PagingMenuController: UIViewController, UIScrollViewDelegate, PagingBarViewDelegate {
    
    public enum ActionBehavior {
        case click
        case scroll
    }
    
    /// bar height
    public var barHeight: CGFloat = 44
    public weak var delegate: PagingMenuControllerDelegate?
    /// spacing between the bar items. default is 15
    public var barItemSpacing: CGFloat { get { barView.spacing } set { barView.spacing = newValue } }
    public var barItemWidth: CGFloat { get { barView.itemWidth } set { barView.itemWidth = newValue } }
    public var barInset = UIEdgeInsets.zero
    public var barItemNormalStyle:PagingBarItemStyle? { get { barView.normalStyle } set { barView.normalStyle = newValue } }
    public var barItemSelectedStyle:PagingBarItemStyle? { get { barView.selectedStyle } set { barView.selectedStyle = newValue } }
    /// whether the overall content is centered
    public var barAlignment: PagingBarView.Alignment { get { barView.alignment } set { barView.alignment = newValue } }
    /// default true. if true, bounces past edge of content and back again
    public var bounces: Bool { get { scrollView.bounces } set { scrollView.bounces = newValue }}
    /// default true. A Boolean value that determines whether scrolling is enabled.
    public var isScrollEnabled: Bool { get { scrollView.isScrollEnabled } set { scrollView.isScrollEnabled = newValue }}
    /// $0.0: can use `PagingBarItemTitle`,`PagingBarItemAttributedTitle`,`String`. You can also use `PagingBarItemProvider` to customize
    /// $0.1: can use `UIViewController`,`UIView`. You can also use `PagingContainerItemProvider` to customize
    public var items: ([PagingBarItemProvider],[PagingContainerItemProvider])? {
        didSet {
            oldValue?.1.forEach({ removeContainerItem($0) })
            barView.items = items?.0
            if let w = contentWidth {
                NSLayoutConstraint.deactivate([w])
                contentWidth = contentView.widthAnchor.constraint(equalTo: view.widthAnchor ,multiplier: CGFloat(items?.1.count ?? 1))
                contentWidth?.isActive = true
                scrollView.setContentOffsetXAfterContentSizeUpdate(0)
            }
            showSelectedViewController(0)
        }
    }
    public var selectedIndex: Int {
        get {
            barView.selectedIndex
        }
        set {
            barView.setSelectedIndex(newValue, animated: false)
            showSelectedViewController(newValue)
            if view.frame.width > 0 {
                scrollView.setContentOffsetXAfterContentSizeUpdate(view.frame.width * CGFloat(newValue))
            }
        }
    }

    /// after setting, the frame is equal to the frame of the currently selected bar item.
    public var barItemSelectedBackgroundView: UIView? {
        get { barView.selectedBackgroundView }
        set { barView.selectedBackgroundView = newValue }
    }

    private lazy var barView: PagingBarView = {
        let bar = PagingBarView()
        bar.delegate = self
        return bar
    }()
    
    private let scrollView = PagingScrollView()
    private let contentView = UIView()
    private var contentWidth: NSLayoutConstraint?
    private var containerItemConstraints = [ObjectIdentifier: [NSLayoutConstraint]]()
    private var lastLayoutWidth: CGFloat = 0

    public override func viewDidLoad() {
        super.viewDidLoad()
        
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
        view.insertSubview(scrollView, at: 0)
        NSLayoutConstraint.activate([
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: barInset.bottom),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentWidth = contentView.widthAnchor.constraint(equalTo: view.widthAnchor ,multiplier: CGFloat(items?.1.count ?? 1))
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            contentWidth!
        ])
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if lastLayoutWidth != view.bounds.width {
            reloadVisibleContainerItems()
            showSelectedViewController(selectedIndex)
        }
        lastLayoutWidth = view.bounds.width
        if !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating {
            scrollView.contentOffsetX = view.frame.width * CGFloat(selectedIndex)
        }
    }
    
    public func updateItem(_ item: PagingBarItemProvider, at index: Int) {
        barView.updateItem(item, at: index)
    }
    
    public func reloadBarStyle() {
        barView.reloadStyle()
    }
    
    public func pagingBarView(_ pageMenu: PagingBarView, didSelectAt index: Int) {
        scrollView.contentOffsetX = scrollView.frame.width * CGFloat(index)
        showSelectedViewController(index)
        delegate?.pagingMenuController(self, didSelectAt: barView.selectedIndex, actionBehavior: .click)
    }
    
    public func pagingBarView(_ pageMenu: PagingBarView, didAddItemView view: UIView, forIndex index: Int) {
        delegate?.pagingMenuController(self, didAddBarItemView: view, forIndex: index)
    }
    
    public func pagingBarView(_ pageMenu: PagingBarView, shouldSelectAt index: Int) -> Bool {
        if let result = delegate?.pagingMenuController(self, shouldSelectAt: index) {
            if !result && isScrollEnabled {
                print("[PagingMenu] Please set `isScrollEnabled` to false.")
                return true
            }
            return result
        }
        return true
    }
    
    private func showSelectedViewController(_ selectedIndex: Int) {
        
        let width = view.bounds.width

        guard let vcs = items?.1 else {
            return
        }
        
        if width == 0 {
            return
        }

        let selectedController = vcs[selectedIndex]
        let itemView = selectedController.pagingContainerItemView
        if itemView.superview == nil {
            selectedController.addToSuper(contentView, pagingMenuController: self)
            itemView.translatesAutoresizingMaskIntoConstraints = false
        }
        updateContainerItemConstraints(for: itemView, index: selectedIndex, width: width)
    }

    private func removeContainerItem(_ item: PagingContainerItemProvider) {
        let itemView = item.pagingContainerItemView
        if let constraints = containerItemConstraints.removeValue(forKey: ObjectIdentifier(itemView)) {
            NSLayoutConstraint.deactivate(constraints)
        }
        item.removeFromSuper(self)
    }

    private func updateContainerItemConstraints(for itemView: UIView, index: Int, width: CGFloat) {
        let key = ObjectIdentifier(itemView)
        if let constraints = containerItemConstraints.removeValue(forKey: key) {
            NSLayoutConstraint.deactivate(constraints)
        }
        var constraints = [
            itemView.widthAnchor.constraint(equalTo: view.widthAnchor),
            itemView.topAnchor.constraint(equalTo: contentView.topAnchor),
            itemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ]
        if isRightToLeftLayout {
            constraints.append(
                itemView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -width * CGFloat(index))
            )
        } else {
            constraints.append(
                itemView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: width * CGFloat(index))
            )
        }
        containerItemConstraints[key] = constraints
        NSLayoutConstraint.activate(constraints)
    }

    private func reloadVisibleContainerItems() {
        items?.1
            .filter { $0.pagingContainerItemView.superview === contentView }
            .forEach { removeContainerItem($0) }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let sv = scrollView as! PagingScrollView
        barView.setSelectedIndex(currentPageIndex(for: sv), animated: true)
        showSelectedViewController(barView.selectedIndex)
        delegate?.pagingMenuController(self, didSelectAt: barView.selectedIndex, actionBehavior: .scroll)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate, let sv = scrollView as? PagingScrollView else {
            return
        }
        barView.setSelectedIndex(currentPageIndex(for: sv), animated: true)
        showSelectedViewController(barView.selectedIndex)
        delegate?.pagingMenuController(self, didSelectAt: barView.selectedIndex, actionBehavior: .scroll)
    }

    private func currentPageIndex(for scrollView: PagingScrollView) -> Int {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else {
            return barView.selectedIndex
        }

        let rawIndex = scrollView.contentOffsetX / pageWidth
        let roundedIndex = Int(rawIndex.rounded())
        return pageIndex(roundedIndex)
    }

    private func pageIndex(_ index: Int) -> Int {
        let maxIndex = max(0, (items?.1.count ?? 1) - 1)
        return min(max(index, 0), maxIndex)
    }

    private var isRightToLeftLayout: Bool {
        view.effectiveUserInterfaceLayoutDirection == .rightToLeft
    }

    class PagingScrollView: UIScrollView {
        
        private var pendingContentOffsetX: CGFloat?
        override var contentSize: CGSize {
            didSet {
                applyPendingContentOffsetXIfPossible()
            }
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            applyPendingContentOffsetXIfPossible()
        }
        
        var contentOffsetX: CGFloat {
            get {
                if isRightToLeftLayout {
                    return contentSize.width - contentOffset.x - frame.width
                }
                return contentOffset.x
            }
            set {
                pendingContentOffsetX = nil
                
                if contentSize.width == 0 {
                    pendingContentOffsetX = newValue
                    return
                }

                if contentSize.width < (newValue + frame.width) {
                    pendingContentOffsetX = newValue
                    return
                }
                setContentOffsetX(newValue, animated: false)
            }
        }

        func setContentOffsetX(_ x: CGFloat, animated: Bool) {
            if isRightToLeftLayout {
                setContentOffset(CGPoint(x: contentSize.width - x - frame.width, y: 0), animated: animated)
            } else {
                setContentOffset(CGPoint(x: x, y: 0), animated: animated)
            }
        }

        func setContentOffsetXAfterContentSizeUpdate(_ x: CGFloat) {
            pendingContentOffsetX = x
            setNeedsLayout()
        }

        private func applyPendingContentOffsetXIfPossible() {
            guard let offsetX = pendingContentOffsetX,
                  frame.width > 0,
                  contentSize.width >= frame.width else {
                return
            }
            setContentOffsetX(offsetX, animated: false)
            pendingContentOffsetX = nil
        }

        private var isRightToLeftLayout: Bool {
            effectiveUserInterfaceLayoutDirection == .rightToLeft
        }
    }
}
