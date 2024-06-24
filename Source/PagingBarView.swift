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

    public enum Alignment {
        case leading
        case center
    }
    public weak var delegate: PagingBarViewDelegate?
    /// spacing between items.
    public var spacing: CGFloat = 15
    public var itemWidth: CGFloat = 0
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

    public var alignment = Alignment.leading {
        didSet {
            switch alignment {
            case .leading:
                leftConstraint?.isActive = true
                centerConstraint?.isActive = false
                rightConstraint?.isActive = true
                minWidthConstraint?.isActive = true
            default:
                leftConstraint?.isActive = false
                centerConstraint?.isActive = true
                rightConstraint?.isActive = false
                minWidthConstraint?.isActive = false
            }
        }
    }
    
    public var items: [PagingBarItemProvider]? {
        didSet {
            if resetItemsIfNeeded {
                setupItemViews()
            }
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
    private let contentView = ContentView()
    private var centerConstraint: NSLayoutConstraint?
    private var leftConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    private var minWidthConstraint: NSLayoutConstraint?
    private var resetItemsIfNeeded = true
    
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
        if alignment == .center {
            return
        }
        let visibleRect = CGRect(x: scrollView.contentOffset.x, y: 0, width: frame.width, height: frame.height)
        if !CGRectContainsRect(visibleRect, button.frame) {
            var x = button.frame.maxX-visibleRect.width
            if x < 0 {
                x = button.frame.origin.x
            }
            scrollView.setContentOffset(CGPoint(x:x, y:0), animated: animated)
        }
    }
    
    public func updateItem(_ item: PagingBarItemProvider, at index: Int) {
        guard let button = contentView.viewWithTag(index+PagingMenuStartTag) as? ItemButton else {
            return
        }
        resetItemsIfNeeded = false
        self.items?[index] = item
        resetItemsIfNeeded = true
        setButtonStyle(button: button, item: item)
    }

    public func reloadStyle() {
        items?.enumerated().forEach({ index, item in
            if let button = contentView.viewWithTag(index+PagingMenuStartTag) as? ItemButton {
                setButtonStyle(button: button, item: item)
            }
        })
    }
    
    private func setupViews() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
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
        contentView.scrollView = scrollView
        
        leftConstraint = contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor)
        centerConstraint = contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        rightConstraint = contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor)
        minWidthConstraint = contentView.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, multiplier: 1)
        NSLayoutConstraint.activate([
            leftConstraint!,
            rightConstraint!,
            minWidthConstraint!,
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
        contentView.needUpdateStartOffsetX = alignment == .leading

        var lastButton: ItemButton?
        items?.enumerated().forEach({ index, item in
            let button = ItemButton()
            button.tag = PagingMenuStartTag+index
            setButtonStyle(button: button, item: item)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(selectAction(button:)), for: .touchUpInside)
            contentView.addSubview(button)
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: contentView.topAnchor),
                button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            if itemWidth > 0 {
                NSLayoutConstraint.activate([
                    button.widthAnchor.constraint(equalToConstant: itemWidth)
                ])
            }
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
            let leading = last.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            leading.priority = .init(1)
            NSLayoutConstraint.activate([
                leading
            ])
        }
    }
    
    private func setButtonStyle(button: ItemButton, item: PagingBarItemProvider) {
        let normalAttributedTitle = item.normalAttributedTitle

        if let normal = normalStyle {
            if normalAttributedTitle is OnlyStringAttributedTitle {
                button.setAttributedTitle(NSAttributedString(string: normalAttributedTitle.string, attributes: [.font:normal.font,.foregroundColor:normal.color]), for: .normal)
            } else {
                button.setAttributedTitle(normalAttributedTitle, for: .normal)
            }

            if let image = normal.backgroundImage {
                button.setBackgroundImage(image, for: .normal)
            }
            if let insets = normal.contentEdgeInsets {
                button.setContentEdgeInset(insets, for: .normal)
            }
            if let radius = normal.cornerRadius {
                button.setCornerRadius(radius, for: .normal)
            }

        } else {
            button.setAttributedTitle(normalAttributedTitle, for: .normal)
        }
        
        let selectedAttributedTitle = item.selectedAttributedTitle
        if let selected = selectedStyle {
            if selectedAttributedTitle is OnlyStringAttributedTitle {
                button.setAttributedTitle(NSAttributedString(string: selectedAttributedTitle.string, attributes: [.font:selected.font,.foregroundColor:selected.color]), for: .selected)
            } else {
                button.setAttributedTitle(selectedAttributedTitle, for: .selected)
            }
            
            if let image = selected.backgroundImage {
                button.setBackgroundImage(image, for: .selected)
            }
            if let insets = selected.contentEdgeInsets {
                button.setContentEdgeInset(insets, for: .selected)
            }
            if let radius = selected.cornerRadius {
                button.setCornerRadius(radius, for: .selected)
            }
        } else {
            button.setAttributedTitle(selectedAttributedTitle, for: .selected)
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

    class ItemButton: UIButton {
        
        var _contentEdgeInsets = [UIControl.State.RawValue:UIEdgeInsets]()
        func setContentEdgeInset(_ insets: UIEdgeInsets, for state: UIControl.State) {
            _contentEdgeInsets[state.rawValue] = insets
            updateContentEdgeInsets()
        }

        var _cornerRadius = [UIControl.State.RawValue:CGFloat]()
        func setCornerRadius(_ radius: CGFloat, for state: UIControl.State) {
            _cornerRadius[state.rawValue] = radius
            updateCornerRadius()
        }

        override var isSelected: Bool {
            didSet {
                updateContentEdgeInsets()
                updateCornerRadius()
            }
        }
        
        func updateContentEdgeInsets() {
            let value = isSelected ? UIControl.State.selected.rawValue : UIControl.State.normal.rawValue
            if let inset = _contentEdgeInsets[value], inset != contentEdgeInsets {
                contentEdgeInsets = inset
            }
        }
        
        func updateCornerRadius() {
            let value = isSelected ? UIControl.State.selected.rawValue : UIControl.State.normal.rawValue
            if let radius = _cornerRadius[value],
               radius != layer.cornerRadius {
                layer.masksToBounds = true
                layer.cornerRadius = radius
            }
        }

    }
    
    class ContentView: UIView {
        weak var scrollView: UIScrollView?
        var needUpdateStartOffsetX = false
        override func layoutSubviews() {
            super.layoutSubviews()

            guard let scrollView = self.scrollView else {
                return
            }
            if needUpdateStartOffsetX && 
                frame.width > scrollView.frame.width &&
                scrollView.semanticContentAttribute == .forceRightToLeft {
                scrollView.contentOffset = CGPoint(x: frame.width-scrollView.frame.width, y: 0)
                needUpdateStartOffsetX = false
            }
        }
    }
}
