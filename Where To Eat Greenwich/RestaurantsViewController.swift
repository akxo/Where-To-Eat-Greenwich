//
//  RestaurantsViewController.swift
//  Where To Eat? - Greenwich
//
//  Created by Alexander Kerendian on 7/15/17.
//  Copyright © 2017 Aktrapp. All rights reserved.
//

import UIKit
import GoogleMobileAds

class RestaurantsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, GADBannerViewDelegate {
    
    let blueish = UIColor.init(colorLiteralRed: 71/255, green: 169/255, blue: 255/255, alpha: 0.2)
    
    @IBOutlet weak var filter: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var randNum = -1
    
    var isFiltered: Bool = false
    
    var isSearching: Bool = false
    
    let locations = ["Greenwich", "Rye", "Port Chester", "Stamford", "White Plains"]
    let prices = ["$", "$$", "$$$"]
    let types = ["American", "Burgers", "Asian", "Deli", "Italian", "Pizza", "Japanese", "Hibachi", "Sushi", "Diner", "Mexican", "Barbeque", "Chicken Shop", "Fast Food", "Salad", "Chinese", "Brazilian", "Latin American", "Indian", "Hot Dogs", "Mall"]
    
    @IBOutlet weak var restaurantsTable: UITableView!
    
    @IBOutlet weak var filtersTable: UITableView!
    
    @IBOutlet weak var shadowView: UIView!
    
    var menuShowing: Bool = false


    @IBOutlet weak var menuTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var restaurantTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shadowTrailingConstraint: NSLayoutConstraint!
    
    let emptyArray = ["No Restaurants Found"]
    

    @IBOutlet weak var bannerView: GADBannerView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
        bannerView.adUnitID = "ca-app-pub-7933787916135393/4992924501"
        bannerView.rootViewController = self
        bannerView.delegate = self
        
        
        bannerView.load(request)

        
        searchRestaurants = restaurants
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        restaurantsTable.tableHeaderView = searchController.searchBar
        
        
        
        navigationController?.navigationBar.barTintColor = blueish
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        tabBarController?.tabBar.barTintColor = blueish
        tabBarController?.tabBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        
        if restaurants.isEmpty {
            parse()
            restaurants = allRestaurants
        }

        shadowView.layer.shadowColor = UIColor.darkGray.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.shadowRadius = 10
        
        filtersTable.layer.cornerRadius = 5
        shadowView.layer.cornerRadius = 5
        
