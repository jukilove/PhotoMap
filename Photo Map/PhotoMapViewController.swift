//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate , LocationsViewControllerDelegate, MKMapViewDelegate {

    @IBOutlet weak var MapView: MKMapView!
    
    var image: UIImage?
    var sentImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //one degree of latitude is approximately 111 kilometers (69 miles) at all times.
        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
                                              MKCoordinateSpanMake(0.1, 0.1))
        MapView.setRegion(sfRegion, animated: false)
        MapView.delegate = self
    }
    

    @IBAction func didPressForCamera(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            print("Camera is available 📸")
            vc.sourceType = .camera
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            vc.sourceType = .photoLibrary
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
      
        _ = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        self.image = editedImage
        
        dismiss(animated: true) {
            self.performSegue(withIdentifier: "tagSegue", sender: nil)
        }
        
        
    }
    
    func locationsPicked(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
               // pop the LocationsViewController from the view stack and show the PhotoMapViewController
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        let annotation = MKPointAnnotation()
        annotation.title = coordinate.latitude.description
        annotation.coordinate = coordinate
        
        MapView.addAnnotation(annotation)
        controller.navigationController?.popToRootViewController(animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuse = "myAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuse)
        if let annotationView = annotationView {
            let imageView = annotationView.leftCalloutAccessoryView as! UIImageView
            imageView.image = image ?? #imageLiteral(resourceName: "camera")
            
            
        }
        else{
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuse)
            annotationView?.canShowCallout = true
            annotationView?.leftCalloutAccessoryView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
            imageView.image = image ?? #imageLiteral(resourceName: "camera")
        }
        let view = annotation as? PhotoAnnotation
        view?.photo = image
        annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return annotationView
    }
    
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let image = view.annotation as! PhotoAnnotation
        sentImage = image.photo
        self.performSegue(withIdentifier: "fullImageSegue", sender: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "tagSegue" {
            if let vc = segue.destination as? LocationsViewController {
                vc.delegate = self
            }
        }else{
            if let vc = segue.destination as? FullImageViewController {
                vc.photo.image = sentImage
            }
        }
    }
    }
