import Vision
import SwiftUI


class TextRecognizer {
    
    func recognize(_ cgImage: CGImage, keywords: [String] = [], completion: @escaping (String) -> Void) {
    let req = VNRecognizeTextRequest { req, err in
      guard err == nil,
            let obs = req.results as? [VNRecognizedTextObservation]
      else { return completion("") }
      let t = obs.compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
      completion(t)
    }
    req.recognitionLevel = .accurate
    DispatchQueue.global().async {
      try? VNImageRequestHandler(cgImage: cgImage, options: [:])
                   .perform([req])
    }
  }
}

