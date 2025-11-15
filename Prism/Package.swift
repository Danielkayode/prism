// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Prism",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "Prism", targets: ["Prism"])
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.20.0"),
        .package(url: "https://github.com/stripe/stripe-ios.git", from: "23.0.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "7.0.0"),
        .package(url: "https://github.com/apple/sourcekit-lsp.git", branch: "main")
    ],
    targets: [
        .target(
            name: "Prism",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "StripeApplePay", package: "stripe-ios"),
                .product(name: "StripePaymentSheet", package: "stripe-ios"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "SourceKitLSP", package: "sourcekit-lsp")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "PrismTests",
            dependencies: ["Prism"],
            path: "Tests"
        )
    ]
)
