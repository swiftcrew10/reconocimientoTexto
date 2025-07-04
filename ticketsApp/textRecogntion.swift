import Vision
import SwiftUI

class TextRecognizer {
    
    func recognize(_ cgImage: CGImage, keywords: [String] = [], completion: @escaping ([String: String]) -> Void) {
        
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil,
                  let observations = request.results as? [VNRecognizedTextObservation] else {
                completion([:])
                return
            }
            
            let lines = observations.compactMap { $0.topCandidates(1).first?.string }
//            print("Líneas detectadas:")
//            lines.forEach { print($0) }
            
            var results: [String: String] = [:]
            
            for (i, line) in lines.enumerated() {
                for keyword in keywords {
                    let lowerLine = line.lowercased()
                    let lowerKeyword = keyword.lowercased()
                    
                    if lowerLine.contains(lowerKeyword) {
                        // Caso 1: valor en la misma línea
                        if let range = lowerLine.range(of: lowerKeyword) {
                            let afterKeyword = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
                            
                            if !afterKeyword.isEmpty {
                                results[keyword] = afterKeyword
                            }
                            // Caso 2: valor está en la siguiente línea
                            else if i + 1 < lines.count {
                                let nextLine = lines[i + 1].trimmingCharacters(in: .whitespaces)
                                if !nextLine.lowercased().contains(lowerKeyword) {
                                    results[keyword] = nextLine
                                }
                            }
                        }
                    }
                }
            }
            
            completion(results)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.01
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
}
