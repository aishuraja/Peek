import Foundation

struct Friend: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let initials: String
    let tint: String
}

struct Reaction: Identifiable, Hashable {
    let id = UUID()
    let friend: Friend
    var videoURL: URL?
}

struct Peek: Identifiable, Hashable {
    let id = UUID()
    let sender: Friend
    let imageName: String
    let caption: String?
    let createdAt: Date
    var isOpened: Bool
    var reactions: [Reaction]
}

enum DemoData {
    static let aish = Friend(name: "Aish", initials: "AI", tint: "FF7597")
    static let navya = Friend(name: "Navya", initials: "NA", tint: "8C7CFF")
    static let tarang = Friend(name: "Tarang", initials: "TA", tint: "48C9B0")
    static let wali = Friend(name: "Wali", initials: "WA", tint: "F4B860")
    static let kartik = Friend(name: "Kartik", initials: "KA", tint: "8C7CFF")
    static let aryan = Friend(name: "Aryan", initials: "AR", tint: "48C9B0")
    static let rhea = Friend(name: "Rhea", initials: "RH", tint: "F4B860")
    static let meera = Friend(name: "Meera", initials: "ME", tint: "70A1FF")

    static let incomingPeeks = [
        Peek(sender: aish, imageName: "dog", caption: "he has something important to say", createdAt: .now.addingTimeInterval(-120), isOpened: false, reactions: []),
        Peek(sender: navya, imageName: "coffee", caption: "tiny afternoon win ☕️", createdAt: .now.addingTimeInterval(-420), isOpened: false, reactions: []),
        Peek(sender: tarang, imageName: "cat", caption: "caught red-pawed", createdAt: .now.addingTimeInterval(-900), isOpened: false, reactions: []),
        Peek(sender: wali, imageName: "music", caption: "this one is going straight on repeat", createdAt: .now.addingTimeInterval(-1_500), isOpened: false, reactions: [])
    ]
    static let sent = Peek(sender: kartik, imageName: "travel", caption: "worth the 5am wake-up", createdAt: .now.addingTimeInterval(-5400), isOpened: true, reactions: [aish, kartik, aryan, rhea].map { Reaction(friend: $0, videoURL: nil) })
}
