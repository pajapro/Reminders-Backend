//
//  middlewares.swift
//  App
//
//  Created by Pavel Procházka on 03/02/2019.
//

import Vapor

public func middlewares(config: inout MiddlewareConfig) throws {
	config.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
	
	// Other Middlewares...
}
