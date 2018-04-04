/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import UIKit
import IGProtoBuff

protocol IGRegistrationStepSelectCountryTableViewControllerDelegate {
    func didSelectCountry(country:IGCountryInfo)
}


class IGRegistrationStepSelectCountryTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate , UINavigationControllerDelegate , UIGestureRecognizerDelegate  {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate : IGRegistrationStepSelectCountryTableViewControllerDelegate?
    
    var listOfCountries = Array<IGCountry>()
    var dictionaryOfSectionedCountries = Dictionary<String, [IGCountry]>()
    var sortedListOfKeys = Array<String>()
    
    var popView: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navItem = self.navigationItem as! IGNavigationItem
        navItem.addModalViewItems(leftItemText: nil, rightItemText: "Close", title: "Country")
        navItem.rightViewContainer?.addAction {
            IGRegistrationStepPhoneViewController.allowGetCountry = false
            if self.popView {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        listOfCountries = IGCountry.getSortedListOfCountriesWithPhone()
        self.createDataSetForTableview(countries: listOfCountries)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return dictionaryOfSectionedCountries.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionaryOfSectionedCountries[sortedListOfKeys[section]]!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: IGSelectCountryCell = self.tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath) as! IGSelectCountryCell
        let countriesInThisSection = dictionaryOfSectionedCountries[sortedListOfKeys[indexPath.section]]
        let country = countriesInThisSection?[indexPath.row]
        cell.setSearchResult(country: country!)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedListOfKeys[section]
    }
    
//    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return sortedListOfKeys //Side Section title
//    }
//    
//    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
//    {
//        return index
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let countriesInThisSection = dictionaryOfSectionedCountries[sortedListOfKeys[indexPath.section]]
        let country = countriesInThisSection?[indexPath.row]
        let isoCode = (country?.isoCode)!
        
        IGInfoCountryRequest.Generator.generate(countryCode: isoCode).success { (responseProto) in
            DispatchQueue.main.async {
                switch responseProto {
                case let countryInfoReponse as IGPInfoCountryResponse:
//                    let requestMessage = countryInfoReponse as! IGPInfoCountry.Builder
                    let countryInfo = IGCountryInfo(responseProtoMessage: countryInfoReponse)
                    countryInfo.countryISO = isoCode
                    self.delegate?.didSelectCountry(country: countryInfo)
                    IGRegistrationStepPhoneViewController.allowGetCountry = false
                    if self.popView {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                default:
                    break
                }    
            }
        }.error { (errorCode, waitTime) in
            
        }.send()
    }
    
    
    //MARK - IBActions
    @IBAction func didTapOnCloseBarButtonItem(_ sender: UIBarButtonItem) {
        
    }
    
    //MARK - Private methods
    fileprivate func createDataSetForTableview(countries:Array<IGCountry>) {
        dictionaryOfSectionedCountries = Dictionary<String, [IGCountry]>()
        sortedListOfKeys = Array<String>()
        for country in countries {
            let firstChar = String(country.localizedName[0])
            if !dictionaryOfSectionedCountries.keys.contains(firstChar) {
                dictionaryOfSectionedCountries[firstChar] = Array<IGCountry>()
            }
            dictionaryOfSectionedCountries[firstChar]?.append(country)
        }
        
        let keys = [String] (dictionaryOfSectionedCountries.keys)
        sortedListOfKeys = keys.sorted(by: { $0 < $1 })
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print(#function)
        self.createDataSetForTableview(countries: self.listOfCountries)
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(#function)
        
        if (searchText == ""){
            self.searchBarTextDidEndEditing(searchBar)
            return
        }
        
        var listOfCountriesAfterSearch = Array<IGCountry>()
        for country in listOfCountries {
            if (country.localizedName.lowercased().contains(searchText.lowercased())) {
                listOfCountriesAfterSearch.append(country)
            }
        }
        self.createDataSetForTableview(countries: listOfCountriesAfterSearch)
        self.tableView.reloadData()
    }
}

//extension IGRegistrationStepSelectCountryTableViewController : UISearchBarDelegate {
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        print(#function)
//        self.createDataSetForTableview(countries: self.listOfCountries)
//        self.tableView.reloadData()
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print(#function)
//
//        if (searchText == ""){
//            self.searchBarTextDidEndEditing(searchBar)
//            return
//        }
//
//        var listOfCountriesAfterSearch = Array<IGCountry>()
//        for country in listOfCountries {
//            if (country.localizedName.lowercased().contains(searchText.lowercased())) {
//                listOfCountriesAfterSearch.append(country)
//            }
//        }
//        self.createDataSetForTableview(countries: listOfCountriesAfterSearch)
//        self.tableView.reloadData()
//    }
//}

