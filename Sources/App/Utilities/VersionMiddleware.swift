//
//  VersionMiddleware.swift
//  Reminders-Backend
//
//  Created by Pavel Procházka on 05/03/2017.
//
//

import Vapor
import HTTP

final class VersionMiddleware: Middleware {
	func respond(to request: Request, chainingTo next: Responder) throws -> Response {
		
		// 1. We are not interested in modifying the *request*, hence immediately ask the next middleware in the chain to respond to the *request*
		// 2. Goes all the way down the chain to the `Droplet` and comes back with the *response* that should be sent to the client
		let response = try next.respond(to: request)
		
		// Modify the response to contain a Version header.
		response.headers["Version"] = "API v1.0"
		
		// Response is returned and will chain back up any remaining middleware and back to the client.
		return response
	}
}
