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
		let route = route.grouped("users")
		route.get(User.parameter, use: index)
		route.post(use: register)
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
	
}
