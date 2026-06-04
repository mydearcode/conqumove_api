// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "ConqumoveClient",
  platforms: [
    .iOS(.v15),
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "ConqumoveClient",
      targets: ["ConqumoveClient"]
    )
  ],
  targets: [
    .target(
      name: "ConqumoveClient",
      path: "Sources/ConqumoveClient"
    )
  ]
)
