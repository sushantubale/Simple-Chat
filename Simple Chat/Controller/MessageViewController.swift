//
//  MessageViewController.swift
//  Simple Chat
//
//  Created by Sushant Ubale on 12/13/18.
//  Copyright © 2018 Sushant Ubale. All rights reserved.
//

import UIKit
import Firebase

class MessageViewController: UITableViewController {

    static let cellId = "cell"
    var users = [Users]()
    var imageCache: NSCache<AnyObject,AnyObject>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: MessageViewController.cellId)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        
        fetchUsers()
    }

    func fetchUsers() {
        
        Database.database().reference().child("users").observe(.childAdded, with: { [weak self] (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                let user = Users()
                user.setValuesForKeys(dictionary)
                self?.users.append(user)
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
            
        }, withCancel: nil)
    }
    
    @objc func cancelTapped() {
        
        dismiss(animated: true, completion: nil)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageViewController.cellId, for: indexPath) as? UserCell
        
        if let cell1 = cell {
            let user = users[indexPath.row]
            cell1.textLabel?.text = user.name
            cell1.detailTextLabel?.text = user.email
            
            if let profileImageURL = user.imageurl {
                
                self.loadProfileImage(profileImageURL, cell1, tableView)
            }
            return cell1

        }
        return cell!
    }
    
    
    private func loadProfileImage(_ url: String,_ cell: UserCell,_ tableviewObject: UITableView) {
        
        self.imageCache = nil
        if let imageCache = imageCache {
            if let imageCached = imageCache.object(forKey: url as AnyObject) as? UIImage  {
                cell.profileImageView.image = imageCached
                return
            }
        }

        
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil  {
                    print("Error getting the profile image")
                    return
                }
                
                if let data = data {
                    DispatchQueue.main.async {
                    
                        if let downloadedImage = UIImage(data: data) {
                            self.imageCache?.setValue(downloadedImage, forKey: url.absoluteString)
                            cell.profileImageView.image = UIImage(data: data)

                        }
                        //tableviewObject.reloadData()
                        
                    }
                }
                }.resume()
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


class UserCell: UITableViewCell {
    
    var profileImageView: UIImageView = {
    let imageView = UIImageView()
        imageView.image = UIImage(named: "")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let textLabel = textLabel, let detailTextLabel = detailTextLabel {
            textLabel.frame = CGRect(x: 76, y: textLabel.frame.origin.y - 2, width: textLabel.frame.width, height: textLabel.frame.height)
            detailTextLabel.frame = CGRect(x: 76, y: detailTextLabel.frame.origin.y + 2, width: detailTextLabel.frame.width, height: detailTextLabel.frame.height)
            
            textLabel.font = UIFont.boldSystemFont(ofSize: 16)
            detailTextLabel.font = UIFont.boldSystemFont(ofSize: 16)
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

