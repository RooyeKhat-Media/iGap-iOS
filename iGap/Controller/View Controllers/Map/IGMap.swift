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
import RealmSwift
import IGProtoBuff


class IGMap: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnCurrentLocation: UIButton!
    
    var tileRenderer: MKTileOverlayRenderer!
    var currentLocation: CLLocation!
    let locationManager = CLLocationManager()
    
    var showMarker = true
    var room: IGRoom!
    let MIN_ZOOM_LEVEL = 16.5
    let MAX_ZOOM_LEVEL = 18.0
    var span: MKCoordinateSpan!
    var latestSpan: MKCoordinateSpan!
    
    @IBAction func btnCurrentLocation(_ sender: UIButton) {
        setCurrentLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonViewCustomize(button: btnCurrentLocation, color: UIColor.white)

        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "Users", title: "Nearby")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction {
            // TODO - show nearby coordinate list
        }
        
        setupTileRenderer()
        
        let status  = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if status == .denied || status == .restricted {
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)

            present(alert, animated: true, completion: nil)
            return
        }
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
       
        let initialRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.689197, longitude: 51.388974), span: MKCoordinateSpan(latitudeDelta: 0.16405544070813249, longitudeDelta: 0.1232528799585566))
        mapView.region = initialRegion
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.delegate = self
    }
    
    private func buttonViewCustomize(button: UIButton, color: UIColor){
        button.backgroundColor = color
        
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowRadius = 0.1
        button.layer.shadowOpacity = 0.1
        
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.masksToBounds = false
        button.layer.cornerRadius = button.frame.width / 2
    }
    

    func addMarker(){
        if !showMarker {
            return
        }
        showMarker = false
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = currentLocation.coordinate
        annotation.title = "iGap Map"
        annotation.subtitle = "iGap map user simple description. \n iGap map user simple description"
        mapView.addAnnotation(annotation)
        setCurrentLocation()
        latestSpan = span
    }
    
    func setCurrentLocation(){
        span = MKCoordinateSpanMake(0, 360 / pow(2, Double(16)) * Double(mapView.frame.size.width) / 256)
        let region = MKCoordinateRegionMake(currentLocation.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    func setupTileRenderer() {
        let template = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
        let overlay = MKHipsterTileOverlay(urlTemplate: template)
        overlay.canReplaceMapContent = true
        mapView.add(overlay, level: .aboveLabels)
        tileRenderer = MKTileOverlayRenderer(tileOverlay: overlay)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}

    func openChat(){
        let realm = try! Realm()
        let predicate = NSPredicate(format: "chatRoom.peer.id = %lld", 10) // userId
        if let roomInfo = try! realm.objects(IGRoom.self).filter(predicate).first {
            room = roomInfo
            performSegue(withIdentifier: "showRoomMessages", sender: self)
        } else {
            IGChatGetRoomRequest.Generator.generate(peerId: 10).success({ (protoResponse) in
                DispatchQueue.main.async {
                    if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse {
                        IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                        self.room = IGRoom(igpRoom: chatGetRoomResponse.igpRoom)
                        self.performSegue(withIdentifier: "showRoomMessages", sender: self)
                    }
                }
            }).error({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                default:
                    break
                }
                
            }).send()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last!
        print("Current location: \(currentLocation)")
        self.currentLocation = currentLocation
        addMarker()
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }

}

// MARK: - MapView Delegate
extension IGMap: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        } else {
            if annotation is MKUserLocation {
                return nil
            }
            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.pinTintColor = UIColor.orange
            pinView?.canShowCallout = true
            let smallSquare = CGSize(width: 30, height: 30)
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 0,y :0), size: smallSquare))
            button.setBackgroundImage(UIImage(named: "IG_Settings_Chats"), for: .normal)
            button.addTarget(self, action: #selector(IGMap.openChat), for: .touchUpInside)
            pinView?.leftCalloutAccessoryView = button
            
            let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            label1.text = "iGap map user simple description.\niGap map user simple description"
            label1.numberOfLines = 0
            pinView?.detailCalloutAccessoryView = label1;
            
            let width = NSLayoutConstraint(item: label1, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.lessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 200)
            label1.addConstraint(width)
            
            let height = NSLayoutConstraint(item: label1, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 90)
            label1.addConstraint(height)
            
            return pinView
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let coordinate = CLLocationCoordinate2DMake(mapView.region.center.latitude, mapView.region.center.longitude)
        let zoomLevel = getZoomLevel()
        
        if MIN_ZOOM_LEVEL > zoomLevel || MAX_ZOOM_LEVEL < zoomLevel {
            let region = MKCoordinateRegionMake(coordinate, self.latestSpan)
            mapView.setRegion(region, animated:true)
        } else {
            self.latestSpan = MKCoordinateSpanMake(0, 360 / pow(2, Double(zoomLevel-1)) * Double(mapView.frame.size.width) / 256)
        }
    }
    
    func getZoomLevel() -> Double {
        var angleCamera = mapView.camera.heading
        if angleCamera > 270 {
            angleCamera = 360 - angleCamera
        } else if angleCamera > 90 {
            angleCamera = fabs(angleCamera - 180)
        }
        let angleRad = M_PI * angleCamera / 180
        let width = Double(mapView.frame.size.width)
        let height = Double(mapView.frame.size.height)
        let heightOffset : Double = 20 // the offset (status bar height) which is taken by MapKit into consideration to calculate visible area height
        // calculating Longitude span corresponding to normal (non-rotated) width
        let spanStraight = width * mapView.region.span.longitudeDelta / (width * cos(angleRad) + (height - heightOffset) * sin(angleRad))
        return log2(360 * ((width / 256) / spanStraight)) + 1
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return tileRenderer
    }
}


