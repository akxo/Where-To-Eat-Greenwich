//
//  FavoritesViewController.swift
//  Where To Eat? - Greenwich
//
//  Created by Alexander Kerendian on 7/15/17.
//  Copyright © 2017 Aktrapp. All rights reserved.
//

import UIKit
import GoogleMobileAds


class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    let blueish = UIColor.init(colorLiteralRed: 71/255, green: 169/255, blue: 255/255, alpha: 0.2)
    
    
    var randNum = -1
    
    @IBOutlet weak var favoritesTable: UITableView!
    

    @IBOutlet weak var bannerView2: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
        bannerView2.adUnitID = "ca-app-pub-7933787916135393/2155309492"
        bannerView2.rootViewController = self
        bannerView2.delegate = self
        

        bannerView2.load(request)
        
        
        navigationController?.navigationBar.barTintColor = blueish
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        tabBarController?.tabBar.barTintColor = blueish
        tabBarController?.tabBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setFavorites()
        favoritesTable.reloadData()
    }
    
    @IBAction func random(_ sender: Any) {
        if !favorites.isEmpty {
            randNum = Int(arc4random_uniform(UInt32(favorites.count)))
            performSegue(withIdentifier: "toDetailView2", sender: self)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = favorites[indexPath.row].name
        cell.detailTextLabel?.text = typesToString(array: (favorites[indexPath.row].type))
        cell.detailTextLabel?.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetailView2", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // delete data and row
            stringFavorites.remove(at: indexPath.row)
            favorites.remove(at: indexPath.row)
            data.set(stringFavorites, forKey: "favs")
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailView2" {
            if let indexPath = favoritesTable.indexPathForSelectedRow {
                let destination = segue.destination as! SelectedRestaurantViewController
                destination.selectedRestaurant = favorites[indexPath.row]
            }
            else if randNum >= 0 {
                let randRes = favorites[randNum]
                let destination = segue.destination as! SelectedRestaurantViewController
                destination.selectedRestaurant = randRes
                randNum = -1
            }
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
