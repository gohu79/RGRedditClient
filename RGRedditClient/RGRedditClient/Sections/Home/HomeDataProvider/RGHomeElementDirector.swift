//
//  RGHomeSectionDirector.swift
//  RGRedditClient
//
//  Created by Jose Humberto Partida Garduno on 11/27/18.
//  Copyright © 2018 Jose Humberto Partida Garduno. All rights reserved.
//

import Foundation
import UIKit

struct RGBasicAlertFactory {
    static func createAlert(title: String, message: String, actionTitle: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: actionTitle, style: style, handler: handler)
        alert.addAction(alertAction)
        return alert
    }
}

protocol RGHomeElementDirecting {
    var sectionsCount: Int { get }
    var sectionsAreEmpty: Bool { get }
    func insertSection(section: Any)
    func insertSections(sections: [Any])
    func removeSection(section: Any)
    func elementSection(at index: Int) -> (section: Any,sectionId: String?)?
}

class RGHomeElementDirector: RGHomeElementDirecting {
    fileprivate var homeSections:[Any] = []
    fileprivate var sectionsRegistered: [RGHomeSections: String] = [:]
    
    enum RGHomeSections: String {
        case error
        case loader
        case feed
    }
    
    var sectionsRegisteredCount: Int{
        return sectionsRegistered.count
    }
    
    var sectionsCount: Int {
        return homeSections.count
    }
    
    var sectionsAreEmpty: Bool {
        return homeSections.isEmpty
    }
    
    func insertSections(sections: [Any]) {
        homeSections.append(contentsOf: sections)
        register(section: sections.first!)
    }
    
    func insertSection(section: Any) {
        homeSections.append(section)
        register(section: section)
    }
    
    func removeSection(section: Any) {
        guard !homeSections.isEmpty else {
            return
        }
        guard let sectionId = getId(for: section) else {
            return
        }
        let sectionIndex = homeSections.firstIndex { (element) -> Bool in
            guard let id = getId(for: element) else {
                return false
            }
            return sectionId == id
        }
        guard let index = sectionIndex else {
            return
        }
        let section = homeSections.remove(at: index)
        deregister(section: section)
    }
    
    func elementSection(at index: Int) -> (section: Any,sectionId: String?)?{
        guard !homeSections.isEmpty else {
            return nil
        }
        
        let section = homeSections[index]
        
        guard let sectionId = getId(for: section) else {
            return nil
        }
        return (section, sectionId)
    }
    
    fileprivate func getId(for section: Any) -> String? {
        return retrieveId(for: section)
    }
    
    fileprivate func retrieveId(for section: Any) -> String? {
        if let _ = section as? RGErrorPresenter, sectionsRegistered.keys.contains(.error) {
            return sectionsRegistered[.error]
        }
        if let _ = section as? RGLoaderPresenter, sectionsRegistered.keys.contains(.loader) {
            return sectionsRegistered[.loader]
        }
        if let _ = section as? RGFeedDataContainer, sectionsRegistered.keys.contains(.feed) {
            return sectionsRegistered[.feed]
        }
        return nil
    }
    
    fileprivate func register(section: Any) {
        if let errorSection =  section as? RGErrorPresenter, !sectionsRegistered.keys.contains(.error) {
            sectionsRegistered[.error] = errorSection.id
        }
        if let loaderSection = section as? RGLoaderPresenter, !sectionsRegistered.keys.contains(.loader) {
            sectionsRegistered[.loader] = loaderSection.id
        }
        if let _ = section as? RGFeedDataContainer, !sectionsRegistered.keys.contains(.feed) {
            sectionsRegistered[.feed] = RGFeedPresenter.id
        }
    }
    
    fileprivate func deregister(section: Any) {
        if let _ = section as? RGErrorPresenter, !sectionsRegistered.keys.contains(.error) {
            sectionsRegistered.removeValue(forKey: .error)
        }
        if let _ = section as? RGLoaderPresenter, !sectionsRegistered.keys.contains(.loader) {
            sectionsRegistered.removeValue(forKey: .loader)
        }
        if let _ = section as? RGFeedDataContainer, sectionsRegistered.keys.contains(.feed) {
            let isThereAnyRGFeed = homeSections.contains { (section) -> Bool in
                if let _ = section as? RGFeedDataContainer {
                    return true
                }
                return false
            }
            if !isThereAnyRGFeed {
                sectionsRegistered.removeValue(forKey: .feed)
            }
        }
    }
}
