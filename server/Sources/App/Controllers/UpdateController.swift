import Vapor
import Fluent

/// Provides updates via REST long-polling.
final class UpdateController {
    func handle(_ req: Request) throws -> EventStream {
        let updates = try req.make(UpdateService.self)
        return updates.stream(on: req)
    }
}
