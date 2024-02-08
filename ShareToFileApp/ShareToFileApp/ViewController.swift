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
    
    @IBAction func networkFileDirectShare(_ sender: Any) {
        let url: String = "https://freetestdata.com/wp-content/uploads/2021/09/Free_Test_Data_1MB_XLSX.xlsx"
        
        // 파일의 원격 URL
        guard let fileURL = URL(string: url) else {
            return
        }
        self.shareFile(at: fileURL)
    }
    
    @IBAction func networkFileSaveShare(_ sender: Any) {
        // 다운로드할 파일의 URL
        guard let url = URL(string: "https://freetestdata.com/wp-content/uploads/2021/09/Free_Test_Data_1MB_XLSX.xlsx") else {
            return
        }
        
        // URLSession을 사용하여 파일 다운로드 요청 생성
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
    }
    
    
    // 공유
    func shareFile(at url: URL) {
        DispatchQueue.main.async {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
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

// MARK: - 파일 다운로드
extension ViewController: URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("다운로드 저장 완료")
        
        // 파일 다운로드 완료 후 로컬에 저장된 파일의 URL
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let destinationURL = documentsPath.appendingPathComponent("Free_Test_Data_1MB_XLSX.xlsx")
        
        do {
            // 이동할 때 이미 파일이 존재한다면 삭제
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            // 다운로드된 파일을 로컬에 이동
            try FileManager.default.moveItem(at: location, to: destinationURL)
            // 다운로드된 파일을 iOS 파일 앱과 공유
            self.shareFile(at: destinationURL)
        } catch {
            print("Error moving downloaded file: \(error)")
        }
    }
}
