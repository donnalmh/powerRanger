//
//  ViewController.swift
//  PowerRanger
//
//  Created by Donna Samuel on 27/1/18.
//  Copyright © 2018 donnali. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate {

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PowerCell", for: indexPath) as! PowerCell
        
        // Updates Table View Cell and Draws Rectangles in Map accordingly
        // Note: Would be better to update Map somewhere else, but put here for time being
        // to leverage on indexPath
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        // Grey out cell and render unselectable
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = UITableViewCellSelectionStyle.none

        // Updating Power Ranger's isDeployed BOOL var
        let powerCell = controller.object(at: indexPath as IndexPath)
        powerCell.deployed()
        
        // Update Map after User interacts with Table
        updateMap(indexPath: indexPath)
    }
    
    // Update Methods
    
    // Update Cell Rect Colour and Labels
    func updateCell(cell: PowerCell, indexPath: NSIndexPath){
        let powerCell = controller.object(at: indexPath as IndexPath)
        cell.configureCell(colour: powerCell.colourAsHex!, id: powerCell.id!, deployed: powerCell.isDeployed)
    }
    
    // Update Map : Draw UIViews to represent any deployed rangers
    func updateMap(indexPath: IndexPath){
        let powerRanger = controller.object(at: indexPath)
        if(powerRanger.isDeployed){
            drawRect(powerRanger: powerRanger)
        }
    }
    
    // Sub-method from Update Map to draw subview UIView with frame CGRect and added to main UIView mapImage
    func drawRect(powerRanger: PowerRanger){
        // If is a new Rectangle
        var centerX =  powerRanger.pointX  - /2
        var centerY = powerRanger.pointY - RECT_HEIGHT/2
        if(centerX == 0.0 && centerY == 0.0)
        {
            centerX = mapImage.frame.width/2 - /2
            centerY = mapImage.frame.height/2 - RECT_HEIGHT/2
        }
        var rect = CGRect(x: centerX, y: centerY, width: , height: RECT_HEIGHT)
        var powerRect = PowerRect(frame: rect, powerRanger: powerRanger)
        powerRect.backgroundColor = UIColor(hex: powerRanger.colourAsHex!)
        mapImage.addSubview(powerRect)
        addPanGesture(powerRect: powerRect)
        
    }
    
    // IBAction methods defined
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        appDelegate.saveContext()
        print("Saved context!")
    }
    
    // Adding Pan Gesture
    func addPanGesture(powerRect: PowerRect){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(sender:)))
        powerRect.addGestureRecognizer(pan)
        pan.delegate = self
        
    }
    
    func closerTo(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat{
        if fabs(value - min) < fabs(value-max)
        {
            print("difference: ",value - min)
            return min
        }else
        {
            return max
        }
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer){
        print("Handling Pan Gesture")
        // Want to redraw new location of rectangle according to location of touch
        // When finger releases, new location of view gets updated, and update point x and Y of power ranger
        
        let rangerView: PowerRect = sender.view as! PowerRect
        print("Current power Ranger selected:\(rangerView.powerRanger.id)")
      
        let mapCenter = mapImage.center
        let mapHalfWidth = mapImage.frame.width/2
        var rangerCenter = rangerView.center
        
        let margin = /2
        let maxXYRange: CGFloat = mapHalfWidth - margin
        print("margin:\(margin)")
        print("mapHalfWidth:\(mapHalfWidth)")
        
        var translation = sender.translation(in: mapImage)
        var transX = translation.x
        var transY = translation.y
        
        // Check to see that ranger is within XY bounds of map
        // For X Coordinates
        
        let min = mapCenter.x - maxXYRange
        let max = mapCenter.x + maxXYRange

        switch sender.state{
        case .began, .changed:
            
            if (rangerCenter.x >= max || rangerCenter.x <= min )
            {
                var xBound: CGFloat = closerTo(value: rangerCenter.x, min: min, max: max)
                if( xBound == max )
                {
                    print("Closer to max X")
                    if( transX > 0 )
                    {
                        rangerView.center = CGPoint(x: max, y: rangerView.center.y)
                    }else{
                        rangerView.center = CGPoint(x: max + transX, y: rangerView.center.y )
                    }
                }else{
                    print("Closer to min Y")
                    if( transX < 0 )
                    {
                        rangerView.center = CGPoint(x: min, y: rangerView.center.y )
                    }else{
                        rangerView.center = CGPoint(x: min + transX, y: rangerView.center.y)
                    }
                }
            }
            
            //  Checking within Ybounds
            if (rangerCenter.y >= max || rangerCenter.y <= min )
            {
                var yBound: CGFloat = closerTo(value: rangerCenter.y, min: min, max: max)
                
                if( yBound == max )
                {
                    print("Closer to max Y")
                    if( transY > 0 )
                    {
                        rangerView.center = CGPoint(x: rangerView.center.x, y: max)
                    }else{
                        rangerView.center = CGPoint(x: rangerView.center.x, y: max + transY)
                    }
                }else{
                    print("Closer to min Y")
                    if( transY < 0 )
                    {
                        rangerView.center = CGPoint(x: rangerView.center.x + transX, y: min)
                    }else{
                        rangerView.center = CGPoint(x: rangerView.center.x + transX, y: min + transY)
                    }
                }
            }
            
            if(rangerCenter.x < max && rangerCenter.x >= min && rangerCenter.y < max && rangerCenter.y >= min )
            {
                rangerView.center = CGPoint(x: rangerView.center.x + transX, y: rangerView.center.y + transY)
            }
            
            sender.setTranslation(CGPoint.zero, in: mapImage)
            
        case .possible:
            return
        case .ended:
            transX = 0
            transY = 0
            rangerView.powerRanger.pointX = rangerView.center.x
            rangerView.powerRanger.pointY = rangerView.center.y
            
        case .cancelled:
            return
        case .failed:
            return
        }
    
        
    }

    
    // NSController
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Accessing controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
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
    
    // Implementing Touches
}

