[![Language Swift 3.0](https://img.shields.io/badge/Language-Swift%203.0-orange.svg)](https://swift.org) [![Vapor 1.5](https://img.shields.io/badge/Vapor-1.5-blue.svg)](http://vapor.codes/)

# 🔔 Reminders-Backend
The goal of this personal learning project is to develop simplified [Reminders app](https://support.apple.com/en-us/HT205890)  on web. The application is written in [Swift 3.0](https://swift.org/blog/swift-3-0-released/) and is based on [Vapor](https://vapor.codes/) Swift web framework.

> Use Reminders for projects, groceries, and anything else that you want to keep track of. You can set when and where you want to be reminded. 

[source](https://support.apple.com/en-us/HT205890)

## 📥 Installation
To run Reminders-Backend locally, you need to install [Swift 3](https://vapor.github.io/documentation/getting-started/install-swift-3-macos.html) on your mac OS. Moreover, you need to install [PostgreSQL](https://www.postgresql.org/download/macosx/) and [configure connection](https://github.com/vapor/postgresql-provider#config). 

After that, execute the following commands:

1. Execute `$ postgres -D /usr/local/var/postgres/` to start PostgreSQL service
2. Run `$ swift build` to compile
3. Run `$ .build/debug/Reminders-Backend` to start the server

## 🛠 Xcode project
This repo does not include an Xcode project. If you want to generate one locally, use `swift package generate-xcodeproj` command or simply `vapor xcode` to generate a new Xcode project for a project.

## 🌍 See it live
The application is deployed on https://pajapro-reminders-application.herokuapp.com
