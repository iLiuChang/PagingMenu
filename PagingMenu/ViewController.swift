//
//  ViewController.swift
//  PagingMenu
//
//  Created by LC on 2023/9/15.
//

import UIKit

class ViewController: UIViewController, PagingMenuControllerDelegate {

    private struct Demo {
        let title: String
        let alignment: PagingBarView.Alignment
        let items: [PagingBarItemProvider]
        let colors: [UIColor]
    }

    private let demos: [Demo] = [
        Demo(
            title: "Leading",
            alignment: .leading,
            items: ["Hot", "Choiceness", "Entertainment", "Sports", "Technology", "Star", "Stock"],
            colors: [.systemRed, .systemYellow, .systemOrange, .systemBlue, .systemIndigo, .systemPink, .systemBrown]
        ),
        Demo(
            title: "Center",
            alignment: .center,
            items: ["News", "Video", "Live"],
            colors: [.systemTeal, .systemGreen, .systemIndigo]
        ),
        Demo(
            title: "Trailing",
            alignment: .trailing,
            items: ["Profile", "Collect", "History"],
            colors: [.systemPink, .systemPurple, .systemBrown]
        )
    ]

    private let directionButton = UIButton(type: .system)
    private let alignmentControl = UISegmentedControl(items: ["Leading", "Center", "Trailing"])
    private let titleLabel = UILabel()
    private let headerContainer = UIView()
    private let paging = PagingMenuController()
    private var selectedDemoIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupHeader()
        setupPagingMenu()
        applyCurrentDemo()
        updateLayoutDirection()
    }

    private func setupHeader() {
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center

        directionButton.setTitle("Switch to RTL", for: .normal)
        directionButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        directionButton.addTarget(self, action: #selector(toggleLayoutDirection), for: .touchUpInside)

        alignmentControl.selectedSegmentIndex = selectedDemoIndex
        alignmentControl.addTarget(self, action: #selector(changeDemo), for: .valueChanged)

        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerContainer)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        directionButton.translatesAutoresizingMaskIntoConstraints = false
        alignmentControl.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(titleLabel)
        headerContainer.addSubview(directionButton)
        headerContainer.addSubview(alignmentControl)

        NSLayoutConstraint.activate([
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 120),

            titleLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            directionButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            directionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            alignmentControl.topAnchor.constraint(equalTo: directionButton.bottomAnchor, constant: 14),
            alignmentControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            alignmentControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            alignmentControl.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor)
        ])
    }

    private func setupPagingMenu() {
        let selectView = UIView()
        let line = UIView()
        line.backgroundColor = .systemGreen
        line.layer.cornerRadius = 1.5
        selectView.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.bottomAnchor.constraint(equalTo: selectView.bottomAnchor, constant: -5),
            line.centerXAnchor.constraint(equalTo: selectView.centerXAnchor),
            line.widthAnchor.constraint(equalToConstant: 24),
            line.heightAnchor.constraint(equalToConstant: 3)
        ])

        paging.barItemSpacing = 24
        paging.barItemNormalStyle = PagingBarItemStyle(color: .secondaryLabel, font: .systemFont(ofSize: 14))
        paging.barItemSelectedStyle = PagingBarItemStyle(color: .label, font: .boldSystemFont(ofSize: 17))
        paging.barItemSelectedBackgroundView = selectView
        paging.delegate = self

        addChild(paging)
        paging.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(paging.view)
        paging.didMove(toParent: self)

        NSLayoutConstraint.activate([
            paging.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            paging.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            paging.view.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 10),
            paging.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func applyCurrentDemo() {
        let demo = demos[selectedDemoIndex]
        titleLabel.text = "\(demo.title) Layout Demo"
        paging.barAlignment = demo.alignment
        paging.items = (demo.items, demo.colors.enumerated().map { index, color in
            makePage(title: demo.items[index].normalAttributedTitle.string, color: color)
        })
    }

    private func makePage(title: String, color: UIColor) -> UIView {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 32)
        label.textColor = .white
        label.text = title
        label.backgroundColor = color
        return label
    }

    private func updateLayoutDirection() {
        let isRightToLeft = UIView.appearance().semanticContentAttribute == .forceRightToLeft
        directionButton.setTitle(isRightToLeft ? "Switch to LTR" : "Switch to RTL", for: .normal)
    }

    @objc private func toggleLayoutDirection() {
        var isRightToLeft = UIView.appearance().semanticContentAttribute == .forceRightToLeft
        isRightToLeft.toggle()
        updateLayoutDirection()
        let attribute: UISemanticContentAttribute = isRightToLeft ? .forceRightToLeft : .forceLeftToRight
        UIView.appearance().semanticContentAttribute = attribute
        SceneDelegate.shared?.window?.rootViewController = ViewController()
    }

    @objc private func changeDemo() {
        selectedDemoIndex = alignmentControl.selectedSegmentIndex
        applyCurrentDemo()
        updateLayoutDirection()
    }

    func pagingMenuController(_ pagingMenuController: PagingMenuController, didSelectAt index: Int, actionBehavior: PagingMenuController.ActionBehavior) {
        print("didSelectAt \(index) actionBehavior:\(actionBehavior)")
    }
}
