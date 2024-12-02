import UIKit
import CoreLocation
import AudioToolbox
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var locationManager: CLLocationManager?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // ロケーションマネージャーの初期化
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()

        // 通知の許可をリクエスト
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("通知の許可エラー: \(error)")
            }
        }

        // アプリが位置情報イベントで起動された場合の処理
        if let _ = launchOptions?[.location] {
            print("アプリが位置情報イベントで起動されました")
        }

        return true
    }

    // 領域に入った場合の処理
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(for: region, eventType: "入ったよ")
        }
    }

    // 領域から出た場合の処理
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(for: region, eventType: "出たよ")
        }
    }

    // ジオフェンスイベントの処理
    private func handleEvent(for region: CLRegion, eventType: String) {
        print("領域 \(eventType): \(region.identifier)")

        // サウンドを鳴らす
        playSystemSound()

        // ローカル通知を送信
        sendNotification(title: "ジオフェンスイベント", message: "領域 \(eventType): \(region.identifier)")
    }

    // システムサウンドを再生するメソッド
    private func playSystemSound() {
        let soundID: SystemSoundID = 1007 // SNS受信音
        AudioServicesPlaySystemSound(soundID)
    }

    // ローカル通知を送信するメソッド
    private func sendNotification(title: String, message: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = message
        notificationContent.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notificationContent,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
