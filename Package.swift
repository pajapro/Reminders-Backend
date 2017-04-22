import PackageDescription

let package = Package(
    name: "Reminders-Backend",
	dependencies: [
		.Package(url: "https://github.com/vapor/vapor.git", "1.5.15"),
		.Package(url: "https://github.com/vapor/postgresql-provider", majorVersion: 1, minor: 1),
		.Package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver-Vapor.git", majorVersion: 1),
	]
)
