//
//  databases.swift
//  App
//
//  Created by Pavel Procházka on 03/02/2019.
//

import Vapor
import FluentPostgreSQL

public func databases(config: inout DatabasesConfig) throws {
	let psqlConfig: PostgreSQLDatabaseConfig
	if let url = Environment.get("DATABASE_URL"), let dbConfig = PostgreSQLDatabaseConfig(url: url) { // it will read from this URL in production
		psqlConfig = dbConfig
		print("Registered DB from DATABASE_URL")
	} else { // when environment variable not present, default to local development environment
		psqlConfig = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "vapor", database: "vapor", password: "password")
		print("Registered local DB")
	}
	
	let psqlDatabase = PostgreSQLDatabase(config: psqlConfig)
	
	// Register the configured PostgreSQL database to the database config
	config.add(database: psqlDatabase, as: .psql)
	
	config.enableLogging(on: .psql)
}
