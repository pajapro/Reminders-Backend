import PackageDescription

let package = Package(
    name: "TODO-Backend",
	dependencies: [
		.Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 3),
		.Package(url: "https://github.com/pajapro/TODO-Foundation.git", majorVersion: 1, minor: 0)
	]
)
