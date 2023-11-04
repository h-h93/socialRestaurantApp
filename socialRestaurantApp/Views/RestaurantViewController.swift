//
//  RestaurantViewController.swift
//  socialRestaurantApp
//
//  Created by hanif hussain on 03/11/2023.
//

import UIKit
import MapKit

class RestaurantViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MKLocalSearchCompleterDelegate {

    let mapView : MKMapView = {
        let map = MKMapView()
        map.overrideUserInterfaceStyle = .dark
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    let locationManager = CLLocationManager()
    let pointsOfinterestCategory = MKPointOfInterestFilter(including: [.restaurant, .bakery, .cafe,])

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        mapView.delegate = self
        
        // initalise location tracking and start updating so we can track user realtime location
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // triggers a one-time location request
        locationManager.requestLocation()
        // continously updates users location
        locationManager.startUpdatingLocation()
        
        // Show user's location on the map
        mapView.showsUserLocation = true
        
        // set constraints for mapview
        setMapConstraints()
        
        mapView.pointOfInterestFilter = pointsOfinterestCategory
        mapView.selectableMapFeatures = [.pointsOfInterest]
        
    }
    
    private func setMapConstraints() {
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
                locationManager.requestLocation()
            }
        }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                mapView.setRegion(region, animated: true)
            }
        }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Get the restaurant point of interest annotation.
           guard let restaurantAnnotation = view.annotation as? MKMapFeatureAnnotation else { return }

           // Create an MKMapItemRequest instance to get the restaurant details.
           let request = MKMapItemRequest(mapFeatureAnnotation: restaurantAnnotation)

           // Request the restaurant details.
           request.getMapItem { mapItem, error in
               guard error == nil else {
                   // Handle the error.
                   return
               }

               // Get the restaurant details from the map item.
               let restaurantName = mapItem?.placemark.name
               let restaurantAddress = mapItem?.placemark.location
               let restaurantPhoneNumber = mapItem?.phoneNumber
               let restaurantWebsite = mapItem?.url
               
               //mapItem?.openInMaps()

               // Display the restaurant details to the user.
           }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Check if the annotation is a restaurant point of interest.
        guard let restaurantAnnotation = annotation as? MKMapFeatureAnnotation else { return nil }

        // Create an annotation view for the restaurant point of interest.
        let annotationView = MKMarkerAnnotationView(annotation: restaurantAnnotation, reuseIdentifier: "RestaurantAnnotationView")

        // Customize the appearance of the annotation view.
        annotationView.markerTintColor = .red
        annotationView.glyphText = "🍴"

        return annotationView
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
