import Vision
import SwiftUI
 

//Clase que maneja el reconocimiento de texto, recibe la lista de keywords, una Image en formato CGImage y regresa un string con espacios.

class TextRecognizer {
    
    func recognize(_ cgImage: CGImage, keywords: [String] = [], completion: @escaping ([String]) -> Void) {
        let req = VNRecognizeTextRequest { req, err in
            guard err == nil,
                  let obs = req.results as? [VNRecognizedTextObservation]
            else { return completion([]) }

            let lines = obs.compactMap { $0.topCandidates(1).first?.string }

            let filtered = keywords.isEmpty
                ? lines
                : lines.filter { line in
                    keywords.contains { kw in
                        line.range(of: kw, options: .caseInsensitive) != nil
                    }
                }

            completion(filtered)
        }
        req.recognitionLevel = .accurate

        DispatchQueue.global().async {
            try? VNImageRequestHandler(cgImage: cgImage, options: [:])
                .perform([req])
        }
    }

}

