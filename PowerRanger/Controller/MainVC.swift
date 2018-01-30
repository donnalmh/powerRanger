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

    //
    // Variables
    //
    
    @IBOutlet weak var mapImage: UIView!
    @IBOutlet weak var tableView: UITableView!
    var controller: NSFetchedResultsController<PowerRanger>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        mapImage.alpha = 0.0
        UIView.animate(withDuration: 1.5, delay: 0.4, options: .allowAnimatedContent, animations: {
            self.mapImage.alpha = 1.0
        }, completion: nil)
        
        fetchData()
        controller.delegate = self
        tableView.reloadData()
        self.view.layoutIfNeeded()
    }
    
    //----------------------- UITableViewDataSource Methods ----------------------------- //
    //
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    //----------------------- UITableViewDelegate Methods ----------------------------- //
    //
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){

        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = UITableViewCellSelectionStyle.none

        let powerCell = controller.object(at: indexPath as IndexPath)
        powerCell.setDeployed()
        
        updateMap(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    // ----------------------- Update Methods ----------------------------- //
    // UITableViewCell: Rect Colour and Labels
    // UIView Map: Display Power Rangers that are indicated as deployed
    //
    
    func updateCell(cell: PowerCell, indexPath: NSIndexPath){
        let powerCell = controller.object(at: indexPath as IndexPath)
        cell.configureCell(colour: powerCell.colourAsHex!, id: powerCell.id!, deployed: powerCell.isDeployed)
    }
    
    func updateMap(indexPath: IndexPath){
        let powerRanger = controller.object(at: indexPath)
        if(powerRanger.isDeployed){
            drawRect(powerRanger: powerRanger)
        }
    }
    
    func drawRect(powerRanger: PowerRanger){
        
        var x =  powerRanger.pointX
        var y = powerRanger.pointY
 
        if(!powerRanger.hasBeenInitialised )
        {
            x = mapImage.frame.width/2 - RECT_OFFSET
            y = mapImage.frame.height/2 - RECT_OFFSET
            
            powerRanger.hasBeenInitialised = true
        }else{
            x =  powerRanger.pointX
            y = powerRanger.pointY
        }
    
        let rect = CGRect(x: x, y: y, width: 1.0, height: 1.0)
        let powerRect = PowerRect(frame: rect, powerRanger: powerRanger)
        powerRect.alpha = 0.0
        
        UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveEaseInOut, animations: {
            powerRect.alpha = 1.0
            powerRect.frame.size.height = RECT_WIDTH + 5
            powerRect.frame.size.width = RECT_WIDTH + 5
        }, completion: nil)
        
        UIView.animate(withDuration: 0.35, delay: 0.35, options: .curveEaseOut , animations: {
            powerRect.frame.size.height = RECT_WIDTH
            powerRect.frame.size.width = RECT_WIDTH
        }, completion: nil)
        
        mapImage.addSubview(powerRect)
        addPanGesture(powerRect: powerRect)
    }
    // Adding Pan Gesture
    func addPanGesture(powerRect: PowerRect){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(sender:)))
        powerRect.addGestureRecognizer(pan)
        pan.delegate = self
    }
    
    // Determine whether current value is on min or max bound
    func closerTo(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat{
        let value = (fabs(value - min) < fabs(value-max)) ? min : max
        return value
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer){
        print("Handling Pan Gesture")
        
        let rangerView: PowerRect = sender.view as! PowerRect
        let rangerCenter = rangerView.center
        let mapCenter = mapImage.center
        let mapHalfWidth = mapImage.frame.width/2
        
        // margin represents distance between rangerView's center point and map edge upon contact
        let margin = RECT_WIDTH/2
        let maxXYRange: CGFloat = mapHalfWidth - margin
        
        var transX = sender.translation(in: mapImage).x
        var transY = sender.translation(in: mapImage).y
        
        // min and max represent the range bounds [-min, -max] in mapImage's XY Coordinate Systems
        let min = mapCenter.x - maxXYRange
        let max = mapCenter.x + maxXYRange
        
        switch sender.state{
        case .began, .changed:
            
            // 1A) Check to see if user attempts to move Power Ranger out of [min, max] x-range
            if (rangerCenter.x >= max || rangerCenter.x <= min )
            {
                // Checks to see if Power Ranger is on the min-bound or max-bound
                let xBound: CGFloat = closerTo(value: rangerCenter.x, min: min, max: max)
                if( xBound == max )
                {
                    // If x-translation will cause Power Ranger's position to exceed x-range,
                    // set Ranger's x-position to min or max. Else, Power Ranger is allowed to remain and
                    // move within range
                    if( transX > 0 )
                    {
                        rangerView.center.x = xBound
                    }else{
                        rangerView.center.x += transX
                    }
                }else if( xBound == min )
                {
                    if( transX < 0 )
                    {
                        rangerView.center.x = xBound
                    }else{
                        rangerView.center.x += transX
                    }
                }
            } // End of Check 1A)
            
            // 1B) Check to see if user attempts to move Power Ranger out of [min, max] y-range
            if (rangerCenter.y >= max || rangerCenter.y <= min )
            {
                // Checks to see if Power Ranger is on the min-bound or max-bound
                let yBound: CGFloat = closerTo(value: rangerCenter.y, min: min, max: max)
                if( yBound == max )
                {
                    // If y-translation will cause Power Ranger's position to exceed y-range,
                    // set Ranger's y-position to min or max. Else, Power Ranger is allowed to remain and
                    // move within range
                    if( transY > 0 )
                    {
                        rangerView.center.y =  max
                    }else{
                        rangerView.center.y += transY
                    }
                }else{
                    if( transY < 0 )
                    {
                        rangerView.center.y =  min
                    }else{
                        rangerView.center.y += transY
                    }
                }
            } // End of Check 1B)
            
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
            rangerView.powerRanger.pointX = rangerView.frame.minX
            rangerView.powerRanger.pointY = rangerView.frame.minY
        case .cancelled:
            return
        case .failed:
            return
        }
    }
    
    // ----------------------- Save Methods ----------------------------- //
    @IBAction func saveButtonTapped(_ sender: Any) {
        appDelegate.saveContext()
        print("Saved context!")
    }

    // ----------------------- NSController Methods ----------------------------- //
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
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
        case.update:
            if let indexPath = indexPath{
                let cell = tableView.cellForRow(at: indexPath) as! PowerCell
                updateCell(cell: cell, indexPath: indexPath as NSIndexPath)
            }
        case.delete:
            return
        case.move:
            return
        }
    }
    
    // ----------------------- NSFetchResults Methods ----------------------------- //
    
    func fetchData(){
        
        let fetchRequest: NSFetchRequest<PowerRanger> = PowerRanger.fetchRequest()
        let colourSort = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [colourSort]

        let vController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        controller = vController
        
        do {
            try controller.performFetch()
            
            let fetchedObjects = controller.fetchedObjects
            
            if fetchedObjects?.count == 0 {
                createDefaultData()
                fetchData()
            }else {
                print(controller.fetchedObjects as Any)
            }
        }catch{
            let error = error as NSError
            print(error)
        }
    }
    
    func createDefaultData(){
        
        for i in 0..<5{
            let ranger = PowerRanger(context: context)
            ranger.colourAsHex = rangerColourArray[i]
            ranger.id = rangerColourNameArray[i]
            ranger.pointX = 0.0
            ranger.pointY = 0.0
            ranger.isDeployed = false
            ranger.hasBeenInitialised = false
        }
        appDelegate.saveContext()
    }
}

