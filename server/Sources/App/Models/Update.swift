import Vapor
import FluentPostgreSQL

struct Update<UpdateModel: AnyModel>: Content {
    var timestamp: Date
    var model: String

    var user: GoogleProfile

    var old: UpdateModel?
    var new: UpdateModel?
}
