//
//  CityViewController.swift
//  Weather
//
//  Created by Aaron Zhong on 18/06/18.
//  Copyright © 2018 Aaron Zhong. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol CityChangedDelegate {
    func cityChanged(cityName: String)
}

class CityViewController: UIViewController {
    
    var userDefaults = UserDefaults.standard
    var cities = [String]()
    
    var contrastColour: UIColor?
    var backgroundColour: UIColor?
    
    @IBOutlet weak var cityTableView: UITableView!
    @IBOutlet weak var addCityButton: UIButton!
    
    var cityChangedDelegate: CityChangedDelegate?
    var parentPageVC: PageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityTableView.delegate = self
        cityTableView.dataSource = self
        
        cityTableView.separatorStyle = .none
        cityTableView.rowHeight = 55
        
        if let cityItems = userDefaults.array(forKey: "cities") as? [String] {
            cities = cityItems
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add New City", message: "", preferredStyle: .alert)
        var textField: UITextField?
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "City Name"
            textField = alertTextField
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            // Add New City
            if let newCity = textField?.text {
                self.cities.append(newCity)
                
                self.userDefaults.set(self.cities, forKey: "cities")
                
                self.cityTableView.reloadData()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true, completion: nil)
    }
    
    func updateView() {
        if let bgColour = backgroundColour {
            view.backgroundColor = bgColour
        }
        
        if let textColour = contrastColour {
            addCityButton.tintColor = textColour
            cityTableView.reloadData()
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

// MARK: - Table View Delegate / Datasource

extension CityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cityTableView.dequeueReusableCell(withIdentifier: "CityCell") as! SwipeTableViewCell
        
        cell.delegate = self
        
        cell.textLabel?.text = cities[indexPath.row]
        
        if let textColour = contrastColour {
            cell.textLabel?.textColor = textColour
        }
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cityChangedDelegate?.cityChanged(cityName: cities[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        
        parentPageVC?.setViewControllers([(parentPageVC?.myVCs.first)!],
                           direction: .reverse,
                           animated: true,
                           completion: nil)
    }
}

// MARK: - BackgroundColour Delegate

extension CityViewController: BackgroundColourDelegate {
    func bgColourChanged(bgColour: UIColor, contrastColour: UIColor) {
        print("bgColourChanged called")
        self.backgroundColour = bgColour
        self.contrastColour = contrastColour
        
        updateView()
    }
}

// MARK: - SwipeTableViewDelegate

extension CityViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.cities.remove(at: indexPath.row)
            self.userDefaults.set(self.cities, forKey: "cities")
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
}
