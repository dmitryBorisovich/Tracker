import UIKit

struct EmojiAndColor {
    static let shared = EmojiAndColor()
    
    let emojiArray = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    
    let colorsArray = [
        UIColor(named: "trackerRed"), UIColor(named: "trackerOrange"),
        UIColor(named: "trackerDarkBlue"), UIColor(named: "trackerDeepPurple"),
        UIColor(named: "trackerGreen"), UIColor(named: "trackerPink"),
        UIColor(named: "trackerLightPink"), UIColor(named: "trackerBlue"),
        UIColor(named: "trackerLightGreen"), UIColor(named: "trackerNavy"),
        UIColor(named: "trackerCarrot"), UIColor(named: "trackerLilac"),
        UIColor(named: "trackerSand"), UIColor(named: "trackerSapphire"),
        UIColor(named: "trackerViolet"), UIColor(named: "trackerPurple"),
        UIColor(named: "trackerIris"), UIColor(named: "trackerDarkGreen")
    ]
}
