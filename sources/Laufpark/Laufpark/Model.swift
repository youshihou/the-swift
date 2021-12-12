//
//  Model.swift
//  Laufpark
//
//  Created by Ankui on 12/11/21.
//

import Foundation
import CoreLocation
import UIKit
import MapKit


struct POI {
    let location: CLLocationCoordinate2D
    let name: String
    
    
    static let all: [POI] = [
        POI(location: CLLocationCoordinate2D(latitude: 53.187240, longitude: 13.088585), name: "Gasthaus Haveleck"),
        POI(location: CLLocationCoordinate2D(latitude: 53.191610, longitude: 13.159954), name: "Jugendherberge Ravensbrück"),
        POI(location: CLLocationCoordinate2D(latitude: 53.179984, longitude: 12.899209), name: "Hotel & Ferienanlage Precise Resort Marina Wolfsbruch"),
        POI(location: CLLocationCoordinate2D(latitude: 52.966637,longitude: 13.281789), name: "Pension Lindenhof"),
        POI(location: CLLocationCoordinate2D(latitude: 53.091639, longitude: 13.093251), name: "Gut Zernikow"),
        POI(location: CLLocationCoordinate2D(latitude: 53.031421, longitude: 13.30988), name: "Ziegeleipark Mildenberg"),
        POI(location: CLLocationCoordinate2D(latitude: 53.112691, longitude: 13.104139), name: "Hotel und Restaurant \"Zum Birkenhof\""),
        POI(location: CLLocationCoordinate2D(latitude: 53.167976, longitude: 13.23558), name: "Campingpark Himmelpfort"),
        POI(location: CLLocationCoordinate2D(latitude: 53.115591, longitude: 12.889571), name: "Maritim Hafenhotel Reinsberg"),
        POI(location: CLLocationCoordinate2D(latitude: 53.175714, longitude: 13.232601), name: "Ferienwohnung in der Mühle Himmelpfort"),
        POI(location: CLLocationCoordinate2D(latitude: 53.115685, longitude: 13.25494), name: "Gut Boltenhof"),
        POI(location: CLLocationCoordinate2D(latitude: 53.053821, longitude: 13.083495), name: "Werkshof Wolfsruh")
    ]
}






enum Color {
    case red
    case turquoise
    case brightGreen
    case violet
    case purple
    case green
    case beige
    case blue
    case brown
    case yellow
    case gray
    case lightBlue
    case lightBrown
    case orange
    case pink
    case lightPink
}

extension Color {
    var name: String {
        switch self {
        case .red: return "rot"
        case .turquoise: return "tuerkis"
        case .brightGreen: return "hellgruen"
        case .beige: return "beige"
        case .green: return "gruen"
        case .purple: return "lila"
        case .violet: return "violett"
        case .blue: return "blau"
        case .brown: return "braun"
        case .yellow: return "gelb"
        case .gray: return "grau"
        case .lightBlue: return "hellblau"
        case .lightBrown: return "hellbraun"
        case .orange: return "orange"
        case .pink: return "pink"
        case .lightPink: return "rosa"
        }
    }
}

extension Color {
    var uiColor: UIColor {
        switch self {
        case .red: return UIColor(r: 255, g: 0, b: 0)
        case .turquoise: return UIColor(r: 0, g: 159, b: 159)
        case .brightGreen: return UIColor(r: 104, g: 195, b: 12)
        case .violet: return UIColor(r: 174, g: 165, b: 213)
        case .purple: return UIColor(r: 135, g: 27, b: 138)
        case .green: return UIColor(r: 0, g: 132, b: 70)
        case .beige: return UIColor(r: 227, g: 177, b: 151)
        case .blue: return UIColor(r: 0, g: 92, b: 181)
        case .brown: return UIColor(r: 126, g: 50, b: 55)
        case .yellow: return UIColor(r: 255, g: 244, b: 0)
        case .gray: return UIColor(r: 174, g: 165, b: 213)
        case .lightBlue: return UIColor(r: 0, g: 166, b: 198)
        case .lightBrown: return UIColor(r: 190, g: 135, b: 90)
        case .orange: return UIColor(r: 255, g: 122, b: 36)
        case .pink: return UIColor(r: 255, g: 0, b: 94)
        case .lightPink: return UIColor(r: 255, g: 122, b: 183)
        }
    }
}

