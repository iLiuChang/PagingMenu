# PagingMenu

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE) [![Platform](https://img.shields.io/badge/platform-iOS-blue.svg?style=flat)](https://developer.apple.com/ios/) [![Swift](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)](https://swift.org/) [![CocoaPods](https://img.shields.io/cocoapods/v/PagingMenu.svg)](https://cocoapods.org/pods/PagingMenu) [![CocoaPods Compatible](https://img.shields.io/cocoapods/p/PagingMenu.svg)](https://cocoapods.org/pods/PagingMenu) [![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](Package.swift) 

A lightweight paging menu controller for iOS. Place view controllers or views inside a horizontal scroll view, with a customizable top bar for switching pages.

## Features

- Horizontal paging with a top menu bar
- Supports `UIViewController` and `UIView` as page content
- Flexible bar items: `String`, `PagingBarItemTitle`, `PagingBarItemAttributedTitle`, or custom `PagingBarItemProvider`
- Custom selected indicator / background via `barItemSelectedBackgroundView`
- Bar alignment: leading or center
- Style APIs for normal / selected bar items
- Delegate callbacks for selection (tap / scroll)
- CocoaPods & Swift Package Manager

## Requirements

| | Version |
| --- | --- |
| iOS | 11.0+ (SPM) / 13.0+ (CocoaPods) |
| Swift | 5.0+ |
| Xcode | 12.0+ |

## Installation

### CocoaPods

```ruby
pod 'PagingMenu'
```

Then run:

```bash
pod install
```

### Swift Package Manager

In Xcode: **File → Add Packages…** and enter:

```
https://github.com/iLiuChang/PagingMenu.git
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/iLiuChang/PagingMenu.git", from: "2.0.0")
]
```

### Manual

1. Download the files in the `Sources` folder
2. Drag them into your Xcode project

## Usage

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    let pagingMenu = PagingMenuController()
    pagingMenu.barHeight = 44
    pagingMenu.barInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    pagingMenu.barItemNormalStyle = PagingBarItemStyle(
        color: .black.withAlphaComponent(0.5),
        font: UIFont.systemFont(ofSize: 16)
    )
    pagingMenu.barItemSelectedStyle = PagingBarItemStyle(
        color: .black,
        font: UIFont.systemFont(ofSize: 16)
    )
    pagingMenu.items = (
        ["Title1", "Title2", "Title3"],
        [UIViewController(), UIViewController(), UIViewController()]
    )

    // Also supports UIView:
    // pagingMenu.items = (["Title1", "Title2", "Title3"], [UIView(), UIView(), UIView()])

    // Mix UIView and UIViewController:
    // pagingMenu.items = (["Title1", "Title2", "Title3"], [UIView(), UIViewController(), UIView()])

    addChild(pagingMenu)
    view.addSubview(pagingMenu.view)
    pagingMenu.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        pagingMenu.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        pagingMenu.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        pagingMenu.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        pagingMenu.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    pagingMenu.didMove(toParent: self)
}
```

### Selected indicator

Use `barItemSelectedBackgroundView` to show a line (or any custom view) under the selected title:

```swift
let itemBg = UIView()
let line = UIView()
line.backgroundColor = .blue
line.layer.cornerRadius = 1.5
itemBg.addSubview(line)
line.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    line.bottomAnchor.constraint(equalTo: itemBg.bottomAnchor),
    line.centerXAnchor.constraint(equalTo: itemBg.centerXAnchor),
    line.widthAnchor.constraint(equalToConstant: 16),
    line.heightAnchor.constraint(equalToConstant: 3)
])
pagingMenu.barItemSelectedBackgroundView = itemBg
```

### Bar alignment

The top bar defaults to leading alignment. Center it with:

```swift
pagingMenu.barAlignment = .center
```

### Custom bar & container items

Bar items support `String`, `PagingBarItemAttributedTitle`, `PagingBarItemTitle`, or a custom `PagingBarItemProvider`.  
Containers support `UIViewController`, `UIView`, or a custom `PagingContainerItemProvider`.

```swift
public protocol PagingBarItemProvider {
    var normalAttributedTitle: NSAttributedString { get }
    var selectedAttributedTitle: NSAttributedString { get }
}

public protocol PagingContainerItemProvider {
    var pagingContainerItemView: UIView { get }
    func addToSuper(_ superView: UIView, pagingMenuController: PagingMenuController)
    func removeFromSuper(_ pagingMenuController: PagingMenuController)
}
```

### Delegate

```swift
pagingMenu.delegate = self

func pagingMenuController(
    _ pagingMenuController: PagingMenuController,
    didSelectAt index: Int,
    actionBehavior: PagingMenuController.ActionBehavior
) {
    // actionBehavior: .click or .scroll
}
```

## Example

Open `Demo/PagingMenu.xcodeproj` and run the demo target.

## License

PagingMenu is available under the MIT license. See the [LICENSE](LICENSE) file for details.
