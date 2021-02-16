import Foundation
let json = """
{
    "from": "Guille",
    "text": "Look what I just found!",
    "attachments": [
        {
            "name": "Test1",
            "type": "image",
            "items": [
                "A", "B", "C"
            ],
            "payload": {
                "url": "url1",
                "width": 640,
                "height": 480
            }
        },
        {
            "name": "Test2",
            "type": "audio",
            "payload": {
                "title": "title1",
                "url": "url2",
                "shouldAutoplay": true,
            }
        },
        {
            "name": "Test3",
            "type": "audio",
            "payload": {
                "title": "title2",
                "url": "url3",
                "shouldAutoplay": true,
            }
        }
    ]
}
""".data(using: .utf8)!

struct ImageAttachment: Codable {
    let url: URL
    let width: Int
    let height: Int
}

struct AudioAttachment: Codable {
    let title: String
    let url: URL
    let shouldAutoplay: Bool
}

enum Attachment {
    case image(String,[String],ImageAttachment)
    case audio(String, AudioAttachment)
    case unsupported
}


extension Attachment: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case items
        case payload
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let name = try container.decode(String.self, forKey: .name)
        
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "image":
            let payload = try container.decode(ImageAttachment.self, forKey: .payload)
            let items = try container.decode([String].self, forKey: .items)
            self = .image(name,items,payload)
        case "audio":
            let payload = try container.decode(AudioAttachment.self, forKey: .payload)
            self = .audio(name, payload)
        default:
            self = .unsupported
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .image(let name,let items, let payload):
            try container.encode("image", forKey: .type)
            try container.encode(payload, forKey: .payload)
            try container.encode(name, forKey: .name)
            try container.encode(items, forKey: .items)
        case .audio(let name, let payload):
            try container.encode("audio", forKey: .type)
            try container.encode(payload, forKey: .payload)
            try container.encode(name, forKey: .name)
        case .unsupported:
            let context = EncodingError.Context(codingPath: [], debugDescription: "Invalid attachment.")
            throw EncodingError.invalidValue(self, context)
        }
    }
}

struct Message: Codable {
    let from: String
    let text: String
    let attachments: [Attachment]
}

let decoder = JSONDecoder()
let message = try decoder.decode(Message.self, from: json)
for attachment in message.attachments {
    switch attachment {
    case .image(let name,let items, let payload):
        print("image", name)
        print("image", items)
        print("image", payload)
    case .audio(let name, let payload):
        print("audio",name)
        print("audio", payload)
    case .unsupported:
        print("unsupported")
    }
}
