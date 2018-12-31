import Vapor
import FluentPostgreSQL

struct Part: PostgreSQLModel {
    var id: Int?
    var name: String
    var quantity: Int
    var statusID: Int
    var parentPartID: Int?
}

struct PartUpdate: Content {
    var name: String?
    var quantity: Int?
    var statusID: Int?
    var parentPartID: Int?
}

extension Part {
    var subparts: Children<Part, Part> {
        return children(\.parentPartID)
    }
}
