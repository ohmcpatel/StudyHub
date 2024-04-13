import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    private var completion: ((CLLocationCoordinate2D?, Error?) -> Void)?
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization() // Request authorization
    }
    
    func getCurrentLocation(completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        self.completion = completion
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestLocation()
        } else {
            completion(nil, NSError(domain: "LocationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location services not enabled"]))
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            completion?(nil, NSError(domain: "LocationError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to get location"]))
            return
        }
        let coordinate = location.coordinate
        locationManager.stopUpdatingLocation()
        completion?(coordinate, nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(nil, error)
    }
}
