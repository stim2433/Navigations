
import PackageDescription

let package = Package(
    name: "Navigations",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Navigations",
            targets: ["Navigations"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Navigations"),
        .testTarget(
            name: "NavigationsTests",
            dependencies: ["Navigations"]),
    ]
)
