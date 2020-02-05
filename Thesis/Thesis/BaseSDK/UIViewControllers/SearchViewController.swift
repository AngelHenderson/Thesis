//
//  SearchViewController.swift

//
//  Created by Angel Henderson on 3/8/17.
//  Copyright © 2017 Angel Henderson Holding Corporation. All rights reserved.
//

import UIKit

import SwiftyJSON
import Alamofire
import SwifterSwift

extension SearchViewController {
    @objc func searchBarTextDidChange(searchBar: UISearchBar, searchText: String){}
}

class SearchViewController: BaseCollectionViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var recentSearchList: [String] = []
    let recentSearchKey = "\(AppCoreKit.bundleIdentifier).RecentSearch"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitle = "Search"
        navigationSubTitle = "Search"
        navigationView?.headerSetup(title: navigationTitle, subject: navigationSubTitle, image: navigationImageIcon)
        cacheSupport = false
        
        //self.searchBar.becomeFirstResponder()
        searchBar.enablesReturnKeyAutomatically = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        trackScreen(name: "Search View")
        
        navigationView?.titleLabel?.alpha = 0
        searchBar.textField?.textColor = .primaryTextColor
        searchBar.text = ""
        
        json = nil
        collectionView?.reloadData()
        
        if let recentSearchArray = getUserDefaultObject(key: recentSearchKey){
            recentSearchList = recentSearchArray as! [String]
            setUserDefault(object: recentSearchList, key: recentSearchKey)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }

    // MARK: - Search

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        trackEvent(category: "Search", value: 1)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
     @objc func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 3 {
            json = nil
            collectionView?.reloadData()
        }
        else { searchBarTextDidChange(searchBar: searchBar, searchText: searchText)}
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if json == nil {return 1}
        
        return self.numberOfSections(in: collectionView)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if json == nil {
            return recentSearchList.count != 0 ? recentSearchList.count + 1 : 0
        }
        
        return self.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Empty Json
        if json == nil {return recentCellConfiguration(indexPath: indexPath)}
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if json != nil {return cellSizeConfiguration(width: self.view.frame.size.width, height: 65)}
        if indexPath.row == 0 && self.view.frame.size.width == CommonKit.iPhoneXWidth {return CGSize(width: 724, height: 38)}
        return indexPath.row == 0 ? CGSize(width: self.view.frame.size.width, height: 38) : cellSizeConfiguration(width: self.view.frame.size.width, height: 38)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Call addToRecentSearch() on selected title
        if json == nil && indexPath.row != 0 {
            searchBar.text = recentSearchList[indexPath.row - 1].trimmed
            searchBar(searchBar, textDidChange: recentSearchList[indexPath.row - 1].trimmed)
        }
        //didSelectItemAt(collectionView: collectionView, indexPath: indexPath)
    }
    
 
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Please use addToRecentSearch()
    }
    
    // MARK: - Recent Search
    
    func addToRecentSearch(text:String){
        if let recentSearchArray = getUserDefaultObject(key: recentSearchKey){
            var searchArray = recentSearchArray as! [String]
            searchArray.prepend(text.trimmed)
            searchArray.removeDuplicates()
            searchArray = limitSearchArraySize(array: searchArray)
            setUserDefault(object: searchArray, key: recentSearchKey)
        }
        else {setUserDefault(object: [text], key: recentSearchKey)} //Create initial array
    }
    
    @IBAction func clearRecentSearch(){
        setUserDefault(object: [], key: recentSearchKey)
        recentSearchList = []
        collectionView?.reloadData()
        showTempAlert(title: "Recent Search cleared", subtitle: "Your recent search has successfully been cleared")
    }
    
    func limitSearchArraySize(array:[String]) -> [String]{
        var searchArray = array
        while searchArray.count > 10 {
            searchArray.popLast()
        }
        return searchArray
    }
    
    func recentCellConfiguration(indexPath:IndexPath) -> UICollectionViewCell{        
        switch indexPath.row {
        case 0:
            let cell: SectionHeaderCollectionViewCell = collectionView!.dequeueReusableCell(withReuseIdentifier: "RecentCollectionViewCellHeader", for: indexPath) as! SectionHeaderCollectionViewCell
            cell.titleLabel?.text = "Recent"
            cell.titleLabel?.textColor = .primaryTextColor
            cell.button?.tintColor = ColorKit.themeColor
            return cell
        default:
            let index = indexPath.row - 1
            let cell: SectionHeaderCollectionViewCell = collectionView!.dequeueReusableCell(withReuseIdentifier: "RecentCollectionViewCell", for: indexPath) as! SectionHeaderCollectionViewCell
            cell.titleLabel?.text = recentSearchList[index]
            cell.titleLabel?.textColor = ColorKit.themeColor
            return cell
        }
    }
}
