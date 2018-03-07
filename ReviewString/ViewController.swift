//
//  ViewController.swift
//  ReviewString
//
//  Created by euisuk_lee on 2017. 12. 4..
//  Copyright © 2017년 euisuk_lee. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var imgCollectionView: UICollectionView!
    @IBOutlet weak var resultSegment: UISegmentedControl!
    @IBOutlet weak var faceSegment: UISegmentedControl!
    @IBOutlet weak var rejectSegment: UISegmentedControl!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var qnaLabel: UILabel!
    
    var reviewAccounts: [ReviewAccount?] = []
    var nowReviewAccount: ReviewAccount?
    var nextId = 0
    var uploadMax = 0
    var uploadCounter = 0
    
    var downloadImageArray: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInreviewAccount()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        imgCollectionView.setCollectionViewLayout(flowLayout, animated: true)
        imgCollectionView.delegate = self
        imgCollectionView.dataSource = self
        
        self.imgCollectionView.register(UINib(nibName: "reviewUICollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "reviewUICollectionViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return downloadImageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewUICollectionViewCell", for: indexPath) as! reviewUICollectionViewCell
        cell.image.image = downloadImageArray[indexPath.row]
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return(CGSize(width: (self.imgCollectionView.frame.height/4)*3, height: self.imgCollectionView.frame.size.height))
   
    }

    @IBAction func ReviewBtn(_ sender: Any) {
        self.resultSegment.selectedSegmentIndex = UISegmentedControlNoSegment
        self.faceSegment.selectedSegmentIndex = UISegmentedControlNoSegment
        self.rejectSegment.selectedSegmentIndex = UISegmentedControlNoSegment
        
        if nowReviewAccount!.inreviewImage!.count > 0 {
            uploadMax += 1
            registerProfile()
        }
        
        if nowReviewAccount!.inreviewqna!.count > 0 {
            uploadMax += 1
            registerqna()
        }
    }
    
    func getInreviewAccount() {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "crocodile" : "wearecro"
        ]
        
        Alamofire.request(String.domain! + "information/internal/get/in-review-account/", method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                let json = JSON(response.result.value!)
                let female = json["females"].arrayValue
                let male = json["male"].arrayValue
                
                for (index, i) in [female, male].enumerated() {
                    for a in i {
                        let JSONAccount = a
                        var addAccount = ReviewAccount()
                        
                        if (JSONAccount["status"].stringValue == "INREVIEW") || (JSONAccount["status"].stringValue == "EDITTING") {
                            print(a)
                            addAccount.id = JSONAccount["id"].intValue
                            addAccount.age = JSONAccount["age"].stringValue
                            addAccount.blood_type = JSONAccount["blood_type"].stringValue
                            addAccount.body_form = JSONAccount["body_form"].stringValue
                            addAccount.department = JSONAccount["department"].stringValue
                            addAccount.drink = JSONAccount["drink"].stringValue
                            addAccount.education = JSONAccount["education"].stringValue
                            addAccount.height = JSONAccount["height"].stringValue
                            addAccount.location = JSONAccount["location"].stringValue
                            addAccount.religion = JSONAccount["religion"].stringValue
                            addAccount.sex = index == 0 ? "female" : "male"
                            
                            let JSONqna = JSONAccount["qna"]["in_review"].arrayValue
                            var addqnaArray: [qna] = []
                            for q in JSONqna {
                                var addqna = qna()
                                addqna.answer = q["answer"].stringValue
                                addqna.id = q["id"].intValue
                                addqna.question = q["question"].stringValue
                                addqna.question_id = q["question_id"].intValue
                                addqnaArray.append(addqna)
                            }
                            
                            addAccount.inreviewqna = addqnaArray
                            
                            let JSONimageArray = JSONAccount["images"]["in_review"].arrayValue
                            var addImageArray: [profileImage] = []
                            for p in JSONimageArray {
                                var addImage = profileImage()
                                addImage.index = p["index"].intValue
                                addImage.name = p["name"].stringValue
                                
                                addImageArray.append(addImage)
                                
                                if JSONimageArray.count == addImageArray.count {
                                    addAccount.inreviewImage = addImageArray
                                }
                            }
                            if addImageArray.count == 0 {
                                addAccount.inreviewImage = []
                            }
                            
                            self.reviewAccounts.append(addAccount)
                        }
                    }
                }
                self.nextID()
                
            case .failure(let error):
                print("error - edit-account-info :" + String(describing: error))
            }
        }
    }
    
    func getImage(_ imgArray: [profileImage]) {
        var newArray: [UIImage] = []
        for i in imgArray {
            let name = i.name!
            let replaced = (name as NSString).replacingOccurrences(of: "{}", with: "large")
            
            Alamofire.request(String.domain! + "profile/" + replaced).responseData { (response) in
                print(response)
                newArray.append(UIImage(data: response.data!)!)
                
                if imgArray.count == newArray.count {
                    self.downloadImageArray = newArray
                    self.imgCollectionView.reloadData()
                }
            }
        }
    }
    
    func nextID() {
        if reviewAccounts.count > nextId {
            nowReviewAccount = reviewAccounts[nextId]
            
            getImage((nowReviewAccount?.inreviewImage!)! as! [profileImage])
            profileLabel.text = "ID : \(String(describing: nowReviewAccount!.id!)) #\(String(describing: nowReviewAccount!.location!)) #\(nowReviewAccount!.sex!) #\(nowReviewAccount!.age!)세 #\(nowReviewAccount!.height!)cm #\(nowReviewAccount!.education!) #\(nowReviewAccount!.department!) #\(nowReviewAccount!.body_form!)"
            
            if (nowReviewAccount?.inreviewqna?.count)! > 0 {
                qnaLabel.text = "A1 : \(String(describing: nowReviewAccount?.inreviewqna![0]!.answer!)) \nA2 : \(String(describing: nowReviewAccount?.inreviewqna![1]!.answer!)) \nA3 : \(String(describing: nowReviewAccount?.inreviewqna![2]!.answer!))"
            } else {
                qnaLabel.text = "QNA 심사 할 건 없음"
            }
            
            nextId += 1
        }
    }
    
    func registerProfile() {
        for i in (nowReviewAccount?.inreviewImage)! {
            let param = [
                "sex" : nowReviewAccount!.sex!,
                "account_id" : nowReviewAccount!.id! ,
                "image_index" : i!.index!,
                "result" : true
            ] as [String : Any]
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "crocodile" : "wearecro"
            ]
            
            Alamofire.request(String.domain! + "information/internal/register/review/profile-image/", method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseJSON{response in
                switch response.result {
                case .success:
                    print("success : getLastAPI")
                    print(response)
                    self.uploadCounter += 1
                    self.nextChecker()
                    
                case .failure(let error):
                    print("이것은 에러입니다 삐빅 :" + String(describing: error))
                }
            }
        }
    }
    
    func registerqna() {
        for i in (nowReviewAccount?.inreviewqna)! {
            let param = [
                "sex" : nowReviewAccount?.sex!,
                "account_id" : nowReviewAccount?.id! ,
                "question_id" : i?.question_id!,
                "result" : true
                ] as [String : Any]
            
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "crocodile" : "wearecro"
            ]
            
            Alamofire.request(String.domain! + "information/internal/register/review/qna-answer/", method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseJSON{response in
                switch response.result {
                case .success:
                    print("success : getLastAPI")
                    self.uploadCounter += 1
                    self.nextChecker()
                    
                case .failure(let error):
                    print("이것은 에러입니다 삐빅 :" + String(describing: error))
                }
            }
        }
    }
    
    func nextChecker() {
        if uploadMax == uploadCounter {
            nextID()
        }
    }
}

struct ReviewAccount {
    var sex: String?
    var body_form: String?
    var department: String?
    var age: String?
    var religion: String?
    var height: String?
    var location: String?
    var blood_type: String?
    var id: Int?
    var drink: String?
    var education: String?
    var inreviewImage: [profileImage?]?
    var inreviewqna: [qna?]?
}

struct profileImage {
    var name: String?
    var index: Int?
}

struct qna {
    var answer: String?
    var question_id: Int?
    var id: Int?
    var question: String?
}

