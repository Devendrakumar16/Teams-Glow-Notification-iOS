import Foundation

let texts = ["Microsoft Teams, Adarsh Kumar, rytr"]

var expandedTexts: [String] = []
for text in texts {
    if text.contains(",") {
        let parts = text.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        expandedTexts.append(contentsOf: parts)
    } else {
        expandedTexts.append(text)
    }
}

let allText = expandedTexts.joined(separator: " ").lowercased()
let isTeams = allText.contains("microsoft teams") ||
              expandedTexts.contains(where: { $0 == "Microsoft Teams" || $0 == "Teams" })

let blocklist: Set<String> = [
    "microsoft teams", "teams",
    "notification", "notifications", "notification center",
    "close", "close button", "options", "actions", "action",
    "banner", "alert", "group", "window",
    "button", "image", "icon", "text", "static text",
    "scroll area", "scroll bar", "list", "cell", "row",
    "system dialogue", "system dialog", "dialogue", "dialog",
    "open", "dismiss", "reply", "mark as read",
    "show", "hide", "expand", "collapse",
]

let meaningfulTexts = expandedTexts.filter { text in
    let lower = text.lowercased().trimmingCharacters(in: .whitespaces)
    return !lower.isEmpty &&
           !blocklist.contains(lower) &&
           !lower.hasPrefix("notification ") &&
           !lower.hasPrefix("alert ") &&
           lower.count > 1
}

var senderName = "Unknown"
var messagePreview = ""

if meaningfulTexts.count >= 2 {
    senderName = meaningfulTexts[0]
    messagePreview = meaningfulTexts.dropFirst().joined(separator: " ")
}

print("isTeams:", isTeams)
print("senderName:", senderName)
print("messagePreview:", messagePreview)
