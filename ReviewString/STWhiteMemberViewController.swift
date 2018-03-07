//
//  STWhiteMemberViewController.swift
//  ReviewString
//
//  Created by EuiSuk_Lee on 2018. 1. 11..
//  Copyright © 2018년 euisuk_lee. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class STWhiteMemberViewController: UIViewController {
    @IBOutlet weak var WhiteMemberLabel: UILabel!
    @IBOutlet weak var segmentedResult: UISegmentedControl!
    @IBOutlet weak var segmentedResultReson: UISegmentedControl!
    @IBOutlet weak var ImageView: UIImageView!
    
    var profileImg = [UIImage()]
    var idArray: [account] = []
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getReviewAccount()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getReviewAccount()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getReviewAccount() {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "crocodile" : "wearecro"
        ]
        
        Alamofire.request(String.domain! + "information/internal/get/in-review-id-card/", method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON{response in
            switch response.result {
            case .success:
                print("success : getLastAPI")
                let json = JSON(response.result.value)
                print(json)
                let accounts = json["accounts"].arrayValue
                
                for i in accounts {
                    var newAccount = account()
                    newAccount.account_id = i["account_id"].stringValue
                    newAccount.image = i["image"].stringValue
                    newAccount.sex = i["sex"].stringValue
                    newAccount.image_id = i["image_id"].stringValue
                    
                    self.idArray.append(newAccount)
                    
                    if accounts.count == self.idArray.count {
                        self.currentIndex = 0
                        self.nextID()
                    }
                }
            case .failure(let error):
                print("이것은 에러입니다 삐빅 :" + String(describing: error))
            }
        }
    }
    
    func getIdImage() {
        if idArray.count > 0 {
            if let id = self.idArray[currentIndex].image {
                Alamofire.request(String.domain! + "profile/" + id).responseData { (response) in
                    print(response)
                    self.ImageView.image = UIImage(data: response.data!)!
                }
            }
        }
    }
    
    func nextID() {
        getIdImage()
//        self.WhiteMemberLabel.text = self.idArray[currentIndex].account_label!
    }
    
    @IBAction func registerAccountAction(_ sender: Any) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "crocodile" : "wearecro"
        ]
        
        let params = [
            "sex" : idArray[currentIndex].sex!,
            "account_id": idArray[currentIndex].account_id!,
            "image_id" : idArray[currentIndex].image_id!,
            "result" : segmentedResult.selectedSegmentIndex == 0 ? true : false
            ] as [String : Any]
        
        Alamofire.request(String.domain! + "information/internal/register/review/id-card-image/" , method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON{response in
            switch response.result {
            case .success:
                print("success : getLastAPI")
                if self.currentIndex <= self.idArray.count {
                    self.currentIndex += 1
                    self.nextID()
                    self.segmentedResult.selectedSegmentIndex = UISegmentedControlNoSegment
                    self.segmentedResultReson.selectedSegmentIndex = UISegmentedControlNoSegment
                } else {
                    self.WhiteMemberLabel.text = "심사 할 계정 없음"
                }
            case .failure(let error):
                print("이것은 에러입니다 삐빅 :" + String(describing: error))
            }
        }
    }
}

struct account {
    var image: String?
    var sex: String?
    var account_id: String?
    var image_id: String?
    var account_label: String?
}

extension String {
    static var domain: String? {
        return "포트폴리오용"
    }
}
