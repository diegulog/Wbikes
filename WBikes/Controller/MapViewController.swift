//
//  ViewController.swift
//  WBikes
//
//  Created by Diego on 14/10/2020.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var bottomSheetView = BottomSheetView()
    fileprivate let locationManager = CLLocationManager()
    var city: City!
    var bikeMode = true
    var selectedAnnotation: StationAnnotation?
    let height: CGFloat = 230
    let screenSize : CGSize = UIScreen.main.bounds.size
    lazy var tabBarSize : CGFloat = tabBarController?.tabBar.frame.size.height ?? 0
    var dataController: DataController!
    
    lazy var loadingIndicator: UIBarButtonItem = {
        let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        return UIBarButtonItem(customView: loadingIndicator)
    }()
    lazy var updateBarButtom: UIBarButtonItem = {
        let barButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh, target: self, action: #selector(updateData))
        barButton.style = .done
        barButton.tintColor = .white
        return barButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBarController = self.tabBarController as! TabBarViewController
        dataController = tabBarController.dataController
        city = tabBarController.city
        fetchedResults()
        checkSelectCity()
        addBottomSheetView()
    }
    override func viewWillAppear(_ animated: Bool) {
        print("MapViewController viewWillAppear")
        updateData()
    }
    
    fileprivate func fetchedResults() {
        let fetchRequest:NSFetchRequest<Station> = Station.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "city == %@", city)
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            updateMap(stations: result)
        }
    }
    
    @objc fileprivate func updateData(){
        print("update data")
        updateUI(true)
        Cliente.getStations(city: city, dataController: dataController) { (stations, error) in
            self.updateUI(false)
            if error != nil {
                if self.viewIfLoaded?.window != nil {
                    self.alertNetworkFailure(){
                        self.updateData()
                    }
                }
                return
            }
            self.updateMap(stations: stations)
        }
    }
    
    fileprivate func updateMap(stations: [Station]){
        
        if let selectedAnnotation = self.selectedAnnotation {
            if let selectedStation = stations.first(where: { $0.id == selectedAnnotation.station.id }) {
                self.bottomSheetView.updateData(station: selectedStation)
            }
        }
        var annotations = [MKAnnotation]()
        for station in stations {
            let coordinate = CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude)
            let annotation = StationAnnotation(coordinate: coordinate, station: station)
            annotations.append(annotation)
        }
        self.mapView?.removeAnnotations(mapView.annotations)
        self.mapView?.addAnnotations(annotations)
    }
    
    
    fileprivate func updateUI(_ update: Bool){
        self.navigationItem.setRightBarButton(update ? loadingIndicator : updateBarButtom , animated: true)
    }
    
    func addBottomSheetView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(tapGesture)
        
        bottomSheetView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: height)
        bottomSheetView.setRoundCorners(radius: 16)
        bottomSheetView.buttonDirectionsAction = {
            guard let anotation = self.selectedAnnotation else {
                return
            }
            let placemark = MKPlacemark(coordinate: anotation.coordinate, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "\(anotation.station.name ?? anotation.station.address ?? "")"
            mapItem.openInMaps(launchOptions: nil)
        }
        bottomSheetView.buttonFavoriteAction = {
            let fetchRequest:NSFetchRequest<Station> = Station.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.predicate = NSPredicate(format: "id == %@", self.bottomSheetView.id!)
            if let result = try? self.dataController.viewContext.fetch(fetchRequest).first {
                result.isFavorite = !result.isFavorite
                let image = result.isFavorite ?  UIImage(named: "favorite_fill") : UIImage(named: "favorite")
                self.bottomSheetView.favoriteButton.setImage( image, for: .normal)
                self.dataController.save()
            }
            
        }
        self.view.addSubview(bottomSheetView)
        
    }
    
    func showBottomSheet(show: Bool)  {
        let y = show ? screenSize.height - height - tabBarSize : screenSize.height
        bottomSheetView.animated(x: 0 ,y: y)
    }
    
    @objc func handleTap() {
        showBottomSheet(show:false)
    }
    
    
    func checkSelectCity() {
        navigationItem.title = city.name
        mapView.setRegion(getLastLocation(), animated: false)
        if let type =  UserDefaults.standard.object(forKey: Constants.mapType.rawValue) as? UInt {
            mapView.mapType = MKMapType(rawValue: type)!
        }
        requestLocation()
    }
    
    fileprivate func requestLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    fileprivate func selectMapType(type: MKMapType){
        self.mapView.mapType = type
        UserDefaults.standard.set(type.rawValue, forKey: Constants.mapType.rawValue)
    }
    
    // MARK: - IBActions
    
    @IBAction func locationAction(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func mapTypeAction(_ sender: Any) {
        let alert = UIAlertController(title: "Map Settings", message: nil, preferredStyle: .actionSheet )
        alert.addAction(UIAlertAction(title: "Standard", style: .default, handler: { (action)  in
            self.selectMapType(type: .standard)
        }))
        alert.addAction(UIAlertAction(title: "Satellite", style: .default, handler: { (action) in
            self.selectMapType(type: .satellite)
        }))
        alert.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: { (action) in
            self.selectMapType(type: .hybrid)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func changeModeAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            bikeMode = true
        case 1:
            bikeMode = false
        default:
            break;
        }
        updateData()
    }
    
}

