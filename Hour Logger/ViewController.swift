//
//  ViewController.swift
//  Hour Logger
//
//  Created by Ankur Dahal on 7/5/21.
//

import Cocoa

class ViewController: NSViewController {


    @IBOutlet weak var start_time: NSDatePicker!
    @IBOutlet weak var end_time: NSDatePicker!
    @IBOutlet weak var work_description: NSTextField!
    private let filename : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("hours.csv")
    private let SECONDS_IN_HOUR : Double = 60 * 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    
    @IBAction func saveHours(_ sender: Any) {
        // add -9:45 to make it EST
        let start_date_string = start_time.dateValue.addingTimeInterval(-35100)
        let end_date_string = end_time.dateValue.addingTimeInterval(-35100)
        
        if (start_date_string > end_date_string) {
            showAlert(alert: createAlert(msg: "Error", button: "OK", style: "critical", info: "Check that the end date is after the start date"), message: "Data not saved.")
        } else {
            // valid date entered
            showAlert(alert: createAlert(msg: "Saved!", button: "OK", style: "info", info: ""), message: "Saved successfully.")
            
            // save the data to csv file
            saveToCsv(work_description: work_description.stringValue, start_d: start_date_string, end_d: end_date_string, hours_worked: hoursWorked(start: start_date_string, end: end_date_string))
        }
    }
    
    
    // returns -1 if invalid date is supplied
    func hoursWorked(start: Date, end: Date) -> String  {
        return String(format: "%.3f", end.timeIntervalSince(start) / SECONDS_IN_HOUR)
    }
    
    
    
    func saveToCsv(work_description : String, start_d : Date, end_d : Date, hours_worked : String) -> Void {
        let formatted_start = formatDate(date: start_d)
        let formatted_end = formatDate(date: end_d)
        let data = "\(work_description),\(formatted_start),\(formatted_end),\(hours_worked)\n"
        
        if fileDoesExist(file: filename.path) {
            // File already exists, so append to the already-existing data
            do {
                let fileHandle = try FileHandle(forWritingTo: filename)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data.data(using: .utf8)!)
                fileHandle.closeFile()
            } catch {
                print("ERROR: Cannot write to file: \(error)")
            }
        } else {
            // File does not exist, write the headers first
            do {
                var headers : String = "Description,Start Time,End Time,Hours Worked\n"
                headers.append(data)
                try headers.write(to: filename, atomically: true, encoding: .utf8)
            } catch {
                print("ERROR: Cannot write to file: \(error)")
            }
        }
    }
    
    
    func formatDate(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "MMM d HH:mm"
        return dateFormatter.string(from: date)
    }
    
    
    func fileDoesExist(file : String) -> Bool {
        return FileManager.default.fileExists(atPath: file)
    }
    
    
    func createAlert(msg : String, button : String, style : String, info : String) -> NSAlert {
        let alert = NSAlert()
        alert.messageText = msg
        alert.informativeText = info
        alert.addButton(withTitle: button)
        if (style == "info") {
            alert.alertStyle = .informational
        } else {
            alert.alertStyle = .critical
        }
        return alert
    }
    
    
    func showAlert(alert : NSAlert, message : String) -> Void {
        var w: NSWindow?
        if let window = view.window{
            w = window
        }
        else if let window = NSApplication.shared.windows.first{
            w = window
        }
        if let window = w{
            alert.beginSheetModal(for: window){ (modalResponse) in
                if modalResponse == .alertFirstButtonReturn {
                    print(message)
                }
            }
        }
    }
    
    
    @IBAction func viewHours(_ sender: Any) {
        if fileDoesExist(file: filename.path) {
            // file exists, so open the csv file for the user to view
            NSWorkspace.shared.open(filename)
        } else {
            // file does not exist, so show an alert
            showAlert(alert: createAlert(msg: "File Does Not Exist", button: "Got It", style: "critical", info: "There are no stored records found. Please add your hours to start logging."), message: "Done.")
        }
    }
    
    func deleteFile() -> Void {
        do {
            let file_manager = FileManager()
            try file_manager.removeItem(at: filename)
        } catch {
            print("ERROR: Cannot delete file: \(error)")
        }
        print("Deleted")
    }
    
    @IBAction func deleteHours(_ sender: Any) {
        let alert = NSAlert()
        alert.messageText = "Confirm Delete?"
        alert.informativeText = "Are you sure you want to delete all logged hours?"
        alert.addButton(withTitle: "Confirm")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .critical
        var w: NSWindow?
        if let window = view.window{
            w = window
        }
        else if let window = NSApplication.shared.windows.first{
            w = window
        }
        if let window = w{
            alert.beginSheetModal(for: window){ (modalResponse) in
                if modalResponse == .alertFirstButtonReturn {
                    // confirm delete the records
                    if self.fileDoesExist(file: self.filename.path) {
                        self.deleteFile()
                    }
                } else if modalResponse == .alertSecondButtonReturn {
                    print("Canceled")
                }
            }
        }

    }
    
    
}

