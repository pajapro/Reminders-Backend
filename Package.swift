import PackageDescription

let package = Package(
    name: "Reminders-Backend",
	dependencies: [
		.Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
		.Package(url: "https://github.com/vapor/auth-provider.git", majorVersion: 1),
		.Package(url: "https://github.com/vapor/fluent-provider.git", majorVersion: 1),
		.Package(url: "https://github.com/vapor/validation-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/leaf-provider.git", majorVersion: 1),
		.Package(url: "https://github.com/vapor-community/postgresql-provider", majorVersion: 2),
		.Package(url: "https://github.com/vapor-community/swiftybeaver-provider", majorVersion: 1),
	]
)