extension MapViewController : MKMapViewDelegate, CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Access the last object from locations to get perfect current location
        if let location = locations.last {
            let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude)
            let region = MKCoordinateRegion(center: myLocation, latitudinalMeters: 700, longitudinalMeters: 700)
            mapView.setRegion(region, animated: true)
        }
        self.mapView.showsUserLocation = true
        manager.stopUpdatingLocation()
    }
    
    func mapView(_ map: MKMapView, didSelect view: MKAnnotationView) {
        self.mapView.deselectAnnotation( view.annotation, animated: true)
        if let annotation = view.annotation as? StationAnnotation {
            //    mapView.addGestureRecognizer(tapGesture)
            selectedAnnotation = annotation
            bottomSheetView.updateData(station: annotation.station)
            showBottomSheet(show: true)
            self.mapView.setCenter(annotation.coordinate, animated: true)
            
        }
    }
    
    func selectAnotation(station: Station){
        mapView.annotations.forEach { anotation in
            if let stationAnotation = anotation as? StationAnnotation, stationAnotation.station.id == station.id  {
                mapView.selectAnnotation(stationAnotation, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let stationAnnotation = annotation as? StationAnnotation else{
            return nil
        }
        let reuseId = stationAnnotation.station.id!
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: stationAnnotation, reuseIdentifier: reuseId)
            
        }else {
            pinView?.annotation = stationAnnotation
        }
        pinView?.markerTintColor = setColorStation(isBikes: bikeMode, station: stationAnnotation.station)
        pinView?.glyphImage = UIImage(named: bikeMode ? "bikes": "dock")
        pinView?.canShowCallout = false
        return pinView
    }
    
    func setColorStation(isBikes: Bool, station : Station) -> UIColor {
        guard station.freeBikes + station.emptySlots > 0 else{
            return .red
        }
        let total = station.freeBikes + station.emptySlots
        let value = isBikes ? station.freeBikes : station.emptySlots
        let available = (value * 100) / total
        
        if available > 50 {
            return .green
        } else if available > 0 {
            return .orange
        } else {
            return .red
        }
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveActualRegion(mapView.region)
    }
    
    fileprivate func saveActualRegion(_ region: MKCoordinateRegion) {
        let defaults =  UserDefaults.standard
        defaults.set(region.center.latitude, forKey: Constants.latitude.rawValue)
        defaults.set(region.center.longitude, forKey: Constants.longitude.rawValue)
        defaults.set(region.span.latitudeDelta, forKey: Constants.latitudeDelta.rawValue)
        defaults.set(region.span.longitudeDelta, forKey: Constants.longitudeDelta.rawValue)
        
    }
    
    fileprivate func getLastLocation() -> MKCoordinateRegion {
        let defaults =  UserDefaults.standard
        guard let latitude = defaults.object(forKey: Constants.latitude.rawValue) as? Double,
              let longitude = defaults.object(forKey: Constants.longitude.rawValue) as? Double,
              let latitudeDelta = defaults.object(forKey: Constants.latitudeDelta.rawValue)as? Double,
              let longitudeDelta = defaults.object(forKey: Constants.longitudeDelta.rawValue)as? Double
        else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude),latitudinalMeters: 7000,longitudinalMeters: 7000)
        }
        
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
    }
}

class StationAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var station: Station
    
    init(coordinate: CLLocationCoordinate2D, station: Station) {
        self.coordinate = coordinate
        self.station = station
    }
}
