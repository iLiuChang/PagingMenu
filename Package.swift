// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "PagingMenu",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "PagingMenu", targets: ["PagingMenu"])
    ],
    targets: [
        .target(
            name: "PagingMenu",
            path: "Sources",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        )
    ]
)
