//
//  ViewController.swift
//  collectionView
//
//  Created by Junyoung Lee on 2022/03/27.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
//    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet var collectionView: UICollectionView!
    
    // filter flag
    var flag = "all"
    
    // 기본 데이터
    var baseData = ["1학년 1반", "1학년 2반", "1학년 3반","1학년 4반","1학년 5반","1학년 6반","1학년 7반",
               "2학년 1반", "2학년 2반", "2학년 3반", "2학년 4반", "2학년 5반", "2학년 6반", "2학년 7반", "2학년 8반", "2학년 9반"]
    
    // 전체
    var allData = [String]()
    // 1학년
    var oneData = [String]()
    // 2학년
    var twoData = [String]()
    // collectionView에 보여질 데이터
    var viewData = [String]()
    
    //viewWillAppear addObserver 키보드 올리고 내릴때 view 위로 밀기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //viewWillDisappear removeObserver
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //collectionView 터치로 키보드 내리기
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(singleTapGestureRecognizer)
        
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        allData = baseData
        
        oneData = allData.filter{value in
            return value.starts(with: "1학년")
        }
        twoData = allData.filter{value in
            return value.starts(with: "2학년")
        }
        
        viewData = allData
    }
    
    //키보드가 올라올때
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func sort() {
        allData = baseData
        
        oneData = allData.filter{value in
            return value.starts(with: "1학년")
        }
        twoData = allData.filter{value in
            return value.starts(with: "2학년")
        }
        if flag == "all" {
            viewData = allData
        } else if flag == "one"{
            viewData = oneData
        } else if flag == "two"{
            viewData = twoData
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // 공백, 중복일때 데이터 추가 안되게
        guard let text = textField.text else { return false }
        
        //공백
        if text == "" {
            textField.resignFirstResponder()
            return false
        } else {
            // 학년, 반 텍스트에 반드시 포함
            if !text.contains("학년") && !text.contains("반"){
                textField.resignFirstResponder()
                return false
            }
            
            //중복
            for i in 0 ..< baseData.count{
                //필터사용해보기
                if baseData[i] == text {
                    textField.resignFirstResponder()
                    return false
                }
            }
            baseData.append(text)
            textField.text = ""
        }
        sort()
        collectionView.reloadData()
        
        
        textField.resignFirstResponder()
        return true
    }
    
    //키보드가 내려갈때
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    // 컬렉션뷰 터치로 내리기
    @objc func MyTapMethod(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    // 전체 학년
    @IBAction func allAction(_ sender: Any) {
        viewData = allData
        flag = "all"
        collectionView.reloadData()
    }
    
    // 1학년
    @IBAction func oneAction(_ sender: Any) {
        viewData = oneData
        flag = "one"
        collectionView.reloadData()
    }
    
    // 2학년
    @IBAction func twoAction(_ sender: Any) {
        viewData = twoData
        flag = "two"
        collectionView.reloadData()
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // collectionView 아이템 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if viewData.count == 0 {
////            noDataLabel.alpha = 1
////        } else {
////            noDataLabel.alpha = 0
////        }
        return viewData.count
    }
    
    // collectionView 아이템 데이터
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.cellLabel.text = viewData[indexPath.row]
        cell.layer.cornerRadius = 8
        return cell
    }
    
    // 이이템 클릭 시 동작할 함수 (삭제)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 선택된 셀의 label.text가져오기
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        guard let text = cell.cellLabel.text else {return}
        
        baseData.removeAll(where: {$0 == text})
        sort()
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let width = collectionView.frame.width
        
        flow.minimumLineSpacing = 8
        flow.minimumInteritemSpacing = 6
        
        let cellwidth = (width - (flow.minimumInteritemSpacing * 2))/3
        
        return CGSize(width: cellwidth, height: 65)
    }
}
