//
//  TaskListsViewController.swift
//  RealmTasks
//
//  Created by Nathan Lambson on 11/07/2017.
//  Copyright (c) 2014 Alan Skipp. All rights reserved.
//

import UIKit
import RealmSwift
import FTPopOverMenu_Swift

class TaskTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ASValueTrackingSliderDataSource {
    @IBOutlet weak var stressSlider: ASValueTrackingSlider!
    
    let emotions = ["😎","😁","😀","😐","🙁","😟","😔","😓","😰","😱"]
    internal var stressLevel: Float = 0
    var currentEmotionButton : UIButton?
    var lists : Results<TaskList>!
    var isEditingMode = false
    
    
    var currentCreateAction:UIAlertAction!
    @IBOutlet weak var taskListsTableView: UITableView!
    
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
        lists = uiRealm.objects(TaskList.self)
        self.taskListsTableView.setEditing(false, animated: true)
        self.taskListsTableView.reloadData()
    }
    
    // MARK: - User Actions -

    @IBAction func didSelectSortCriteria(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0{
            
            // A-Z
            self.lists = self.lists.sorted(byKeyPath: "name")
        }
        else{
            // date
            self.lists = self.lists.sorted(byKeyPath: "createdAt", ascending:false)
        }
        self.taskListsTableView.reloadData()
    }
    
    @IBAction func didClickOnEditButton(_ sender: UIBarButtonItem) {
        isEditingMode = !isEditingMode
        self.taskListsTableView.setEditing(isEditingMode, animated: true)
    }
    
    @IBAction func didClickOnAddButton(_ sender: UIBarButtonItem) {
        displayAlertToAddTaskList(nil)
    }
    
    //Enable the create action of the alert only if textfield text is not empty
    @objc func listNameFieldDidChange(_ textField:UITextField){
        self.currentCreateAction.isEnabled = (textField.text?.characters.count)! > 0
    }
    
    func displayAlertToAddTaskList(_ updatedList:TaskList!){
        
        var title = "New Tasks List"
        var doneTitle = "Create"
        if updatedList != nil{
            title = "Update Tasks List"
            doneTitle = "Update"
        }
        
        let alertController = UIAlertController(title: title, message: "Write the name of your tasks list.", preferredStyle: UIAlertControllerStyle.alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            
            let listName = alertController.textFields?.first?.text
            
            if updatedList != nil{
                // update mode
                try! uiRealm.write{
                    updatedList.name = listName!
                    self.readTasksAndUpdateUI()
                }
            }
            else{
                let newTaskList = TaskList()
                newTaskList.name = listName!
                
                try! uiRealm.write{
                    
                    uiRealm.add(newTaskList)
                    self.readTasksAndUpdateUI()
                }
            }
            
            print(listName ?? "")
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Task List Name"
            textField.addTarget(self, action: #selector(TaskTableViewController.listNameFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            if updatedList != nil{
                textField.text = updatedList.name
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
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
    
    // MARK: - UITableViewDataSource -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let listsTasks = lists{
            return listsTasks.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell")
        
        let list = lists[indexPath.row]
        
        cell?.textLabel?.text = list.name
        cell?.detailTextLabel?.text = "\(list.tasks.count) Tasks"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            
            //Deletion will go here
            
            let listToBeDeleted = self.lists[indexPath.row]
            try! uiRealm.write{
                
                uiRealm.delete(listToBeDeleted)
                self.readTasksAndUpdateUI()
            }
        }
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { (editAction, indexPath) -> Void in
            
            // Editing will go here
            let listToBeUpdated = self.lists[indexPath.row]
            self.displayAlertToAddTaskList(listToBeUpdated)
            
        }
        return [deleteAction, editAction]
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "openTasks", sender: self.lists[indexPath.row])
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let tasksViewController = segue.destination as! TasksViewController
        tasksViewController.selectedList = sender as! TaskList
    }

}

