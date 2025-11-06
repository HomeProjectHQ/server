import FoundationModels

@Generable
struct FeaturedItemData: Codable {
    @Guide(description: "Type of media: Movie, TvEpisode, or TvShow")
    var type: String
    
    @Guide(description: "Database ID of the item")
    var itemId: Int
    
    @Guide(description: "Brief caption explaining why now (20-80 chars)")
    var caption: String
}

@Generable
struct FeaturedItems: Codable {
    @Guide(description: "Exactly 5 featured items")
    var items: [FeaturedItemData]
}

typealias SchemaType = FeaturedItems