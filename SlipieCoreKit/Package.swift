// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SlipieCoreKit",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .macOS(.v13)
    ],
    products: [
        .library(name: "SlipieCoreKit", targets: ["SlipieCoreKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "SlipieCoreKit",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ]
        ),
        .testTarget(
            name: "SlipieCoreKitTests",
            dependencies: ["SlipieCoreKit"]
        )
    ]
)
