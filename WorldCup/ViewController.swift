//
//  ViewController.swift
//  WorldCup
//
//  Created by Pietro Rea on 8/2/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, NSFetchedResultsControllerDelegate {
  
  var coreDataStack: CoreDataStack!
    
  var fetchedResultsController: NSFetchedResultsController!
    
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var addButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let fetchRequest = NSFetchRequest(entityName: "Team")
    
    let zoneDescriptor = NSSortDescriptor(key: "qualifyingZone", ascending: true)
    let winsDescriptor = NSSortDescriptor(key: "wins", ascending: false)
    let nameDescriptor = NSSortDescriptor(key: "teamName", ascending: true)
    
    fetchRequest.sortDescriptors = [ zoneDescriptor,  winsDescriptor, nameDescriptor]
    
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.context, sectionNameKeyPath: "qualifyingZone", cacheName: "worldcup")
    fetchedResultsController.delegate = self
    
    do
    {
       try fetchedResultsController.performFetch()
    } catch
    {
        print("error")
    }
   
    
  }
  
  func numberOfSectionsInTableView
    (tableView: UITableView) -> Int {
      
      return fetchedResultsController.sections!.count
  }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        
        return sectionInfo.name
    }
    
func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      
      let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        
      return sectionInfo.numberOfObjects
  }
    
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
      let resuseIdentifier = "teamCellReuseIdentifier"
      
      let cell = tableView.dequeueReusableCellWithIdentifier(
        resuseIdentifier, forIndexPath: indexPath)
        as! TeamCell
      
      configureCell(cell, indexPath: indexPath)
      
      return cell
  }

  
  
  func configureCell(cell: TeamCell, indexPath: NSIndexPath) {
    let team = fetchedResultsController.objectAtIndexPath(indexPath) as! Team
    
    cell.flagImageView.image = UIImage(named: team.imageName)
    cell.teamLabel.text = team.teamName
    cell.scoreLabel.text = "Wins: \(team.wins)"
    
  }
  
    
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let team = fetchedResultsController.objectAtIndexPath(indexPath) as! Team
    
    let wins = team.wins.integerValue
    
    team.wins = NSNumber(integer: wins+1)
    
    do
    {
     try! coreDataStack.context.save()
    }
    tableView.reloadData()
      
  }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
   func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Delete:
           tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as! TeamCell
                configureCell(cell, indexPath: indexPath!)
        case .Move: tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic) tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic) default:
            break
        }
    }
   
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    
}

