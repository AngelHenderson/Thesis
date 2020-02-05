//
//  AppIndexingKit.swift

//
//  Created by Angel Henderson on 9/26/17.
//  Copyright © 2018 Angel Henderson. All rights reserved.
//

import Foundation
import CoreSpotlight
import MobileCoreServices
import Alamofire
import AlamofireImage


//Documentation: https://developer.apple.com/library/content/documentation/General/Conceptual/AppSearch/AppContent.html
//https://developer.apple.com/library/content/documentation/General/Conceptual/AppSearch/index.html#//apple_ref/doc/uid/TP40016308-CH4-SW1
//https://www.appsfoundation.com/post/ios-9-search-api-core-spotlight

//MARK: -  NSUSERACTIVITY FRAMEWORK
//NSUserActivity



//MARK: - CORE SPOTLIGHT API
//The Core Spotlight framework provides APIs that help you add app-specific content to the on-device index and enable deep links into your app.
//Core Spotlight does not require users to visit the content in order to index it.
//In addition, you can use CoreSpotlight APIs to index content at any point, such as when the app loads.
//Note that Core Spotlight helps you make items searchable in the private on-device index; you don’t use Core Spotlight APIs to make items publicly searchable.

//MARK: Add To Core Spotlight

//Creating a searchable item and adding it to the on-device index

struct CoreSpotlight {
    static var spotlightArray:[String] = []
    
    enum ArrayError: Error {
        case arrayNotSet
    }
    
    static func setSpotlightArray() throws{
        setUserDefault(object: spotlightArray, key: "spotlightArray")
        throw ArrayError.arrayNotSet

    }
    static func getSpotlightArray(){
        guard let coreArray: [String] = getUserDefaultObject(key: "spotlightArray") as? [String] else {return}
        //print("iCloud pulled \(coreArray)")
        spotlightArray = coreArray

    }
    static func eraseSpotlightArray(){setUserDefault(object: [], key: "spotlightArray")}

