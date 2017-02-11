import PackageDescription

let package = Package(
    name: "Reminders-Backend",
	dependencies: [
		.Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 3),
		.Package(url: "https://github.com/vapor/postgresql-provider", majorVersion: 1, minor: 1)
	]
)
