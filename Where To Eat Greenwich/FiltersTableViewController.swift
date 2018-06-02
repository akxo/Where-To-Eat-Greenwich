//
//  FiltersTableViewController.swift
//  Where To Eat? - Greenwich
//
//  Created by Alexander Kerendian on 7/20/17.
//  Copyright © 2017 Aktrapp. All rights reserved.
//

import UIKit

class FiltersTableViewController: UITableViewController {

    let allFilters = ["Greenwich", "Rye", "Port Chester", "Stamford", "White Plains", "American", "Burgers", "Asian", "Deli", "Italian", "Pizza", "Japanese", "Hibachi", "Sushi", "Diner", "Mexican", "Barbeque", "Chicken Shop", "Fast Food", "Salad", "Chinese", "Brazilian", "Latin American", "Indian", "Hot Dogs", "Mall", "$", "$$", "$$$"]
    
    var selectedFilters: [String] = []
    
    var i = 0
    
    func getFilters() -> [String] {
        return selectedFilters
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allFilters.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = allFilters[indexPath.row]
        if selectedFilters.contains((cell.textLabel?.text)!) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.none {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            selectedFilters.append(allFilters[indexPath.row])
        }
        else if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            selectedFilters.remove(at: selectedFilters.index(of: allFilters[indexPath.row])!)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        printArray(array: selectedFilters)
        // pass selectedFilters
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("preparing segue")
        let destination = segue.destination as! RestaurantsViewController
        destination.isFiltered = !(selectedFilters.isEmpty)
        destination.selectedFilters = selectedFilters

    }
 
    override func viewWillDisappear(_ animated: Bool) {
        
        
    }

    
    func printArray(array: [String]) {
        for i in array {
            print(i + "   ")
        }
    }
    


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
