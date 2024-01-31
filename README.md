# PagingMenu
A paging menu controller built from other view controllers placed inside a scroll view

## Requirements

- **iOS 10.0+**
- **Swift 5.0+**

## Usage

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    let pagingMenu = PagingMenuController()
    pagingMenu.barHeight = 44
    pagingMenu.barInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    pagingMenu.barItemNormalStyle = PagingBarItemStyle(color: .black.withAlphaComponent(0.5), font: UIFont.systemFont(ofSize: 16))
    pagingMenu.barItemSelectedStyle = PagingBarItemStyle(color: .black, font: UIFont.systemFont(ofSize: 16))
    pagingMenu.items = (["Title1", "Title2", "Title3"], [UIViewController(), UIViewController(),UIViewController()])
    
    // items can also be UIView
    // pagingMenu.items = (["Title1", "Title2", "Title3"], [UIView(), UIView(),UIView()])

    // items can also be UIView and UIViewController
    // pagingMenu.items = (["Title1", "Title2", "Title3"], [UIView(), UIViewController(),UIView()])

    addChild(pagingMenu)
    view.addSubview(pagingMenu.view)
    pagingMenu.view.snp.makeConstraints { make in
        make.left.equalTo(0)
        make.width.equalTo(view)
        make.top.equalTo(20)
        make.bottom.equalTo(0)
    }
}
```


If you want to add a line under the selected title, you can set `barItemSelectedBackgroundView`. Of course, you can also set the background you want through `barItemSelectedBackgroundView`.
```swift
let itemBg = UIView()
let line = UIView()
line.backgroundColor = .blue
line.layer.cornerRadius = 1.5
itemBg.addSubview(line)
line.snp.makeConstraints { make in
    make.bottom.equalTo(0)
    make.centerX.equalToSuperview()
    make.size.equalTo(CGSize(width: 16, height: 3))
}
pagingMenu.barItemSelectedBackgroundView = itemBg
```


The content of the top bar is on the left by default. If you want to display it in the center, you can set `barAlignment` to `center`.
```swift
pagingMenu.barAlignment = .center
```


The top bar item supports `String`, `PagingBarItemAttributedTitle`, `PagingBarItemTitle`, and you can also customize it through `PagingBarItemProvider`.
The container supports `UIViewController`, `UIView`, and you can also customize it through `PagingContainerItemProvider`.
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


## Installation

### CocoaPods

To integrate PagingMenu into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'PagingMenu'
```

### Manual

1. Download everything in the `Source` folder;
2. Add (drag and drop) the source files in `Source` to your project.

## License

PagingMenu is provided under the MIT license. See LICENSE file for details.
