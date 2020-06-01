//
//  PlacesVC.swift
//  GooglePlacesDemo
//
//  Created by Eric Stein on 5/29/20.
//  Copyright © 2020 Eric Stein All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import CoreLocation
//import GoogleMaps
import MapKit
import CoreData

class PlacesVC: UIViewController {
    
    
    var placesArr = [PlaceEntity]()
    @IBOutlet weak var placeTV: UITableView!
    var searchLocation : CLLocation!
    
    //show activity indicator while calling google places api
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!
    
    //    @IBOutlet weak var googleMap: GMSMapView!
    @IBOutlet weak var mapView: MKMapView!
    
    //Take latitude from user
    @IBOutlet weak var latitudeTF: UITextField!
    
    //Take longitude from user
    @IBOutlet weak var longitudeTF: UITextField!
    
    //display radius changed by user
    @IBOutlet weak var radiusLbl: UILabel!
    
    //It will display number of places found
    @IBOutlet weak var resultCountLbl: UILabel!
    
    //this is to toggle between list and map
    var showPlacesList = true
    
    //default start radius set to 50
    var currentRadius = 1000
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    //this will be use when user scroll and to load more results from google places api
    var nextPageApiToken = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //number keyboard doens't display done option so added for dismissing keyboard
        addDoneButtonOnKeyboard()
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        latitudeTF.inputAccessoryView = doneToolbar
        longitudeTF.inputAccessoryView = doneToolbar
        
    }
    
    @objc func doneButtonAction(){
        //dismiss keyboard
        self.view.endEditing(true)
    }
    
    func callGooglePlacesApi(latitude:String,longitude:String) {
        
        //start activity indicator
        self.actIndicator.startAnimating()
        
        //call api
        Alamofire.request("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(currentRadius)&key=\(googleApiKey)").responseJSON { (responseData) -> Void in
            
            //Once api response comes stop loader
            self.actIndicator.stopAnimating()
            
            if let responseDict = responseData.result.value as? NSDictionary{
                print("Resp is \(responseDict)")
                self.nextPageApiToken = responseDict.value(forKey: "next_page_token") as? String ?? ""
                
                let resultArr = responseDict.value(forKey: "results") as! [NSDictionary]
                
                for dict in resultArr{
                    
                    //call method to show places on map
                    //                    self.showPlacesOnMap()
                    var place : PlaceEntity!
                    let placeId = dict.value(forKey: "place_id") as? String
                    
                    //check if this place already exist
                    let fetchRequest = NSFetchRequest<PlaceEntity>(entityName: "PlaceEntity")
                    fetchRequest.predicate = NSPredicate(format: "placeId = %@", placeId!)
                    do{
                        let savedPlaces = try self.context.fetch(fetchRequest)
                        if savedPlaces.count > 0{
                            //update already saved item
                            place = savedPlaces[0]
                            print("place exist")
                        }else{
                            //save new item
                            place = PlaceEntity(context: self.context)
                        }
                        
                    }catch{
                        
                    }
                    
                    place.placeId = placeId
                    place.placeName = dict.value(forKey: "name") as? String
                    
                    if let geometry = dict.value(forKey: "geometry") as? NSDictionary , let location = geometry.value(forKey: "location") as? NSDictionary{
                        place.latitude = location.value(forKey: "lat") as! Double
                        place.longitude = location.value(forKey: "lng") as! Double
                        
                        print("lat \(place.latitude) long \(place.longitude)")
                    }
                    if let photoArr = dict.value(forKey: "photos") as? [NSDictionary] , photoArr.count > 0{
                        let photoDict = photoArr[0]
                        place.placeImage = photoDict.value(forKey: "photo_reference") as? String
                    }
                    
                    self.appDel.saveContext()
                }
               
                //remove previous results
                self.placesArr.removeAll()
                
                //remove all annotations from map
                self.mapView.removeAnnotations(self.mapView.annotations)
                
                self.fetchDataFromDB()
            }
            self.placeTV.reloadData()
        }
    }
    
    func showPlacesOnMap(){
        var placeAnnotations = [MKPointAnnotation]()
        //plot places on Map
        for place in self.placesArr {
            let annotation = MKPointAnnotation()
            let placeCoordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude:place.longitude)
            annotation.coordinate = placeCoordinate
            annotation.title = place.placeName
            placeAnnotations.append(annotation)
        }
        //zoom to visible all places
        self.mapView.showAnnotations(placeAnnotations, animated: true)
    }
    
    @IBAction func navigationBtnPress(_ sender: UIBarButtonItem) {
        
        self.navigationItem.rightBarButtonItem =  nil
        
        if showPlacesList{
            //if previously showing list then toggle to map
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "List", style: .done, target: self, action: #selector(navigationBtnPress(_:)))
            
            //hide map and show list
            self.placeTV.isHidden = true
            self.mapView.isHidden = false
            
        }else{
            //if previously showing map then toggle to list
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map", style: .done, target: self, action: #selector(navigationBtnPress(_:)))
            
            //hide list and show map
            self.placeTV.isHidden = false
            self.mapView.isHidden = true
            
        }
        showPlacesList = !showPlacesList
    }
    
    @IBAction func searchBtnPress(_ sender: UIButton) {
        
        //dismiss keyboard
        self.view.endEditing(true)
        
        //remove previous results
        self.placesArr.removeAll()
        
        //remove all annotations from map
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        
        guard let latitudeVal = latitudeTF.text , latitudeVal.count > 0 else {
            AppManager.shared.showAlert(title: "Error", msg: "Enter Latitude", vc: self)
            return
        }
        
        guard let longitudeVal = longitudeTF.text , longitudeVal.count > 0 else {
            AppManager.shared.showAlert(title: "Error", msg: "Enter Longitude", vc: self)
            return
        }
        
        //user has entered both lets search
        searchLocation = CLLocation(latitude:Double(latitudeVal)!, longitude: Double(longitudeVal)!)
        
        //fetch and show already stored data to user if exist
        fetchDataFromDB()
        
        callGooglePlacesApi(latitude: latitudeVal, longitude: longitudeVal)
    }
    
    func fetchDataFromDB(){
        let fetchRequest = NSFetchRequest<PlaceEntity>(entityName: "PlaceEntity")
        let sort = NSSortDescriptor(key: #keyPath(PlaceEntity.placeName), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        do{
            //get all places in ascending order
            let savedPlaces = try self.context.fetch(fetchRequest)
            for place in savedPlaces{
                let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
                let distanceInMeters = searchLocation.distance(from: placeLocation) // result is in meters
                print("distance \(distanceInMeters)")
                if distanceInMeters <= Double(currentRadius){
                    //dynamically adding distance in model but not saving in Coredata
                    place.distance = distanceInMeters
                    placesArr.append(place)
                }
            }
            print("Places count \(placesArr.count)")
            self.placeTV.reloadData()
            
            self.resultCountLbl.text = "\(placesArr.count) places found"
        }catch{
            
        }
        
        showPlacesOnMap()
    }
    
    //Manage Radius
    @IBAction func radiusChange(_ sender: UISlider) {
        currentRadius = Int(sender.value)
        radiusLbl.text = "\(currentRadius) m"
    }
    
    
}

//Display places on TableView
extension PlacesVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentPlace = placesArr[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlacesTVC") as! PlacesTVC
        cell.selectionStyle = .none
        cell.placeNameLbl.text = currentPlace.placeName
                cell.distanceLbl.text = String(format: "%.2f km", currentPlace.distance/1000)
        
        if let placeImg = currentPlace.placeImage{
            //if google places image reference link exist then only call api
            let imUrl = URL(string: "\(googleImgUrl)\(placeImg)")
            cell.placeImgV.kf.setImage(with: imUrl,placeholder: UIImage(named: "placeholder.png"))
        }else{
            //set placeholder image url not exist
            cell.placeImgV.image = UIImage(named: "placeholder.png")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        //hide extra tableview lines
        return 0.1
    }
}
