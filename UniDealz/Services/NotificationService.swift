import Foundation
import Combine
import UserNotifications
import FirebaseMessaging

class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    @Published var isPermissionGranted = false

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }

    func requestPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                    DispatchQueue.main.async {
                        self.isPermissionGranted = granted
                    }
                }
            case .denied:
                DispatchQueue.main.async {
                    self.isPermissionGranted = false
                }
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async {
                    self.isPermissionGranted = true
                }
            @unknown default:
                break
            }
        }
    }

    // deal notifications

    // schedules a local notification for every deal that's active today and hasn't ended yet.
    // if notifications are turned off, any previously scheduled deal notifications are cancelled.
    func scheduleDealNotifications(deals: [Deal], enabled: Bool) {
        guard enabled else {
            // user toggled notifications off, remove all pending deal notifications
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                let ids = requests.filter { $0.identifier.hasPrefix("deal_") }.map { $0.identifier }
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
            }
            return
        }

        // query the live permission status rather than relying on a stored value,
        // since the user could have revoked permission in settings at any point.
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                return
            }

            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                // clear old deal notifications before rescheduling so we don't get duplicates
                let existing = requests.filter { $0.identifier.hasPrefix("deal_") }.map { $0.identifier }
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: existing)

                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "EEEE"
                let todayName = dayFormatter.string(from: Date())
                let now = Date()
                for deal in deals {
                    // only schedule if the deal runs today and hasn't already ended
                    guard deal.daysAvailable.contains(todayName),
                          let endDate = parseTime(deal.endTime),
                          endDate > now
                    else { continue }

                    let content = UNMutableNotificationContent()
                    content.title = deal.venueName.isEmpty ? "UniDealz" : deal.venueName
                    content.body  = "\(deal.title) until \(formatTime(deal.endTime)) today!"
                    content.sound = .default

                    // fire at the deal's start time if it hasn't started yet,
                    // otherwise fire in 3 seconds so the user gets an instant alert.
                    let fireDate: Date
                    if let startDate = parseTime(deal.startTime), startDate > now {
                        fireDate = startDate
                    } else {
                        fireDate = now.addingTimeInterval(3)
                    }

                    // UNCalendarNotificationTrigger fires at a specific time of day, not after a delay
                    // this is more reliable than a time interval for scheduling exact deal start times.
                    let components = Calendar.current.dateComponents([.hour, .minute, .second], from: fireDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(
                        identifier: "deal_\(deal.id ?? UUID().uuidString)",
                        content: content,
                        trigger: trigger
                    )
                    UNUserNotificationCenter.current().add(request) { _ in }
                }
            }
        }
    }

    // liked deal notification

    // fires a notification 5 seconds after a deal is liked so the user gets a reminder about it.
    func sendLikedNotification(deal: Deal) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            let content = UNMutableNotificationContent()
            content.title = "Deal saved!"
            content.body = "\(deal.title) at \(deal.venueName) ends \(formatTime(deal.endTime)) today."
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "liked_\(deal.id ?? UUID().uuidString)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { _ in }
        }
    }

    // fcm delegate

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
}
