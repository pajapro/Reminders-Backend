[![Language Swift 4.2.1](https://img.shields.io/badge/Language-Swift%204.2.1-orange.svg)](https://swift.org) [![Vapor 3.1.1](https://img.shields.io/badge/Vapor-3.1.1-blue.svg)](http://vapor.codes/)

# 🔔 Reminders-Backend
The goal of this personal learning project is to develop simplified [Reminders app](https://support.apple.com/en-us/HT205890)  on web. The application is written in [Swift 4.2.1](https://swift.org/blog/swift-4-2-released/) and is based on [Vapor](https://vapor.codes/) Swift web framework.

> Use Reminders for projects, groceries, and anything else that you want to keep track of. You can set when and where you want to be reminded. 

[source](https://support.apple.com/en-us/HT205890)

## 📥 Installation
To run Reminders-Backend locally, you need to:

1. Install [Swift 4.2.1](https://swift.org/download/#releases) on your mac OS - I strongly encourage you to use [swiftenv](https://swiftenv.fuller.li/en/latest/) for Swift version management
2. Install [Docker](https://mihaelamj.github.io/Install%20Docker/) 
3. Download [PostgreSQL](https://mihaelamj.github.io/Install%20PostgreSQL%20in%20Docker/) image in Docker

After that, execute the following commands:

1. Execute `$ docker start postgres` to spin off PostgreSQL Docker image
2. Run `$ vapor xcode -y` to create Xcode project and open it
3. Hit `Commnad + R` in Xcode to start the server

## 🛠 Xcode project
This repo does not include an Xcode project. If you want to generate one locally, use `vapor xcode -y` command to generate a new Xcode project for a project.

## 🌍 See it live
The application is deployed on https://shielded-atoll-10365.herokuapp.com/. Use [`API.paw`](https://paw.cloud) file to interact with the REST API.
