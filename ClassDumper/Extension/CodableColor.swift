import SwiftUI

struct AccentColor: Identifiable {
    var id: String { name }
    var color: CodableColor
    var name: String
}

var accents: [AccentColor] = [
    .init(color: CodableColor(.blue), name: "Blue"),
    .init(color: CodableColor(.purple), name: "Purple"),
    .init(color: CodableColor(.pink), name: "Pink"),
    .init(color: CodableColor(.red), name: "Red"),
    .init(color: CodableColor(.orange), name: "Orange"),
    .init(color: CodableColor(.yellow), name: "Yellow"),
    .init(color: CodableColor(.green), name: "Green"),
    .init(color: CodableColor(.gray), name: "Gray"),
]

struct CodableColor: RawRepresentable, Codable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(_ color: Color) {
        let nsColor = NSColor(color).usingColorSpace(.deviceRGB)!
        let red = Int(nsColor.redComponent * 255)
        let green = Int(nsColor.greenComponent * 255)
        let blue = Int(nsColor.blueComponent * 255)
        let alpha = Int(nsColor.alphaComponent * 255)

        self.rawValue = String(format: "%02X%02X%02X%02X", red, green, blue, alpha)
    }

    func toColor() -> Color {
        let red = Double(Int(rawValue.prefix(2), radix: 16)!) / 255.0
        let green = Double(Int(rawValue.dropFirst(2).prefix(2), radix: 16)!) / 255.0
        let blue = Double(Int(rawValue.dropFirst(4).prefix(2), radix: 16)!) / 255.0
        let alpha = Double(Int(rawValue.dropFirst(6).prefix(2), radix: 16)!) / 255.0

        return Color(NSColor(calibratedRed: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha)))
    }
}
