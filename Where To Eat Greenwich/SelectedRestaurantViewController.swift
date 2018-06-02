//
//  SelectedRestaurantViewController.swift
//  Where To Eat? - Greenwich
//
//  Created by Alexander Kerendian on 7/16/17.
//  Copyright © 2017 Aktrapp. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SelectedRestaurantViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var errorView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var hoursLabel: UILabel!
    
    var inFavorites: Bool = false

    var selectedRestaurant: Restaurant? = nil
    
    @IBOutlet weak var phoneButton: UIButton!
    
    var favsIndex = 0
    
    var geocoder = CLGeocoder()
    
    var latitude: Double = 0.0
    
    var longitude: Double = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // errorView.isHidden = true
        
        errorLabel.sendSubview(toBack: view)
        errorView.sendSubview(toBack: view)
        
        if inFavorites {
            self.navigationItem.rightBarButtonItem?.title = "Remove From Favorites"
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        } else {
            self.navigationItem.rightBarButtonItem?.title = "Add To Favorites"
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.green
        }
        
        imageView.image = UIImage(named: "image.jpg")
        nameLabel.text = selectedRestaurant?.name
        nameLabel.textColor = UIColor.white
        priceLabel.text = selectedRestaurant?.price
    
        var typeString = ""
        var i = 0
        
        while i <= ((selectedRestaurant?.type.count)! - 1) {
            if i == (selectedRestaurant?.type.count)! - 1{
                typeString = typeString + (selectedRestaurant?.type[i])!
            }
            else {
                typeString = typeString + (selectedRestaurant?.type[i])! + ", "
            }
            i += 1
        }
        typeLabel.text = typeString
        
        hoursLabel.text = printHours()
        
        phoneButton.setTitle(phoneToString(), for: .normal)

        forwardGeocoding(address: (selectedRestaurant?.address)!)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        setFavorites()
        if stringFavorites.contains((selectedRestaurant?.name)!) {
            inFavorites = true
        } else {
            inFavorites = false
        }
        if inFavorites {
            self.navigationItem.rightBarButtonItem?.title = "Remove From Favorites"
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        } else {
            self.navigationItem.rightBarButtonItem?.title = "Add To Favorites"
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.green
        }

    }
    
    @IBAction func phoneButtonPressed(_ sender: Any) {
        let phoneUrl = "tel://" + (selectedRestaurant?.phoneNumber)!
        if let url = URL(string: phoneUrl){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            self.navigationController?.popViewController(animated: true)
        }
    }

    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("viewForAnnotation")
        if(annotation is MKUserLocation) {
            return nil
        }
        
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if(pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        
        let button = UIButton(type: .detailDisclosure) as UIButton
        
        pinView?.rightCalloutAccessoryView = button
        
        return pinView
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control as? UIButton)?.buttonType == UIButtonType.detailDisclosure {
            let url  = NSURL(string: "http://maps.apple.com/?q=" + String(latitude) + "," + String(longitude))
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url! as URL, options: [:])
            } else {
                UIApplication.shared.openURL(url! as URL)
            }
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }

    
    @IBAction func addButtonPressed(_ sender: Any) {
        if inFavorites {
            let index = stringFavorites.index(where: {$0.contains((selectedRestaurant?.name)!)})
            stringFavorites.remove(at: index!)
            data.set(stringFavorites, forKey: "favs")
            buildList()
            self.navigationItem.rightBarButtonItem?.title = "Add To Favorites"
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.green
        } else {
            stringFavorites.append((selectedRestaurant?.name)!)
            data.set(stringFavorites, forKey: "favs")
            buildList()
            self.navigationItem.rightBarButtonItem?.title = "Remove From Favorites"
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        }
        inFavorites = !inFavorites
    }
    
    func printHours() -> String {
        let week = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                    var hours = "Hours:"
        if selectedRestaurant?.hours == "" {
            hours = hours + "\n\nHours Not Available"
        } else {
            let dataHours = selectedRestaurant?.hours.components(separatedBy: " ")
            var i = 0
            for day in week {
                if dataHours?[i] == "0" {
                    if day == "Wednesday" || day == "Thursday" {
                        hours = hours + "\n" + day + ":\tClosed"
                    } else {
                        hours = hours + "\n" + day + ":\t\tClosed"
                    }
                    i += 1
                } else {
                    if day == "Wednesday" || day == "Thursday" {
                        hours = hours + "\n" + day + ":\t" + (dataHours?[i])! + " - "
                    } else {
                        hours = hours + "\n" + day + ":\t\t" + (dataHours?[i])! + " - "
                    }
                    i += 1
                    hours = hours + (dataHours?[i])!
                    i += 1
                }
            }
        }
        return hours
    }

    func phoneToString() -> String {
        
        var characters: [Character] = []
        if let number = selectedRestaurant?.phoneNumber {
            characters = Array(number.characters)
        }
        var phoneNumber = "("
        for i in 0...9 {
            if i == 3 {
                phoneNumber = phoneNumber + ") "
            } else if i == 6 {
                phoneNumber = phoneNumber + "-"
            }
            phoneNumber = phoneNumber + "\(characters[i])"
        }
        return phoneNumber
    }
    
    func forwardGeocoding(address: String) {
        geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print("No network connection")
               self.errorView.isHidden = false
                return
            }
            if (placemarks?.count)! > 0 {
                self.errorView.isHidden = true
                self.mapView.bringSubview(toFront: self.view)
                self.errorView.sendSubview(toBack: self.view)
                self.errorLabel.sendSubview(toBack: self.view)
                let placemark = placemarks?[0]
                let latitude = placemark?.location?.coordinate.latitude
                let longitude = placemark?.location?.coordinate.longitude
                self.latitude = Double(latitude!)
                self.longitude = Double(longitude!)
                let span: MKCoordinateSpan = MKCoordinateSpanMake(0.001, 0.001)
                let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
                self.mapView.setRegion(region, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                annotation.title = self.selectedRestaurant?.name
                annotation.subtitle = self.selectedRestaurant?.address
                self.mapView.addAnnotation(annotation)
            } else {
                print("No area of interest found.")
            }
        })
    }


    
    
    
    
    
    
    
}
