//
//  XMLParser.swift
//  AssessmentApp
//
//  Created by Sumit K Das on 6/4/17.
//  Copyright © 2017 Sumit K Das. All rights reserved.
//

import Foundation

class XMLData {
    var uid: String
    var name: String
    var gender: String
    var yob: String
    var co: String
    var house: String
    var street: String
    var lm: String
    var vtc: String
    var po: String
    var dist: String
    var subdist: String
    var state: String
    var pc: String
    var dob: String
    
    init?(dictionary: [String : String]) {
        guard let uid = dictionary["uid"],
            let name = dictionary["name"],
            let gender = dictionary["gender"],
            let yob = dictionary["yob"],
            let co = dictionary["co"],
            let house = dictionary["house"],
            let street = dictionary["street"],
            let lm = dictionary["lm"],
            let vtc = dictionary["vtc"],
            let po = dictionary["po"],
            let dist = dictionary["dist"],
            let subdist = dictionary["subdist"],
            let state = dictionary["state"],
            let pc = dictionary["pc"],
            let dob = dictionary["dob"] else {
                return nil
}
        self.uid = uid
        self.name = name
        self.gender = gender
        self.yob = yob
        self.co = co
        self.house = house
        self.street = street
        self.lm = lm
        self.vtc = vtc
        self.po = po
        self.dist = dist
        self.subdist = subdist
        self.state = state
        self.pc = pc
        self.dob = dob
        
    }
}
class MyParser: NSObject {
    var parser: XMLParser
    
    var data = [XMLData]()
    
    init(xml: String) {
        parser = XMLParser(data: xml.data(using: String.Encoding.utf8)!)
        super.init()
        parser.delegate = self as! XMLParserDelegate
    }
    
    func parseXML() -> [XMLData] {
        parser.parse()
        return data
    }
    
}
extension MyParser: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "map" {
            
            if let datum = XMLData(dictionary: attributeDict) {
                data.append(datum)
            }
        }
    }
}
