//
//  InfoTableViewController.swift
//  WBikes
//
//  Created by Diego on 21/10/2020.
//

import UIKit
import MessageUI

class InfoTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var selectCityCell: UITableViewCell!
    var city: City!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBarController = self.tabBarController as! TabBarViewController
        self.city = tabBarController.city
        selectCityCell.detailTextLabel?.text = city.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let cell = tableView.cellForRow(at: indexPath), let identifier = cell.reuseIdentifier {
                switch identifier {
                case "ContactMeCell":
                    if !MFMailComposeViewController.canSendMail() {
                        sendAlert(title: "Error", message: "Mail services are not available")
                        return
                    }
                    let composeVC = MFMailComposeViewController()
                    composeVC.mailComposeDelegate = self
                    composeVC.setToRecipients(["dgsmartstudio@gmail.com"])
                    composeVC.setSubject("Support")
                    self.present(composeVC, animated: true, completion: nil)
                case "PrivacyPolicyCell":
                    loadWebController(url: Bundle.main.path(forResource: "privacyPolicy", ofType: "html")!)
                case "TemsCell":
                    loadWebController(url: Bundle.main.path(forResource: "terms", ofType: "html")!)

                case "AboutCell":
                    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

                    sendAlert(title: "About", message: "Made with ♥️ by Diego Gl\nVersion \(appVersion)")
                default: return
                }
            }
    }
    
    fileprivate func loadWebController(url: String) {
        let webViewController = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.htmlFile = url
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    fileprivate func sendAlert(title: String, message: String ){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {

        controller.dismiss(animated: true, completion: nil)
    }

}
