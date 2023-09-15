//
//  PagingMenuView.swift
//  PagingMenu
//
//  Created by LC on 2023/9/15.
//

import UIKit

public protocol PagingMenuViewDelegate: AnyObject {
    func pagingMenuView(_ pageMenu: PagingMenuView, didSelectAt index: Int)
}

private let PagingMenuStartTag = 100

public class PagingMenuView: UIView {

    public weak var delegate: PagingMenuViewDelegate?
    public var spacing: CGFloat = 0
    public var normalStyle:PagingItemStyle?
    public var selectedStyle:PagingItemStyle?
    public var isAlignCenter = false {
        didSet {
            if isAlignCenter {
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
    
    public var items: [PagingItemProvider]? {
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
    
    public func updateItem(_ item: PagingItemProvider, at index: Int) {
        guard let button = contentView.viewWithTag(index+PagingMenuStartTag) as? UIButton else {
            return
        }
        self.items?[index] = item
        setButtonStyle(button: button, item: item)
    }

    private func setupViews() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        leftConstraint = contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        centerConstraint = contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        rightConstraint = contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)

        NSLayoutConstraint.activate([
            leftConstraint!,
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

    }
    
    private func setupItemViews() {
        contentView.subviews.forEach{ $0.removeFromSuperview() }
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
                    button.leadingAnchor.constraint(equalTo: last.trailingAnchor, constant: spacing)
                ])
            } else {
                NSLayoutConstraint.activate([
                    button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
                ])
            }
            lastButton = button
            if index == 0 {
                selectedButton(button: button)
            }
        })
        
        if let last = lastButton {
            NSLayoutConstraint.activate([
                last.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0)
            ])
        }
    }
    
    private func setButtonStyle(button: UIButton, item: PagingItemProvider) {
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
            delegate?.pagingMenuView(self, didSelectAt: button.tag-PagingMenuStartTag)
        }
    }

    @discardableResult
    private func selectedButton(button: UIButton) -> Bool {
        if selectedButton === button {
            return false
        }
        selectedButton?.isSelected = false
        button.isSelected = true
        selectedButton = button
        return true
    }

}