        if menuShowing {
            menuTrailingConstraint.constant = 0
            shadowTrailingConstraint.constant = 0
        } else {
            menuTrailingConstraint.constant = -211
            shadowTrailingConstraint.constant = -211
        }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setFavorites()
        restaurantsTable.reloadData()
    }
    
   @IBAction func random(_ sender: Any) {
        if !restaurants.isEmpty {
            randNum = Int(arc4random_uniform(UInt32(restaurants.count)))
            if menuShowing {
                menuTrailingConstraint.constant = -211
                shadowTrailingConstraint.constant = -211
                menuShowing = !menuShowing
            }
            performSegue(withIdentifier: "toDetailView", sender: self)
        }
    }
    
    @IBAction func filterPressed(_ sender: Any) {
        if menuShowing {
            menuTrailingConstraint.constant = -211
            shadowTrailingConstraint.constant = -211
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
        } else {
            menuTrailingConstraint.constant = 0
            shadowTrailingConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
        }
        menuShowing = !menuShowing
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.isEqual(restaurantsTable) {
            if isSearching {
                return searchRestaurants.count
            } else if restaurants.isEmpty {
                return emptyArray.count
            } else {
                return restaurants.count
            }
        } else {
            return allFilters.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.isEqual(restaurantsTable) {
            return 60.0
        } else {
            return 44.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.isEqual(restaurantsTable) {
            if !restaurants.isEmpty {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
                var res = [Restaurant]()
                if isSearching {
                    res = searchRestaurants
                } else {
                    res = restaurants
                }
                cell.textLabel?.text = res[indexPath.row].name
                cell.detailTextLabel?.text = typesToString(array: (res[indexPath.row].type))
                cell.detailTextLabel?.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                return cell
            } else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
                cell.textLabel?.text = emptyArray[indexPath.row]
                return cell
            }
            
        } else {
            let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "filterCell")
            cell.textLabel?.text = allFilters[indexPath.row]
                cell.backgroundColor = #colorLiteral(red: 0.9655054952, green: 0.9655054952, blue: 0.9655054952, alpha: 1)
            if selectedFilters.contains(allFilters[indexPath.row]) {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
                
            }
           // cell.backgroundColor = UIColor.lightGray
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEqual(restaurantsTable) {
            performSegue(withIdentifier: "toDetailView", sender: self)
        } else {
            if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.none {
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
                let filter = allFilters[indexPath.row]
                selectedFilters.append(filter)
            }
            else if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
                selectedFilters.remove(at: selectedFilters.index(of: allFilters[indexPath.row])!)
            }
            restaurants = filterList()
            restaurantsTable.reloadData()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailView" {
            if let indexPath = restaurantsTable.indexPathForSelectedRow {
                let destination = segue.destination as! SelectedRestaurantViewController
                var res = [Restaurant]()
                if isSearching {
                    res = searchRestaurants
                } else {
                    res = restaurants
                }
                destination.selectedRestaurant = res[indexPath.row]
                if stringFavorites.contains(res[indexPath.row].name) {
                    destination.inFavorites = true
                } else {
                    destination.inFavorites = false
                }
            }
            else if randNum >= 0 {
                let randRes = restaurants[randNum]
                let destination = segue.destination as! SelectedRestaurantViewController
                destination.selectedRestaurant = randRes
                if stringFavorites.contains(randRes.name) {
                    destination.inFavorites = true
                } else {
                    destination.inFavorites = false
                }
                randNum = -1
            }
        }

    }
    
