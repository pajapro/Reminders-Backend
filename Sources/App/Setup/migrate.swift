//
//  migrate.swift
//  App
//
//  Created by Pavel Procházka on 03/02/2019.
//

import Vapor
import FluentPostgreSQL

public func migrate(migrations: inout MigrationConfig) throws {
	migrations.add(model: Task.self, database: .psql)
	migrations.add(model: List.self, database: .psql)
	migrations.add(model: User.self, database: .psql)
	migrations.add(model: Token.self, database: .psql)
}
