//
//  UtilityController.swift
//  App
//
//  Created by Prochazka, Pavel on 10/10/2018.
//

import Vapor
import FluentPostgreSQL

fileprivate struct PostgreSQLVersion: Codable {
    let version: String
}

final class UtilityController {
    
    /// Retrieve the database version
    func databaseVersion(_ req: Request) throws -> Future<String> {
        return req.withPooledConnection(to: .psql) { conn in
            return conn.raw("SELECT version()")
                .all(decoding: PostgreSQLVersion.self)
        }.map { rows in
            return rows[0].version
        }
    }
    
    /// Retrieve the OS application is running in
    func os(_ req: Request) throws -> HTTPResponse {
        #if os(Linux)
            return HTTPResponse(status: .ok, body: "Linux")
        #elseif os(OSX)
            return HTTPResponse(status: .ok, body: "macOS")
        #else
            return HTTPResponse(status: .ok, body: "...other OS")
        #endif
    }
}
