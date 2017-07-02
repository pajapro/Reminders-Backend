//
//  Request+Extensions.swift
//  Reminders-Backend
//
//  Created by Pavel Procházka on 25/06/2017.
//
//

import Vapor
import AuthProvider

extension Request {
	
	/// Returns the currently authenticated user, otherwise throws an error.
	func currentUser() throws -> User {
		return try auth.assertAuthenticated()
	}
}
