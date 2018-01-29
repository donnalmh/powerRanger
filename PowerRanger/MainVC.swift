//
//  ViewController.swift
//  PowerRanger
//
//  Created by Donna Samuel on 27/1/18.
//  Copyright © 2018 donnali. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    // Variables
    @IBOutlet weak var mapImage: UIView!
    @IBOutlet weak var tableView: UITableView!
    var controller: NSFetchedResultsController<PowerRanger>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchData()
        controller.delegate = self
        tableView.reloadData()
        print("End cellForRowAt")
        
    }
    
    // UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Accessing cellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: "PowerCell", for: indexPath) as! PowerCell
        updateCell(cell: cell, indexPath: indexPath as NSIndexPath )
        updateMap(indexPath: indexPath)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = controller.sections{
            return sections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = controller.sections{
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    // UITableViewDelegate methods
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Grey out cell and render unselectable
        
        // Re-configuring data so that Power Ranger is indicated as deployed and will update Map
        print("Deployed")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select Row:\(indexPath)")
        // Grey out cell and render unselectable
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        
        
        // Re-configuring data so that Power Ranger is indicated as deployed and will update Map
        let powercell = controller.object(at: indexPath as IndexPath)
        powercell.deployed()
        updateMap(indexPath: indexPath)
    }
    
    func updateMap(indexPath: IndexPath){
        let powerRanger = controller.object(at: indexPath)
        if(powerRanger.isDeployed){
            drawRect(powerRanger: powerRanger)
        }
    }
    
    func drawRect(powerRanger: PowerRanger){
        let mapCenterX =  mapImage.frame.width/2 - RECT_WIDTH/2 + powerRanger.pointX
        let mapCenterY = mapImage.frame.height/2 - RECT_HEIGHT/2 + powerRanger.pointY
        let rect = CGRect(x: mapCenterX, y: mapCenterY, width: RECT_WIDTH, height: RECT_HEIGHT)
        
        let rectView = UIView(frame: rect)
        rectView.backgroundColor = UIColor(hex: powerRanger.colourAsHex!)
        mapImage.addSubview(rectView)
    }
    
    // IBAction methods defined
    @IBAction func saveButtonTapped(_ sender: Any) {
        appDelegate.saveContext()
    }
    
    // NSController
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Accessing controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Accessing controllerDidChangeContent")
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("Accessing didChange")
        switch (type)
        {
        case.insert:
            if let indexPath = newIndexPath{
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            
        case.delete:
            if let indexPath = indexPath{
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case.move:
            if let indexPath = indexPath{
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let indexPath = newIndexPath{
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case.update:
            if let indexPath = indexPath{
                let cell = tableView.cellForRow(at: indexPath) as! PowerCell
                updateCell(cell: cell, indexPath: indexPath as NSIndexPath)
            }
        }
    }
    
    func updateCell(cell: PowerCell, indexPath: NSIndexPath){
        print("Accessing updateCell")
        let powercell = controller.object(at: indexPath as IndexPath)
        cell.configureCell(colour: powercell.colourAsHex!, id: powercell.id!, deployed: powercell.isDeployed)
    }
    
    // NSFetchResults
    
    func fetchData(){
        
        // Configure Fetch Request and Sort Descriptor
        // Important: Fetch Request must be assigned a SortDescriptor.
        
        let fetchRequest: NSFetchRequest<PowerRanger> = PowerRanger.fetchRequest()
        let colourSort = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [colourSort]
        
        // Configuring NSFetchedResultsController with Fetch Request
        // Important: Assigning controller. Without doing this, the program will crash and access a var controller that contains nil.
        
        let vController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller = vController
        
        
        // Retrieving Fetched Objects in Power Ranger Core Data
       
        do {
            try controller.performFetch()
            
            var fetchedObjects = controller.fetchedObjects
            
            if fetchedObjects?.count == 0 {
                print("Default Data creating")
                createDefaultData()
                fetchData()
            }else {
                print("Fetch Objects not nil")
                print(controller.fetchedObjects)
            }
        }catch{
            let error = error as NSError
            print(error)
        }
    }
    
    func createDefaultData(){
        let ranger1 = PowerRanger(context: context)
        ranger1.colourAsHex = "714493"
        ranger1.id = "Purple"
        ranger1.pointX = 0.0
        ranger1.pointY = 0.0
        ranger1.isDeployed = false
        
        let ranger2 = PowerRanger(context: context)
        ranger2.colourAsHex = "E98236"
        ranger2.id = "Orange"
        ranger2.pointX = 0.0
        ranger2.pointY = 0.0
        ranger2.isDeployed = false
        
        let ranger3 = PowerRanger(context: context)
        ranger3.colourAsHex = "E35C86"
        ranger3.id = "Pink"
        ranger3.pointX = 0.0
        ranger3.pointY = 0.0
        ranger3.isDeployed = false
        
        let ranger4 = PowerRanger(context: context)
        ranger4.colourAsHex = "82C7BC"
        ranger4.id = "Cyan"
        ranger4.pointX = 0.0
        ranger4.pointY = 0.0
        ranger4.isDeployed = false
        
        let ranger5 = PowerRanger(context: context)
        ranger5.colourAsHex = "327DA8"
        ranger5.id = "Blue"
        ranger5.pointX = 0.0
        ranger5.pointY = 0.0
        ranger5.isDeployed = false
        
        appDelegate.saveContext()
    }
}

