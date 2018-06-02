//
//  Restaurants.swift
//  Where To Eat? - Greenwich
//
//  Created by Alexander Kerendian on 7/15/17.
//  Copyright © 2017 Aktrapp. All rights reserved.
//

import Foundation

struct Restaurant {
    
    let name: String
    let price: String
    let type: [String]
    let town: String
    let phoneNumber: String
    let address: String
    let hours: String
    
    
    init(name: String, price: String, type: [String], town: String, phoneNumber: String, address: String, hours: String) {
        self.name = name
        self.price = price
        self.type = type
        self.town = town
        self.phoneNumber = phoneNumber
        self.address = address
        self.hours = hours
    }
    
}

var allRestaurants = [Restaurant]()

var restaurants: [Restaurant] = []

let allFilters = ["Greenwich", "Rye", "Port Chester", "Stamford", "$", "$$", "$$$", "$$$$", "American", "Asian", "Bar", "Barbeque", "Burgers", "Chicken Shop", "Chinese", "Deli", "Diner", "Fast Food", "French", "Hibachi", "Indian", "Italian", "Japanese", "Mall", "Mexican", "Pizza", "Salad", "Seafood", "Spanish", "Steakhouse", "Sushi"]

var selectedFilters: [String] = []

var favorites: [Restaurant] = []

var stringFavorites: [String] = []

var searchRestaurants: [Restaurant] = []

let data = UserDefaults.standard

func buildList() {
    favorites = []
    for fav in stringFavorites {
        for res in allRestaurants {
            if fav.contains(res.name) {
                favorites.append(res)
            }
        }
    }
}



func setFavorites() {
    if data.object(forKey: "favs") == nil {
        favorites = []
        stringFavorites = []
    } else {
        stringFavorites = data.object(forKey: "favs") as! [String]
        buildList()
    }
    
}

func parse() {
    let path = Bundle.main.path(forResource: "greenwich", ofType: "txt")
    let filemgr = FileManager.default
    if filemgr.fileExists(atPath: path!) {
        
        do {
            let fullText = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            let lines = fullText.components(separatedBy: "\n") as [String]
            for line in lines {
                if !line.isEmpty {
                    let resData = line.components(separatedBy: ";")
                    let name = resData[0]
                    let price = resData[1]
                    let type = resData[2].components(separatedBy: ",") as [String]
                    let town = resData[3]
                    let phoneNumber = resData[4]
                    let address = resData[5]
                    let hours = resData[6]
                
                
                    let res = Restaurant(name: name, price: price, type: type, town: town, phoneNumber: phoneNumber, address: address, hours: hours)
                    allRestaurants.append(res)
                }
            }
    
        } catch let error as NSError {
            print("Error: \(error)")
        }
    }
}


func typesToString(array: [String]) -> String {
    var type = ""
    for i in 0...(array.count - 1) {
        if i == array.count - 1 {
            type = type + array[i]
        } else {
            type = type + array[i] + ", "
        }
    }
    return type
}