    static func AddItemToCoreSpotlight(title:String, contentDescription:String?, uniqueIdentifier:String?){
        // Create an attribute set to describe an item.
        guard let content = contentDescription else {return}
        guard let uniqueIdentifier = uniqueIdentifier else {return}

        //Check is Identifier already exists
        guard CoreSpotlight.spotlightArray.contains(uniqueIdentifier) == false else {return}
        
        let attributeSet = createAttributeSetContent(title: title, contentDescription: content)
        // Create an item with a unique identifier, a domain identifier (website), and the attribute set you created earlier.
        let item = CSSearchableItem(uniqueIdentifier: uniqueIdentifier, domainIdentifier: AppCoreKit.bundleIdentifier, attributeSet: attributeSet)
        
        // Add the item to the on-device index.
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error { print("Add error: \(error.localizedDescription)")}
            else {print("Search item successfully indexed \(uniqueIdentifier)")
                CoreSpotlight.spotlightArray.append(uniqueIdentifier)
                //setSpotlightArray()
                
                do{try setSpotlightArray()}
                catch let error {print("Error: \(error)")}
            }
        }
    }
    
    static func AddItemToCoreSpotlight(title:String, contentDescription:String?, image:UIImage?, uniqueIdentifier:String?){
        guard let content = contentDescription else {return}
        guard let thumbnailImage = image else {return}
        guard let uniqueIdentifier = uniqueIdentifier else {return}
        
        //Check is Identifier already exists
        guard CoreSpotlight.spotlightArray.contains(uniqueIdentifier) == false else {return}
        
        let attributeSet = createAttributeSetContent(title: title, contentDescription: content, thumbnailData: thumbnailImage.pngData()!)
        let item = CSSearchableItem(uniqueIdentifier: uniqueIdentifier, domainIdentifier: AppCoreKit.bundleIdentifier, attributeSet: attributeSet)
        
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error { print("Add error: \(error.localizedDescription)")}
            else {print("Search item successfully indexed \(uniqueIdentifier)")
                CoreSpotlight.spotlightArray.append(uniqueIdentifier)
                
                do{try setSpotlightArray()}
                catch let error {print("Error: \(error)")}
            }
        }
    }
    
    static func AddItemToCoreSpotlight(title:String, contentDescription:String?, imageUrl:String?, uniqueIdentifier:String?){
        guard let content = contentDescription else {return}
        guard let thumbnailImageUrl = imageUrl else {return}
        guard let uniqueIdentifier = uniqueIdentifier else {return}

        //Check is Identifier already exists
        guard CoreSpotlight.spotlightArray.contains(uniqueIdentifier) == false else {return}
        
        Alamofire.request(thumbnailImageUrl).responseImage { response in
            if let image = response.result.value {
                let attributeSet = createAttributeSetContent(title: title, contentDescription: content, thumbnailData: image.pngData()!)
                let item = CSSearchableItem(uniqueIdentifier: uniqueIdentifier, domainIdentifier: AppCoreKit.bundleIdentifier, attributeSet: attributeSet)
                
                CSSearchableIndex.default().indexSearchableItems([item]) { error in
                    if let error = error { print("Add error: \(error.localizedDescription)")}
                    else {print("Search item successfully indexed \(uniqueIdentifier)")
                        CoreSpotlight.spotlightArray.append(uniqueIdentifier)
                        
                        do{try setSpotlightArray()}
                        catch let error {print("Error: \(error)")}
                        
                    }
                }
            }
        }
    }
    
    static func AddItemToCoreSpotlight(title:String, contentDescription:String?, imageUrl:String?, uniqueIdentifier:String?, keywords:[String]){
        guard let content = contentDescription else {return}
        guard let thumbnailImageUrl = imageUrl else {return}
        guard let uniqueIdentifier = uniqueIdentifier else {return}
    
        //Check is Identifier already exists
        guard CoreSpotlight.spotlightArray.contains(uniqueIdentifier) == false else {return}
        
        Alamofire.request(thumbnailImageUrl).responseImage { response in
            if let image = response.result.value {
                let attributeSet = createAttributeSetContent(title: title, contentDescription: content, thumbnailData: image.pngData()!, keywords: keywords)
                let item = CSSearchableItem(uniqueIdentifier: uniqueIdentifier, domainIdentifier: AppCoreKit.bundleIdentifier, attributeSet: attributeSet)
                
                CSSearchableIndex.default().indexSearchableItems([item]) { error in
                    if let error = error { print("Add error: \(error.localizedDescription)")}
                    else {
                        print("Search item successfully indexed \(uniqueIdentifier)")
                        CoreSpotlight.spotlightArray.append(uniqueIdentifier)
                        
                        do{try setSpotlightArray()}
                        catch let error {print("Error: \(error)")}
                
                    }
                }
            }
        }
    }
    
    static func AddItemToCoreSpotlight(title:String, contentDescription:String?, imageUrl:String?, url:URL?, uniqueIdentifier:String?,  keywords:[String]){
        guard let content = contentDescription else {return}
        guard let thumbnailImageUrl = imageUrl else {return}
        guard let uniqueIdentifier = uniqueIdentifier else {return}
        guard let uniqueUrl = url else {return}

        //Check is Identifier already exists
        guard CoreSpotlight.spotlightArray.contains(uniqueIdentifier) == false else {return}

        Alamofire.request(thumbnailImageUrl).responseImage { response in
            if let image = response.result.value {
                let attributeSet = createAttributeSetContent(title: title, contentDescription: content, thumbnailData: image.pngData()!, keywords: keywords)
                attributeSet.url = uniqueUrl
                let item = CSSearchableItem(uniqueIdentifier: uniqueIdentifier, domainIdentifier: AppCoreKit.bundleIdentifier, attributeSet: attributeSet)
                
                CSSearchableIndex.default().indexSearchableItems([item]) { error in
                    if let error = error { print("Add error: \(error.localizedDescription)")}
                    else {print("Search item successfully indexed \(uniqueIdentifier)")
                        CoreSpotlight.spotlightArray.append(uniqueIdentifier)
                        
                        do{try setSpotlightArray()}
                        catch let error {print("Error: \(error)")}
                    }
                }
            }
        }
    }
    
    static func AddItemToCoreSpotlight(searchableItems:[CSSearchableItem]){
        CSSearchableIndex.default().indexSearchableItems(searchableItems) { error in
            if let error = error { print("Add error: \(error.localizedDescription)")}
            else {print("Search item successfully indexed")}
        }
    }
    
    //MARK: Create Attribute Set
    
    static func createAttributeSetContent(title:String, contentDescription:String) -> CSSearchableItemAttributeSet{
        //attributeSet.contentDescription = songList[i].album + "\n" + songList[i].style
        
        var keywords = title.components(separatedBy: " ")
        for word in contentDescription.components(separatedBy: " "){keywords.append(word)}
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        attributeSet.title = title
        attributeSet.contentDescription = contentDescription
        attributeSet.thumbnailData = AppCoreKit.appIcon.pngData()
        attributeSet.keywords = keywords
        return attributeSet
    }
    
    static func createAttributeSetContent(title:String, contentDescription:String, thumbnailData:Data) -> CSSearchableItemAttributeSet{
        var keywords = title.components(separatedBy: " ")
        for word in contentDescription.components(separatedBy: " "){keywords.append(word)}
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        attributeSet.title = title
        attributeSet.contentDescription = contentDescription
        attributeSet.thumbnailData = thumbnailData
        attributeSet.keywords = keywords
        return attributeSet
    }
    
    static func createAttributeSetContent(title:String, contentDescription:String, thumbnailData:Data, keywords:[String]) -> CSSearchableItemAttributeSet{
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        attributeSet.title = title
        attributeSet.contentDescription = contentDescription
        attributeSet.thumbnailData = thumbnailData
        attributeSet.keywords = keywords
        return attributeSet
    }
    
    
    //MARK: Delete From Core Spotlight
    
    // Delete the items represented by unique identifier.
    static func RemoveItemFromCoreSpotlight(uniqueIdentifier:String){
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [uniqueIdentifier], completionHandler: { error in
            if let error = error { print("Remove error: \(error.localizedDescription)")}
            else { print("Search item successfully removed") }
        })
    }
    
    // Delete the items represented by an array of unique identifiers.
    static func RemoveItemFromCoreSpotlight(uniqueIdentifiers:[String]){
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: uniqueIdentifiers, completionHandler: { error in
            if let error = error { print("Remove error: \(error.localizedDescription)")}
            else { print("Search item successfully removed") }
        })
    }
    
    // Delete the items represented by a domain identifier.
    static func RemoveItemFromCoreSpotlight(){
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [AppCoreKit.bundleIdentifier], completionHandler: { error in
            if let error = error { print("Remove error: \(error.localizedDescription)")}
            else { print("Search item successfully removed")
                eraseSpotlightArray()
            }
        })
    }
    
    // Delete all items from the on-device index.
    static func RemoveAllItemsFromCoreSpotlight(){
        CSSearchableIndex.default().deleteAllSearchableItems(completionHandler: { error in
            if let error = error { print("Remove All error: \(error.localizedDescription)")}
            else {
                print("All Search items successfully removed")
                eraseSpotlightArray()
            }
        })
    }
}





