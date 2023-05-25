struct HackerNewsPost: Identifiable, Decodable {
    var id: Int
    var title: String
    var url: String?
}
