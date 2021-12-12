//
//  ViewController.swift
//  Laufpark
//
//  Created by Ankui on 12/11/21.
//

import UIKit
import MapKit


struct State: Equatable {
    var tracks: [Track] = []
    var trackPosition: CGFloat? // 0...1
    var selection: MKPolygon? {
        didSet {
            trackPosition = nil
        }
    }
    var loading: Bool {
        tracks.isEmpty
    }
    var hasSelection: Bool {
        selection != nil
    }
    
    
    static func == (lhs: State, rhs: State) -> Bool {
        lhs.selection == rhs.selection &&
        lhs.trackPosition == rhs.trackPosition &&
        lhs.tracks == rhs.tracks
    }
}




class ViewController: UIViewController {
    private let mapView: MKMapView = buildMapView()
    private let positionAnnotation = MKPointAnnotation()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let trackInfoView = TrackInfoView()
    private var trackInfoBottomConstraint: NSLayoutConstraint?
    private let trackInfoViewHeight: CGFloat = 120
    
    private var state: State = State() {
        didSet {
            update(old: oldValue)
        }
    }
    private var polygons: [MKPolygon: Track] = [:]
    private let locationManager = CLLocationManager()
    
    
    func setTracks(_ t: [Track]) {
        state.tracks = t
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(mapTapped(sender:)))
        mapView.addGestureRecognizer(gesture)
        mapView.addAnnotation(positionAnnotation)
        loadingIndicator.startAnimating()
        
        trackInfoView.panGestureRecognizer.addTarget(self, action: #selector(didPanProfile(sender:)))
        
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.addConstraintsToSizeToParent()
        mapView.delegate = self
        
        view.addSubview(trackInfoView)
        trackInfoView.backgroundColor = .white
        trackInfoView.translatesAutoresizingMaskIntoConstraints = false
        trackInfoBottomConstraint = trackInfoView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: trackInfoViewHeight)
        NSLayoutConstraint.activate([
            trackInfoBottomConstraint!,
            trackInfoView.leftAnchor.constraint(equalTo: view.leftAnchor),
            trackInfoView.rightAnchor.constraint(equalTo: view.rightAnchor),
            trackInfoView.heightAnchor.constraint(equalToConstant: trackInfoViewHeight)
        ])
        
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        resetMapRect()
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        resetMapRect()
    }
    
    private func resetMapRect() {
        let origin = MKMapPoint(x: 143758507.60971117, y: 86968700.835495561)
        let size = MKMapSize(width: 437860.61378830671, height: 749836.27541357279)
        let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        mapView.setVisibleMapRect(MKMapRect(origin: origin, size: size), edgePadding: insets, animated: true)
    }
    
    private func update(old: State) {
        if state.loading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        if state.tracks != old.tracks {
            mapView.removeOverlays(mapView.overlays)
            for track in state.tracks {
                let polygon = track.polygon
                polygons[polygon] = track
                mapView.addOverlay(polygon)
            }
        }
        if state.selection != old.selection {
            trackInfoView.track = state.selection.flatMap { polygons[$0] }
            for polygon in polygons.keys {
                guard let renderer = mapView.renderer(for: polygon) as? MKPolygonRenderer else {
                    continue
                }
                renderer.configure(color: polygons[polygon]!.color.uiColor, selected: !state.hasSelection)
            }
            if let selectedPolygon = state.selection, let renderer = mapView.renderer(for: selectedPolygon) as? MKPolygonRenderer {
                renderer.configure(color: polygons[selectedPolygon]!.color.uiColor, selected: true)
            }
        }
        if state.hasSelection != old.hasSelection {
            trackInfoBottomConstraint?.constant = state.hasSelection ? 0 : trackInfoViewHeight
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        if state.trackPosition != old.trackPosition {
            if let position = state.trackPosition,
                let selection = state.selection,
                let track = polygons[selection] {
                let distance = Double(position) * track.distance
                if let point = track.point(at: distance) {
                    positionAnnotation.coordinate = point.coordinate
                }
            } else {
                positionAnnotation.coordinate = CLLocationCoordinate2D()
            }
        }
    }
    
    @objc func didPanProfile(sender: UIPanGestureRecognizer) {
        let normalizedPosition = (sender.location(in: trackInfoView).x / trackInfoView.bounds.size.width).clamped(to: 0.0...1.0)
        state.trackPosition = normalizedPosition
    }
    
    @objc func mapTapped(sender: UITapGestureRecognizer) {
        let point = sender.location(ofTouch: 0, in: mapView)
        let mapPoint = MKMapPoint(mapView.convert(point, toCoordinateFrom: mapView))
        let possibilities = polygons.keys.filter { polygon in
            guard let render = mapView.renderer(for: polygon) as? MKPolygonRenderer else {
                return false
            }
            let point = render.point(for: mapPoint)
            return render.path.contains(point)
        }
        if let s = state.selection, possibilities.count > 1 && possibilities.contains(s) {
            state.selection = possibilities.lazy.sorted { $0.pointCount < $1.pointCount }.first(where: { $0 != s })
        } else {
            state.selection = possibilities.first
        }
    }
}



extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polygon = overlay as? MKPolygon else {
            return MKOverlayRenderer()
        }
        if let renderer = mapView.renderer(for: overlay)  {
            return renderer
        }
        let renderer = MKPolygonRenderer(polygon: polygon)
        let isSelected = state.selection == polygon
        renderer.configure(color: polygons[polygon]!.color.uiColor, selected: isSelected || !state.hasSelection)
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let pointAnnotation = annotation as? MKPointAnnotation, pointAnnotation == positionAnnotation else {
            return nil
        }
        let result = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        result.pinTintColor = .red
        return result
    }
}




extension MKPolygonRenderer {
    func configure(color: UIColor, selected: Bool) {
        strokeColor = color
        fillColor = selected ? color.withAlphaComponent(0.2) : color.withAlphaComponent(0.1)
        lineWidth = selected ? 3 : 1
    }
}
