//
//  Helpers.swift
//  Laufpark
//
//  Created by Ankui on 12/12/21.
//

import UIKit
import MapKit

extension UIView {
    func addConstraintsToSizeToParent(spaceing: CGFloat = 0) {
        guard let view = superview else { fatalError() }
        let top = topAnchor.constraint(equalTo: view.topAnchor)
        let bottom = bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let left = leftAnchor.constraint(equalTo: view.leftAnchor)
        let right = rightAnchor.constraint(equalTo: view.rightAnchor)
        view.addConstraints([top, bottom, left, right])
        if spaceing != 0 {
            top.constant = spaceing
            bottom.constant = spaceing
            left.constant = -spaceing
            right.constant = -spaceing
        }
    }
}


extension Comparable {
    func clamped(to: ClosedRange<Self>) -> Self {
        if self < to.lowerBound {
            return to.lowerBound
        }
        if self > to.upperBound {
            return to.upperBound
        }
        return self
    }
}


func time(name: StaticString = #function, line: Int = #line, _ f: () -> Void) {
    let startTime = DispatchTime.now()
    f()
    let endTime = DispatchTime.now()
    let diff = (endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000
    print("\(name) (line \(line)): \(diff)")
}



func buildMapView() -> MKMapView {
    let view = MKMapView()
    view.showsCompass = true
    view.showsScale = true
    view.showsUserLocation = true
    view.mapType = .standard
    view.isRotateEnabled = false
    view.isPitchEnabled = false
    return view
}
