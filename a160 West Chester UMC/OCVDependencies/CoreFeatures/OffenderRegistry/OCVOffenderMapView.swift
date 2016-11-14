//
//  OCVOffenderMapView.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/20/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import MapKit

class OCVOffenderMapView: UIViewController {
    let clusteringManager = FBClusteringManager()

    let offenders: [OCVOffenderObjectViewModel]!
    let offenderLocations: [FBAnnotation]
    let mapView = MKMapView()

    init(offenders: [[OCVOffenderObjectViewModel]]) {
        self.offenders = offenders.flatMap {$0}.filter { $0.coordinates.latitude != 0.0 && $0.coordinates.longitude != 0.0 }

        let averageLat = self.offenders.map { Double($0.coordinates.latitude) }.reduce(0.0, + ) / Double(self.offenders.count)
        let averageLon = self.offenders.map { Double($0.coordinates.longitude) }.reduce(0.0, + ) / Double(self.offenders.count)
        let averageLocation = CLLocation(latitude: averageLat, longitude: averageLon)

        let regionRadius = 800000.0
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(averageLocation.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)

        self.offenderLocations = self.offenders.flatMap {
            let annotation = FBAnnotation()
            annotation.title = $0.displayName
            annotation.offender = $0
            annotation.coordinate = CLLocationCoordinate2D(latitude: $0.coordinates.latitude, longitude: $0.coordinates.longitude)
            return annotation
            }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }

        clusteringManager.addAnnotations(offenderLocations)
        clusteringManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension OCVOffenderMapView: FBClusteringManagerDelegate {
    func cellSizeFactorForCoordinator(_ coordinator: FBClusteringManager) -> CGFloat {
        return 1.0
    }
}


extension OCVOffenderMapView: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        OperationQueue().addOperation({
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth: Double = self.mapView.visibleMapRect.size.width
            let scale: Double = mapBoundsWidth / mapRectWidth
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale: scale)
            self.clusteringManager.displayAnnotations(annotationArray, onMapView: self.mapView)
        })

    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let offenderAnnotation = view.annotation as? FBAnnotation {
            if let selectedOffender = offenderAnnotation.offender {
                navigationController?.pushViewController(OCVOffenderDetail(offender: selectedOffender), animated: true)
            }
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var reuseId = ""
        if annotation.isKind(of: FBAnnotationCluster.self) {
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
            return clusterView
        } else {
            reuseId = "Pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            if #available(iOS 9.0, *) {
                pinView?.pinTintColor = AppColors.alertRed.color
            } else {
                pinView?.pinColor = MKPinAnnotationColor.red
            }

            let disclosureButton = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = disclosureButton

            return pinView
        }
    }
}
