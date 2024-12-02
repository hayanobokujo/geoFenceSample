import UIKit
import MapKit
import CoreLocation
import AudioToolbox

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // チェックポイント
    let checkPointName: String = "里山を考える会"
    let checkPointLat: Double = 33.867879815618785
    let checkPointLng: Double = 130.80894498066073
    let checkPointRadius: Double = 50.0

    // 地図表示用のマップビュー
    private let mapView = MKMapView()
    
    // 現在地取得用のロケーションマネージャー
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIのセットアップ
        setupMapView()
        
        // 位置情報のセットアップ
        setupLocationManager()
        
        // サンプルのジオフェンス領域を設定
        setupGeofenceRegion()
    }
    
    private func setupMapView() {
        // マップビューを画面全体に配置
        mapView.frame = view.bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.showsUserLocation = true // 現在地の表示を有効化
        view.addSubview(mapView)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // ユーザーに位置情報の許可をリクエスト
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        // 現在位置の取得を開始
        locationManager.startUpdatingLocation()
    }
    
    private func setupGeofenceRegion() {
        // ジオフェンスの中心座標を設定
        let center = CLLocationCoordinate2D(latitude: checkPointLat, longitude: checkPointLng)
        let region = CLCircularRegion(
            center: center,
            radius: checkPointRadius, // 何メートル以内に入ったら通知するか
            identifier: checkPointName
        )
        region.notifyOnEntry = true  // 領域に入ったときに通知
        region.notifyOnExit = true  // 領域から出たときに通知
        
        // ジオフェンスの監視を開始
        locationManager.startMonitoring(for: region)
    }
    
    // 位置情報の更新時に呼ばれるデリゲートメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        // 現在地を中心にマップを移動
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: true)
    }
    
    // 領域に入った場合のデリゲートメソッド
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            playSystemSound() // システムサウンドを鳴らす
            triggerHapticFeedback(for: .success) // 成功の触覚フィードバック
            showAlert(title: "通知", message: "入ったよ")
        }
    }

    // 領域から出た場合のデリゲートメソッド
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            playSystemSound() // システムサウンドを鳴らす
            triggerHapticFeedback(for: .warning) // 警告の触覚フィードバック
            showAlert(title: "通知", message: "出たよ")
        }
    }

    // システムサウンドを再生するメソッド
    private func playSystemSound() {
        let soundID: SystemSoundID = 1007 // SNS受信音
        AudioServicesPlaySystemSound(soundID)
    }

    // 触覚フィードバックを発生させるメソッド
    private func triggerHapticFeedback(for feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(feedbackType)
    }

    // アラートを表示するメソッド
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // エラー処理
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗しました: \(error.localizedDescription)")
    }
}

