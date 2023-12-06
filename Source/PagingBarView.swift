//
//  PagingBarView.swift
//  PagingMenu
//
//  Created by LC on 2023/9/15.
//

import UIKit

public protocol PagingBarViewDelegate: AnyObject {
    func pagingBarView(_ pageMenu: PagingBarView, didSelectAt index: Int)
}

private let PagingMenuStartTag = 100

public class PagingBarView: UIView {

    public weak var delegate: PagingBarViewDelegate?
    /// spacing between items.
    public var spacing: CGFloat = 15
    public var normalStyle:PagingBarItemStyle?
    public var selectedStyle:PagingBarItemStyle?
    /// after setting, the frame is equal to the frame of the currently selected item.
    public var selectedBackgroundView: UIView? {
        didSet {
            selectedBackgroundView?.removeFromSuperview()
            if let bg = selectedBackgroundView {
                bg.translatesAutoresizingMaskIntoConstraints = false
                contentView.insertSubview(bg, at: 0)
            }
        }
    }

    public var contentCenter = false {
        didSet {
            if contentCenter {
                leftConstraint?.isActive = false
                centerConstraint?.isActive = true
                rightConstraint?.isActive = false
            } else {
                leftConstraint?.isActive = true
                centerConstraint?.isActive = false
                rightConstraint?.isActive = true
            }
        }
    }
    
    public var items: [PagingBarItemProvider]? {
        didSet {
            setupItemViews()
            scrollView.contentOffset = .zero
        }
    }
    
    public var selectedIndex: Int {
        if let button = selectedButton {
            return button.tag - PagingMenuStartTag
        }
        return 0
    }
    
    private var selectedButton: UIButton?
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var centerConstraint: NSLayoutConstraint?
    private var leftConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    public func setSelectedIndex(_ index: Int, animated: Bool) {
        guard let button = contentView.viewWithTag(index+PagingMenuStartTag) as? UIButton else {
            return
        }
        selectedButton(button: button)
        let visibleRect = CGRect(x: scrollView.contentOffset.x, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        if !CGRectContainsRect(visibleRect, button.frame) {
            var x = button.frame.maxX-visibleRect.width
            if x < 0 {
                x = button.frame.origin.x
            }
            scrollView.setContentOffset(CGPoint(x:x, y:0), animated: animated)
        }
    }
    
    public func updateItem(_ item: PagingBarItemProvider, at index: Int) {
        guard let button = contentView.viewWithTag(index+PagingMenuStartTag) as? UIButton else {
            return
        }
        self.items?[index] = item
        setButtonStyle(button: button, item: item)
    }

    private func setupViews() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.semanticContentAttribute = .forceLeftToRight
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: rightAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        leftConstraint = contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor)
        centerConstraint = contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        rightConstraint = contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor)

        NSLayoutConstraint.activate([
            leftConstraint!,
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

    }
    
    private func setupItemViews() {
        contentView.subviews.forEach{
            if $0 != selectedBackgroundView { 
                $0.removeFromSuperview()
            }
        }
        var lastButton: UIButton?
        items?.enumerated().forEach({ index, item in
            let button = UIButton()
            button.tag = PagingMenuStartTag+index
            setButtonStyle(button: button, item: item)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(selectAction(button:)), for: .touchUpInside)
            contentView.addSubview(button)
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: contentView.topAnchor),
                button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            if let last = lastButton {
                NSLayoutConstraint.activate([
                    button.leftAnchor.constraint(equalTo: last.rightAnchor, constant: spacing)
                ])
            } else {
                NSLayoutConstraint.activate([
                    button.leftAnchor.constraint(equalTo: contentView.leftAnchor)
                ])
            }
            lastButton = button
            if index == 0 {
                selectedButton(button: button)
            }
        })
        
        if let last = lastButton {
            NSLayoutConstraint.activate([
                last.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0)
            ])
        }
    }
    
    private func setButtonStyle(button: UIButton, item: PagingBarItemProvider) {
        if let normal = normalStyle {
            button.setAttributedTitle(NSAttributedString(string: item.normalAttributedTitle.string, attributes: [.font:normal.font,.foregroundColor:normal.color]), for: .normal)
        } else {
            button.setAttributedTitle(item.normalAttributedTitle, for: .normal)
        }
        if let selected = selectedStyle {
            button.setAttributedTitle(NSAttributedString(string: item.selectedAttributedTitle.string, attributes: [.font:selected.font,.foregroundColor:selected.color]), for: .selected)
        } else {
            button.setAttributedTitle(item.selectedAttributedTitle, for: .selected)
        }
    }
    
    @objc private func selectAction(button: UIButton) {
        if selectedButton(button: button) {
            delegate?.pagingBarView(self, didSelectAt: button.tag-PagingMenuStartTag)
        }
    }

    private var selectedBackgroundViewConstraints: [NSLayoutConstraint]?
    @discardableResult
    private func selectedButton(button: UIButton) -> Bool {
        if selectedButton === button {
            return false
        }
        selectedButton?.isSelected = false
        button.isSelected = true
        selectedButton = button
        if let bg = selectedBackgroundView {
            if let constraints = selectedBackgroundViewConstraints {
                contentView.removeConstraints(constraints)
            }
            selectedBackgroundViewConstraints = [
                bg.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                bg.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                bg.widthAnchor.constraint(equalTo: button.widthAnchor),
                bg.heightAnchor.constraint(equalTo: button.heightAnchor)
            ]
            NSLayoutConstraint.activate(selectedBackgroundViewConstraints!)
        }
        return true
    }

}