extension UIColor {
    convenience init(r: Int, g: Int, b: Int) {
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1)
    }
}





struct Point {
    let lat: Double
    let lon: Double
    let ele: Double
}





struct Track {
    let coordinates: [(CLLocationCoordinate2D, elevation: Double)]
    let color: Color
    let number: Int
    let name: String

    var distance: CLLocationDistance {
        guard let first = coordinates.first else {
            return 0
        }
        let (result, _) = coordinates.reduce(into: (0 as CLLocationDistance, previous: CLLocation(first.0))) { r, coord in
            let loc = CLLocation(coord.0)
            let distance = loc.distance(from: r.1)
            r.1 = loc
            r.0 += distance
        }
        return result
    }
    var ascent: Double {
        let elevations = coordinates.lazy.map { $0.elevation }
        return elevations.diffed(with: -).filter { $0 > 0 }.reduce(0, +)
    }
    
    func point(at distance: CLLocationDistance) -> CLLocation? {
        var current = 0 as CLLocationDistance
        for (p1, p2) in coordinates.lazy.map({ CLLocation($0.0) }).diffed() {
            current += p2.distance(from: p1)
            if current > distance { return p2 }
        }
        return nil
    }
}

extension Track: Equatable {
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Track {
    init(color: Color, number: Int, name: String, points: [Point]) {
        self.color = color
        self.number = number
        self.name = name
        coordinates = points.map { point in
            (CLLocationCoordinate2D(latitude: point.lat, longitude: point.lon), elevation: point.ele)
        }
    }
}

extension Track {
    var polygon: MKPolygon {
        var coordinates = self.coordinates.map { $0.0 }
        let result = MKPolygon(coordinates: &coordinates, count: coordinates.count)
        return result
    }
    
    typealias ElevationProfile = [(distance: CLLocationDistance, elevation: Double)]
    var elevationProfile: ElevationProfile {
        let result = coordinates.diffed { l, r in
            (CLLocation(l.0).distance(from: CLLocation(r.0)), r.elevation)
        }
        var distanceTotal = 0 as CLLocationDistance
        return result.map { pair in
            defer { distanceTotal += pair.0 }
            return (distance: distanceTotal, elevation: pair.1)
        }
    }
}





extension String {
    func remove(prefix: String) -> String {
        String(dropFirst(prefix.count))
    }
}


extension CLLocation {
    convenience init(_ coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}


extension Sequence {
    func diffed() -> AnySequence<(Element, Element)> {
        return AnySequence(zip(self, self.dropFirst()))
    }

    func diffed<Result>(with combine: (Element, Element) -> Result) -> [Result] {
        return zip(self, self.dropFirst()).map { combine($0.0, $0.1) }
    }
}










final class TrackReader: NSObject, XMLParserDelegate {
    var inTrk = false
    var points: [Point] = []
    var pending: (lat: Double, lon: Double)?
    var elementContents: String = ""
    var name = ""
    
    init?(url: URL) {
        guard let parser = XMLParser(contentsOf: url) else { return nil }
        super.init()
        parser.delegate = self
        guard parser.parse() else { return nil }
    }

    
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        elementContents += string
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        guard inTrk else {
            inTrk = elementName == "trk"
            return
        }
        if elementName == "trkpt" {
            guard let latStr = attributeDict["lat"], let lat = Double(latStr),
                  let lonStr = attributeDict["lon"], let lon = Double(lonStr) else {
                      return
                  }
            pending = (lat: lat, lon: lon)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        defer { elementContents = "" }
        var trimmed: String {
            elementContents.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if elementName == "trk" {
            inTrk = false
        } else if elementName == "ele" {
            guard let p = pending, let ele = Double(trimmed) else { return }
            points.append(Point(lat: p.lat, lon: p.lon, ele: ele))
        } else if elementName == "name" && inTrk {
            name = trimmed.remove(prefix: "Laufpark Stechlin - Wabe ")
        }
    }
}
