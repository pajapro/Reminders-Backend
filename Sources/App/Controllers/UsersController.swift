//
//  UsersController.swift
//  App
//
//  Created by Pavel Procházka on 25/12/2018.
//

import Vapor
import FluentPostgreSQL
import Crypto

/// Controls basic CRUD operations on `User`s.
final class UsersController: RouteCollection {
	
	func boot(router route: Router) throws {
		let unprotected = route.grouped("users")
		
		let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
		let basicProtected = unprotected.grouped(basicAuthMiddleware)
		
		let tokenProtected = unprotected.grouped(User.tokenAuthMiddleware(), User.guardAuthMiddleware())

		unprotected.post(use: register)
		basicProtected.post("login", use: login)
		tokenProtected.post("logout", use: logout)
	}
	
	/// Registers a new user and returns generated access token
	func register(_ req: Request) throws -> Future<User.Outcoming> {
		return try req.content.decode(User.Registration.self).flatMap(to: User.Outcoming.self) { registrationUser in
			let passwordHashed = try req.make(BCryptDigest.self).hash(registrationUser.password)
			let newUser = User(name: registrationUser.name, email: registrationUser.email, password: passwordHashed)
			return newUser.save(on: req).flatMap(to: User.Outcoming.self) { createdUser in
				let accessToken = try Token.createToken(forUser: createdUser)
				return accessToken.save(on: req).map(to: User.Outcoming.self) { createdToken in
					let outcomingUser = User.Outcoming(email: newUser.email, token: createdToken.token)
					return outcomingUser
				}
			}
		}
	}
	
	/// Authenticates user with username & password and returns generated access token
	func login(_ req: Request) throws -> Future<User.Outcoming> {
		let user = try req.requireAuthenticated(User.self) // will automatically throw an appropriate unauthorized error if the valid credentials were not supplied
		let accessToken = try Token.createToken(forUser: user)
		return accessToken.save(on: req).map(to: User.Outcoming.self) { createdToken in
			let outcomingUser = User.Outcoming(email: user.email, token: createdToken.token)
			return outcomingUser
		}
	}
	
	/// Removes authenticated user's token from database
	func logout(_ req: Request) throws -> HTTPResponse {
		do {
			let user = try req.requireAuthenticated(User.self)
			_ = try user.authTokens.query(on: req).delete()
			return HTTPResponse(status: .ok)
		} catch _ {
			return HTTPResponse(status: .internalServerError)
		}
	}
}
