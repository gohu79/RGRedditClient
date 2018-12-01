//
//  HomeSectionDataPovider.swift
//  RGRedditClient
//
//  Created by Jose Humberto Partida Garduno on 11/26/18.
//  Copyright © 2018 Jose Humberto Partida Garduno. All rights reserved.
//

import Foundation
import UIKit

class RGHomeSectionDataProvider: NSObject, UITableViewDataSource, UITableViewDelegate {

    var homeSectionDirector: RGHomeElementDirecting
    override init() {
        homeSectionDirector = RGHomeElementDirector()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeSectionDirector.sectionsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !homeSectionDirector.sectionsAreEmpty, indexPath.row < homeSectionDirector.sectionsCount else {
            return UITableViewCell()
        }
        guard let section = homeSectionDirector.elementSection(at: indexPath.row), let sectionId = section.sectionId else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: sectionId, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let element = homeSectionDirector.elementSection(at: indexPath.row) else {
            return UITableView.automaticDimension
        }
        if element.section is RGLoaderPresenter {
            if homeSectionDirector.sectionsCount <= 1 {
                return tableView.bounds.size.height
            }
        }
        if element.section is RGErrorPresenter {
            return tableView.bounds.size.height
        }
        return UITableView.automaticDimension
    }
}