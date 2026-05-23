import Foundation

func parseTime(_ timeString: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    guard let base = formatter.date(from: timeString) else { return nil }
    let cal = Calendar.current
    let comps = cal.dateComponents([.hour, .minute], from: base)
    return cal.date(bySettingHour: comps.hour ?? 0, minute: comps.minute ?? 0, second: 0, of: Date())
}

func formatTime(_ timeString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    guard let date = formatter.date(from: timeString) else { return timeString }
    let display = DateFormatter()
    display.dateFormat = "h:mma"
    return display.string(from: date).lowercased().replacingOccurrences(of: ":00", with: "")
}
