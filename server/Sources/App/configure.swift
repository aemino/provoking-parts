import Vapor
import FluentPostgreSQL

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(PostgreSQLProvider())

    // Configure a Postgres database
    let postgresConfig = PostgreSQLDatabaseConfig(
        url: Environment.get("DATABASE_URL") ??
            "postgres://parts:parts@127.0.0.1:5432/parts"
    )!

    let postgres = PostgreSQLDatabase(config: postgresConfig)

    // Register the configured Postgres database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: postgres, as: .psql)
    services.register(databases)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create empty middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self) // Enables client-side sessions support
    services.register(middlewares)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Part.self, database: .psql)
    migrations.prepareCache(for: .psql)
    services.register(migrations)

    // services.register(KeyedCache.self) { container in
    //     try container.keyedCache(for: .psql)
    // }

    // config.prefer(
    //     DatabaseKeyedCache<ConfiguredDatabase<PostgreSQLDatabase>>.self,
    //     for: KeyedCache.self)
    
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register our update service
    let updates = UpdateService()
    services.register(updates)
}
