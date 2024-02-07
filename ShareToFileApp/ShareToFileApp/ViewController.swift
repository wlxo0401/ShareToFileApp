//
//  ViewController.swift
//  ShareToFileApp
//
//  Created by 김지태 on 2/7/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func createJsonAndShare(_ sender: Any) {
        self.saveJSONToFile()
    }
    
    @IBAction func createCsvAndShare(_ sender: Any) {
        self.createAndShareCSVFile()
    }
    
    @IBAction func networkFileShare(_ sender: Any) {
        let url: String = "https://www.stats.govt.nz/assets/Uploads/Annual-enterprise-survey/Annual-enterprise-survey-2021-financial-year-provisional/Download-data/annual-enterprise-survey-2021-financial-year-provisional-csv.csv"
        
        // 파일의 원격 URL
        guard let fileURL = URL(string: url) else {
            return
        }
        self.shareFile(at: fileURL)
    }
    
    
    
    // 공유
    func shareFile(at url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - JSON
extension ViewController {
    // 앱 공간에 저장
    func saveJSONToFile() {
        // JSON 데이터 생성
        let jsonData = createJSONData()
        
        // JSON 데이터를 파일로 저장
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let destinationURL = documentsPath.appendingPathComponent("data.json")
        
        do {
            try jsonData.write(to: destinationURL)
            // 파일 다운로드가 완료되었으므로 iOS 파일 앱과 공유
            self.shareFile(at: destinationURL)
        } catch {
            print("Error saving JSON to file: \(error)")
        }
    }
    
    func createJSONData() -> Data {
        // 예시 JSON 데이터 생성
        let jsonObject: [String: Any] = [
            "name": "John Doe",
            "age": 30,
            "email": "johndoe@example.com"
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            return jsonData
        } catch {
            fatalError("Error creating JSON data: \(error)")
        }
    }
}

// MARK: - CSV
extension ViewController {
    func createAndShareCSVFile() {
            // CSV 형식으로 데이터 생성
            let csvData = generateCSVData()
            
            // CSV 데이터를 파일로 저장
            guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            let fileURL = documentsPath.appendingPathComponent("data.csv")
            
            do {
                try csvData.write(to: fileURL, atomically: true, encoding: .utf8)
                // 파일 공유
                shareFile(at: fileURL)
            } catch {
                print("Error saving CSV file: \(error)")
            }
        }
        
        func generateCSVData() -> String {
            // 예시 데이터
            let data: [[String]] = [
                ["Name", "Age", "Email"],
                ["John Doe", "30", "johndoe@example.com"],
                ["Jane Smith", "25", "janesmith@example.com"]
            ]
            
            var csvString = ""
            for row in data {
                let rowString = row.map { "\"\($0)\"" }.joined(separator: ",")
                csvString.append("\(rowString)\n")
            }
            return csvString
        }
}
