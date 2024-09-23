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
}

public extension PagingMenuControllerDelegate {
    func pagingMenuController(_ pagingMenuController: PagingMenuController, didAddBarItemView view: UIView, forIndex index: Int) { }
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
                scrollView.contentOffsetX = 0
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
                scrollView.contentOffsetX = view.frame.width * CGFloat(newValue)
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

    private var isLayoutFinished = false
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
        view.addSubview(scrollView)
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
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentWidth!
        ])
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isLayoutFinished {
            return
        }
        scrollView.contentOffsetX = view.frame.width * CGFloat(selectedIndex)
        isLayoutFinished = true
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
    
    private func showSelectedViewController(_ selectedIndex: Int) {
        
        let width = view.bounds.width

        guard let vcs = items?.1 else {
            return
        }
        
        if selectedIndex > 0 && width == 0 {
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
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let sv = scrollView as! PagingScrollView
        barView.setSelectedIndex(Int(sv.contentOffsetX/sv.bounds.width), animated: true)
        showSelectedViewController(barView.selectedIndex)
        delegate?.pagingMenuController(self, didSelectAt: barView.selectedIndex, actionBehavior: .scroll)

    }
    
    class PagingScrollView: UIScrollView {
        
        private var needUpdateContentOffsetX: CGFloat?
        override var contentSize: CGSize {
            didSet {
                if let offsetX = needUpdateContentOffsetX, contentSize.width > frame.width {
                    setContentOffsetX(offsetX, animated: false)
                    needUpdateContentOffsetX = nil
                }
            }
        }
        
        var contentOffsetX: CGFloat {
            get {
                if semanticContentAttribute == .forceRightToLeft {
                    return contentSize.width - contentOffset.x - frame.width
                }
                return contentOffset.x
            }
            set {
                needUpdateContentOffsetX = nil
                
                if contentSize.width == 0 {
                    needUpdateContentOffsetX = newValue
                    return
                }

                if semanticContentAttribute == .forceRightToLeft &&
                    contentSize.width < (newValue + frame.width) {
                    needUpdateContentOffsetX = newValue
                    return
                }
                setContentOffsetX(newValue, animated: false)
            }
        }

        func setContentOffsetX(_ x: CGFloat, animated: Bool) {
            if semanticContentAttribute == .forceRightToLeft {
                setContentOffset(CGPoint(x: contentSize.width - x - frame.width, y: 0), animated: animated)
            } else {
                setContentOffset(CGPoint(x: x, y: 0), animated: animated)
            }
        }
    }
}


