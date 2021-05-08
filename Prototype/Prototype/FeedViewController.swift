//
//  FeedViewController.swift
//  Prototype
//
//  Created by Mayowa Olunuga on 08/05/2021.
//

import UIKit

class FeedViewController : UITableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "FeedImageCell")!
    }
}
