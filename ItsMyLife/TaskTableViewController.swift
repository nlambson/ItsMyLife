//
//  TaskTableViewController.swift
//  ItsMyLife
//
//  Created by Nathan Lambson on 11/07/2017.
//  Copyright (c) 2017 Nathan Lambson. All rights reserved.
//

import UIKit
import FTPopOverMenu_Swift
import CoreData

class TaskTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ASValueTrackingSliderDataSource {
    
    @IBOutlet weak var stressSlider: ASValueTrackingSlider!
    
    let emotions = ["😎","😁","😀","😐","🙁","😟","😔","😓","😰","😱"]
    internal var stressLevel: Float = 0
    var currentEmotionButton : UIButton?
    var tasks: [NSManagedObject] = []
    var isEditingMode = false
    
    
    var currentCreateAction:UIAlertAction!
    @IBOutlet weak var tasksTableView: UITableView!
    
    @objc func clickOnButton(button: UIButton) {
        //Dont do anything right now
    }
    
    func setButtonTitle(index: Int) {
        if currentEmotionButton != nil {
            currentEmotionButton?.setTitle(emotions[index], for: .normal)
        } else {
            currentEmotionButton = UIButton(type: .custom)
            currentEmotionButton?.titleLabel?.font = UIFont.systemFont(ofSize: 30.0)
            currentEmotionButton?.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
            currentEmotionButton?.setTitle(emotions[0], for: .normal)
            currentEmotionButton?.addTarget(self, action: #selector(self.clickOnButton), for: .touchUpInside)
            self.navigationItem.titleView = currentEmotionButton
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureFTPopOverMenu()
        self.setButtonTitle(index: 0)
        
        stressSlider.dataSource = self
        stressSlider.setValue(stressLevel, animated: false)
        stressSlider.popUpViewCornerRadius = 12.0
        stressSlider.setMaxFractionDigitsDisplayed(0)
        stressSlider.font = UIFont.init(name: "GillSans-Bold", size: 28)
        stressSlider.popUpViewAnimatedColors = [UIColor.blue, UIColor.red]
        stressSlider.autoAdjustTrackColor = true
        stressSlider.minimumTrackTintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        readTasksAndUpdateUI()
    }
    
    func readTasksAndUpdateUI(){
//        lists = uiRealm.objects(TaskList.self)
        self.tasksTableView.setEditing(false, animated: true)
        self.tasksTableView.reloadData()
    }
    
    // MARK: - User Actions -

    @IBAction func didSelectSortCriteria(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0{
            
            // A-Z
//            self.lists = self.lists.sorted(byKeyPath: "name")
        }
        else{
            // date
//            self.lists = self.lists.sorted(byKeyPath: "createdAt", ascending:false)
        }
        self.tasksTableView.reloadData()
    }
    
    @IBAction func didClickOnEditButton(_ sender: UIBarButtonItem) {
        isEditingMode = !isEditingMode
        self.tasksTableView.setEditing(isEditingMode, animated: true)
    }
    
    @IBAction func didClickOnAddButton(_ sender: UIBarButtonItem) {
        displayAlertToAddTask(nil)
    }
    
    //Enable the create action of the alert only if textfield text is not empty
    @objc func taskNameFieldDidChange(_ textField:UITextField){
        self.currentCreateAction.isEnabled = (textField.text?.count)! > 0
    }
    
    func displayAlertToAddTask(_ updatedTask:Task?){

        var title = "New Task"
        var doneTitle = "Create"
        
        
        if let _ = updatedTask {
            title = "Update Task"
            doneTitle = "Update"
        }

        let alertController = UIAlertController(title: title, message: "Write the name of your task.", preferredStyle: UIAlertControllerStyle.alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            guard let textField = alertController.textFields?.first, let taskNameToSave = textField.text else {
                return
            }

            self.save(name: taskNameToSave)
            self.tasksTableView.reloadData()
    

            print(taskNameToSave)
        }

        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction

        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))

        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Task Name"
            textField.addTarget(self, action: #selector(TaskTableViewController.taskNameFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            if let taskExists = updatedTask {
                textField.text = taskExists.name
            }
        }

        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //TODO Nathan, appears to create a new task... it might update a preexisting task? doesn't look like it searches for it.
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext)!
        
        let task = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // 3
        task.setValue(name, forKeyPath: "name")
        
        // 4
        do {
            try managedContext.save()
            tasks.append(task)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - FTPopOverMenu
    
    func configureFTPopOverMenu() {
        let configuration = FTConfiguration.shared
        configuration.menuRowHeight = 40.0
        configuration.menuWidth = 40.0
        configuration.textFont = UIFont.systemFont(ofSize: 25.0)
        configuration.textAlignment = NSTextAlignment.center
    }
    
    // MARK: - ASValueTrackingSlider datasource
    
    @objc func onSliderValueChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                print("began")
                break
            // handle drag began
            case .moved:
                print("moved")
                break
            // handle drag moved
            case .ended:
                print("ended")
                break
            // handle drag ended
            default:
                break
            }
        }
    }
    
    func slider(_ slider: ASValueTrackingSlider!, stringForValue value: Float) -> String! {
        let value = Int(ceil(value))

        readTasksAndUpdateUI()
        setButtonTitle(index: value)
        //TODO Nathan update this ^ to take the filter value from the slider

        return emotions[value]
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == 0) {
            return 4
        }
        
        return 8
//        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {

//        let task = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        
//        cell.textLabel?.text = task.value(forKeyPath: "name") as? String
//        cell.detailTextLabel?.text = task.value(forKeyPath: "notes") as? String
        
        if (indexPath.section == 0) {
            cell.textLabel?.text = "Open Task"
            cell.detailTextLabel?.text = "Open Task Description"
        } else {
            cell.textLabel?.text = "Completed Task"
            cell.detailTextLabel?.text = "Completed Task Description"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let taskToBeDeleted = self.tasks[indexPath.row]
            
            do {
                //Remove object from core data
                let managedContext = appDelegate.persistentContainer.viewContext
                managedContext.delete(taskToBeDeleted as NSManagedObject)
                try managedContext.save()
                
                //update UI methods
                tableView.beginUpdates()
                self.tasks.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
                
                appDelegate.saveContext()
            } catch let err as NSError {
                print(err)
                
            }
            
        }
        
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { (editAction, indexPath) -> Void in
//            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//                return
//            }
            
            // Editing will go here
            let taskToBeUpdated = self.tasks[indexPath.row]
            self.displayAlertToAddTask(taskToBeUpdated as! Task)
        }
    
        return [deleteAction, editAction]
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        self.performSegue(withIdentifier: "openTasks", sender: self.lists[indexPath.row])
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let tasksViewController = segue.destination as! TasksViewController
//        tasksViewController.selectedTask = sender as! Task
    }

}