/*
    func filterList() -> [Restaurant] {
        var tempList: [Restaurant] = []
        for fil in selectedFilters {
            if types.contains(fil) {
                tempList = tempList + allRestaurants.filter() {$0.type.contains {$0.contains(fil)}}
            }
            else if fil.contains("$") {
                if tempList.isEmpty {
                    tempList = allRestaurants.filter() {$0.price.characters.count == fil.characters.count}
                }
                else {
                    tempList = tempList.filter() {$0.price.characters.count == fil.characters.count}
                }
            } else {
                
            }
        }
        if selectedFilters.isEmpty {
            return allRestaurants
        } else {
            return tempList
        }
    }
    */
    
    func filterList() -> [Restaurant] {
        if selectedFilters.isEmpty {
            return allRestaurants
        } else {
            var typeFilters: [String] = []
            var priceFilters: [String] = []
            var townFilters: [String] = []
            var typeRes: [Restaurant] = []
            var priceRes: [Restaurant] = []
            var townRes: [Restaurant] = []
            var tempList = [Restaurant]()
            for fil in selectedFilters {
                if fil.contains("$") {
                    priceFilters.append(fil)
                } else if (fil == "Rye") || (fil == "Greenwich") || (fil == "Port Chester") || (fil == "Stamford") || (fil == "White Plains") || (fil == "Harrison") {
                    townFilters.append(fil)
                } else {
                    typeFilters.append(fil)
                }
            }
            for fil in typeFilters {
                typeRes = typeRes + allRestaurants.filter() {$0.type.contains {$0.contains(fil)}}
            }
            for fil in priceFilters {
                priceRes = priceRes + allRestaurants.filter() {$0.price.characters.count == fil.characters.count}
            }
            for fil in townFilters {
                townRes = townRes + allRestaurants.filter() {$0.town.contains(fil)}
            }
            if !typeRes.isEmpty && !priceRes.isEmpty && !townRes.isEmpty {
                for res in allRestaurants {
                    outer: for ty in typeRes {
                        if ty.name == res.name {
                            for pr in priceRes {
                                if pr.name == res.name {
                                    for to in townRes {
                                        if to.name == res.name {
                                            tempList.append(res)
                                            break outer
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                return tempList
            } else if typeRes.isEmpty && !priceRes.isEmpty && !townRes.isEmpty {
                for res in allRestaurants {
                    outer: for pr in priceRes {
                        if pr.name == res.name {
                            for to in townRes {
                                if to.name == res.name {
                                    tempList.append(res)
                                    break outer
                                }
                            }
                        }
                    }
                }
                return tempList
            } else if !typeRes.isEmpty && priceRes.isEmpty && !townRes.isEmpty {
                for res in allRestaurants {
                    outer: for ty in typeRes {
                        if ty.name == res.name {
                            for to in townRes {
                                if to.name == res.name {
                                    tempList.append(res)
                                    break outer
                                }
                            }
                        }
                    }
                }
                return tempList
            } else if !typeRes.isEmpty && !priceRes.isEmpty && townRes.isEmpty {
                for res in allRestaurants {
                    outer: for ty in typeRes {
                        if ty.name == res.name {
                            for pr in priceRes {
                                if pr.name == res.name {
                                    tempList.append(res)
                                    break outer
                                }
                            }
                        }
                    }
                }
                return tempList
            } else if !typeRes.isEmpty && priceRes.isEmpty && townRes.isEmpty {
                for res in allRestaurants {
                    outer: for ty in typeRes {
                        if ty.name == res.name {
                            tempList.append(res)
                            break outer
                        }
                    }
                }
                return tempList
            } else if typeRes.isEmpty && !priceRes.isEmpty && townRes.isEmpty {
                for res in allRestaurants {
                    outer: for pr in priceRes {
                        if pr.name == res.name {
                            tempList.append(res)
                            break outer
                        }
                    }
                }
                return tempList
            } else if typeRes.isEmpty && priceRes.isEmpty && !townRes.isEmpty {
                for res in allRestaurants {
                    outer: for to in townRes {
                        if to.name == res.name {
                            tempList.append(res)
                            break outer
                        }
                    }
                }
                return tempList
            } else {
                return []
            }
        }
    }
    

    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if menuShowing {
            if gesture.direction == UISwipeGestureRecognizerDirection.right {
                menuTrailingConstraint.constant = -211
                shadowTrailingConstraint.constant = -211
                UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
            }
            menuShowing = !menuShowing
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.isEqual(restaurantsTable) {
            if menuShowing {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if !menuShowing {
            if tableView.isEqual(restaurantsTable) {
                var res = [Restaurant]()
                if isSearching {
                    res = searchRestaurants
                } else {
                    res = restaurants
                }
                if stringFavorites.contains(res[indexPath.row].name) {
                    let addAction = UITableViewRowAction(style: .default, title: "Already Added") {(action, index) in
                        tableView.isEditing = false
                    }
                    addAction.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                    return [addAction]
                } else {
                    let addAction = UITableViewRowAction(style: .default, title: "Add To Favorites") {(action, index) in
                        stringFavorites.append(res[indexPath.row].name)
                        data.set(stringFavorites, forKey: "favs")
                        buildList()
                        tableView.isEditing = false
                    }
                    addAction.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                    return [addAction]
                }
            } else {
                return []
            }
        } else {
            return []
        }
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        if menuShowing {
            menuTrailingConstraint.constant = -211
            shadowTrailingConstraint.constant = -211
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
            menuShowing = false
        }
        if searchController.searchBar.text == "" {
            isSearching = false
        } else {
            isSearching = true
            searchRestaurants = restaurants.filter({$0.name.lowercased().contains((searchController.searchBar.text?.lowercased())!)})
        }
        
        restaurantsTable.reloadData()
    }

    func printRes(resArray: [Restaurant]) {
        for res in resArray {
            print(res.name)
        }
    }
}
