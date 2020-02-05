//
//  BehaviorKit.swift

//
//  Created by Angel Henderson on 10/10/18.

//

import Foundation
import SwifterSwift

struct BehaviorKit {
    static var learningTopicMaxSize = 10

    
    static func learnTopic(topicId: String){
        var cleanArray: [String] = []
        
        let defaults = Defaults()
        if defaults.has(.learnedTopics) {
            cleanArray = defaults.get(for: .learnedTopics)! //Retrieve learned behavior
        }
        
        cleanArray.removeDuplicates()
        let slice = cleanArray.prefix(learningTopicMaxSize)
        var properlySizedArray = Array(slice)
        
        properlySizedArray.prepend(topicId)
        properlySizedArray.removeDuplicates()
        

        let newSlice = properlySizedArray.prefix(learningTopicMaxSize)
        let finalArray = Array(newSlice)
        print("Topic Final Array: \(finalArray)")
        defaults.set(finalArray, for: .learnedTopics)
    }
}

extension DefaultsKey {
    static let learnedTopics = Key<[String]>("TopicIds")
}
