/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import UIKit
import MapKit
import CoreLocation
protocol DidSelectLocationDelegate{
    func userWasSelectedLocation(location: CLLocation)
}

class IGMessageAttachmentCurrentLocationViewController: UIViewController , UIGestureRecognizerDelegate {
    
    @IBOutlet weak var bottomView: IGTappableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationNameLabel: UILabel!
    @IBOutlet weak var pinImageView: UIImageView!
    let locationManager = CLLocationManager()
    var centerAnnotation = MKPointAnnotation()
    var locationDelegate : DidSelectLocationDelegate?
    var currentLocation = CLLocation()
    override func viewDidLoad() {
        super.viewDidLoad()
        currentLocationNameLabel.text = "Locating..."
        self.locationManager.delegate = self
        self.mapView.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            currentLocation = locationManager.location!
            let userCoordinate = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            let camera = MKMapCamera(lookingAtCenter: userCoordinate, fromEyeCoordinate: userCoordinate, eyeAltitude: 400.0)
            self.mapView.setCamera(camera, animated: true)
            displayLocationInfo(location: currentLocation)
            pinImageView.backgroundColor = UIColor.clear
            pinImageView.isUserInteractionEnabled = false
        }
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addModalViewItems(leftItemText: nil, rightItemText: "Cancel", title: "Location")
        navigationItem.navigationController = self.navigationController as! IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction {
            self.dismiss(animated: true, completion: nil)
        }
        bottomView.addAction {
            self.dismiss(animated: true, completion: {
                self.locationDelegate?.userWasSelectedLocation(location: self.currentLocation)
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayLocationInfo(location:CLLocation) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            // Location name
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                print(locationName)
                self.currentLocationNameLabel.text = locationName as String
            }
            // Street address
            if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                print(street)
            }
            // City
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                print(city)
            }
            // Zip code
            if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                print(zip)
            }
            // Country
            if let country = placeMark.addressDictionary!["Country"] as? NSString {
                print(country)
                
            }
        })
    }
}
//MARK:- UIMapViewDelegate
extension IGMessageAttachmentCurrentLocationViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        currentLocation = location
        displayLocationInfo(location: location)
    }
}
extension IGMessageAttachmentCurrentLocationViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors : " + error.localizedDescription)
    }
}

