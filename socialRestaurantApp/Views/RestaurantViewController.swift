//
//  RestaurantViewController.swift
//  socialRestaurantApp
//
//  Created by hanif hussain on 03/11/2023.
//

import UIKit
import MapKit
import Firebase
import Contacts

class RestaurantViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MKLocalSearchCompleterDelegate {
    
    let firebaseDB = FirebaseDB()
    
    // is user visiting a restaurant?
    //var restaurantSelected = Bool()
    
    let mapView : MKMapView = {
        let map = MKMapView()
        map.overrideUserInterfaceStyle = .dark
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    // get details for current restaurant user is visiting
    var restaurant = Restaurants()
    
    let locationManager = CLLocationManager()
    let pointsOfinterestCategory = MKPointOfInterestFilter(including: [.restaurant, .bakery, .cafe,])
    
    let handle = Auth.auth().addStateDidChangeListener { auth, user in
        // ...
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.plus"), style: .plain, target: self, action: #selector(isUserLoggedIn))
        
        NotificationCenter.default.addObserver(self, selector: #selector(getCurrentRestaurantAttending), name: NSNotification.Name("com.get.restaurantDetails"), object: nil)
        
        firebaseDB.getRestaurant()
    
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
        
        //let userInfo = Auth.auth().currentUser
        //print(userInfo?.uid)
        //firebaseDB.uploadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    // get current restaurant our user is attending
    @objc func getCurrentRestaurantAttending() {
        if firebaseDB.restaurants.count > 0 {
            let firebaseRestaurantDate = firebaseDB.restaurants[0].attendingDate!
            // compare the date from our latest record in the database to current date and see if 12 hours have passed
            if let diff = Calendar.current.dateComponents([.hour], from: firebaseRestaurantDate, to: Date()).hour, diff > 12 {
                restaurant = Restaurants()
            } else {
                restaurant = firebaseDB.restaurants[0]
            }
        }
    }
    
    @objc func isUserLoggedIn() {
        if Auth.auth().currentUser != nil {
            // Show logout page
            logOut()
        } else {
            // Show login page
            login()
        }
    }
    
    @objc func login() {
        let loginVC = LoginRegisterViewController()
        let ac = UIAlertController(title: "Login or Register", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Login/ Register", style: .default, handler: { action in
            // display login view as formsheet or pagesheet to overlay view also set sheet presentation controller settings to display grabber on top of view and set view size to medium size
            loginVC.modalPresentationStyle = .pageSheet
            loginVC.modalTransitionStyle = .crossDissolve
            if let sheet = loginVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
            self.present(loginVC, animated: true)
        }))
        
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
        
        present(ac, animated: true)
        
    }
    
    @objc func logOut() {
        let ac = UIAlertController(title: "Sign out?", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Sign out?", style: .default, handler: { action in
            if self.firebaseDB.logOut() {
                self.restaurant = Restaurants()
            }
        }))
        
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
        
        present(ac, animated: true)
        
    }
    
    private func setMapConstraints() {
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Get the restaurant point of interest annotation and check if user signed in otherwise return
        guard let restaurantAnnotation = view.annotation as? MKMapFeatureAnnotation else { return }
        guard Auth.auth().currentUser != nil else { return }
        
        // Create an MKMapItemRequest instance to get the restaurant details.
        let request = MKMapItemRequest(mapFeatureAnnotation: restaurantAnnotation)
        var MapItem = MKMapItem()
        
        // Request the restaurant details.
        request.getMapItem { mapItem, error in
            guard error == nil else {
                // Handle the error.
                return
            }
            // store mapItem so we can use it
            MapItem = mapItem!
            // need to run alert controller in main thread for responsive ui
            DispatchQueue.main.async {
                if self.restaurant.restaurantName == nil {
                    let ac = UIAlertController(title: "Dining here?", message: nil, preferredStyle: .actionSheet)
                    ac.addAction(UIAlertAction(title: "I'll be dining at this restaurant", style: .default, handler: { action in
                        self.bookRestaurant(mapItem: MapItem)
                    }))
                    ac.addAction(UIAlertAction(title: "Open in Apple maps", style: .default, handler: { uiAction in
                        MapItem.openInMaps()
                    }))
                    
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self.present(ac, animated: true)
                    
                } else if self.restaurant.restaurantName == MapItem.placemark.name {
                    let ac = UIAlertController(title: "Currently booked this restaurant", message: "Modify booking?", preferredStyle: .actionSheet)
                    ac.addAction(UIAlertAction(title: "Delete active booking?", style: .default, handler: { action in
                        //self.bookRestaurant(request: request)
                    }))
                    ac.addAction(UIAlertAction(title: "Open in Apple maps", style: .default, handler: { _ in
                        MapItem.openInMaps()
                    }))
                    
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self.present(ac, animated: true)
                } else {
                    let ac = UIAlertController(title: "You have booked \(self.restaurant.restaurantName!)", message: "Would you like to change your booking or get directions?", preferredStyle: .actionSheet)
                    ac.addAction(UIAlertAction(title: "I'll be dining here instead", style: .default, handler: { action in
                        //self.bookRestaurant(request: request)
                    }))
                    ac.addAction(UIAlertAction(title: "Open in Apple maps", style: .default, handler: { _ in
                        MapItem.openInMaps()
                    }))
                    
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self.present(ac, animated: true)
                }
            }
        } 
    }
    
    func bookRestaurant(mapItem: MKMapItem) {
        
            //self.restaurantSelected = true
            // Get the restaurant details from the map item.
            let restaurantName = mapItem.placemark.name
            var restaurantAddress = String()
            //let address = "\(mapItem?.placemark.name) \(mapItem?.placemark.locality) \(mapItem?.placemark.postalCode)"
            let restaurantPhoneNumber = mapItem.phoneNumber
            let restaurantWebsite = mapItem.url
            
            // format mapItem?.placemark.location to local postal address
            CLGeocoder().reverseGeocodeLocation((mapItem.placemark.location)!, preferredLocale: nil) { (clPlacemark: [CLPlacemark]?, error: Error?) in
                guard let place = clPlacemark?.first else {
                    print("No placemark from Apple: \(String(describing: error))")
                    return
                }
                // initialise postal address formatter
                let postalAddressFormatter = CNPostalAddressFormatter()
                // set address formatter to mailing address layout
                postalAddressFormatter.style = .mailingAddress
                //let address = "\(place.name) \(place.locality) \(place.postalCode)"
                // configure place.address to be of postal address format so it is readabl to users
                if let postalAddress = place.postalAddress {
                    // convert to string and pass to our address var
                    restaurantAddress = postalAddressFormatter.string(from: postalAddress)
                }
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                formatter.dateStyle = .full
                formatter.timeZone = .autoupdatingCurrent
                let date = Date.now.formatted(date: .complete, time: .shortened)
                
                self.restaurant.email = Auth.auth().currentUser!.email!.uppercased()
                self.restaurant.attendingDate = formatter.date(from: date)
                self.restaurant.restaurantLocation = restaurantAddress
                self.restaurant.restaurantName = restaurantName
                self.firebaseDB.uploadRestaurant(restaurant: self.restaurant)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Check if the annotation is a restaurant point of interest.
        guard let restaurantAnnotation = annotation as? MKMapFeatureAnnotation else { return nil }
        
        // Create an annotation view for the restaurant point of interest.
        let annotationView = MKMarkerAnnotationView(annotation: restaurantAnnotation, reuseIdentifier: "RestaurantAnnotationView")
        
        // Customize the appearance of the annotation view.
        annotationView.markerTintColor = .orange
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

