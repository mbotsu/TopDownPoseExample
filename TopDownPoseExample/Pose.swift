import CoreML
import Vision
import KeypointDecoder
import Combine

class Pose: ObservableObject {
  @MainActor @Published var uiImage: UIImage?
  var fileURL: URL?
  private var requests = [VNRequest]()
  var bufferSize: CGSize = .zero
  let de = KeypointDecoder()
  var cancellable = Set<AnyCancellable>()
  var originalImage: UIImage? = nil
  
  @discardableResult
  func setupVision() -> NSError? {
    // Setup Vision parts
    let error: NSError! = nil
    guard let modelURL = Bundle.main.url(forResource: "yolov7-tiny_fp16", withExtension: "mlmodelc") else {
      return NSError(domain: "TopDownPoseEstimation", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
    }
    do {
      let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
      let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
        if let results = request.results {
          self.drawVisionRequestResults(results)
        }
      })
      objectRecognition.imageCropAndScaleOption = .scaleFit
      self.requests = [objectRecognition]
    } catch let error as NSError {
      print("Model loading went wrong: \(error)")
    }
    
    return error
  }
  
  func drawVisionRequestResults(_ results: [Any]) {
    var bboxes: [Float32] = []
    let label = "person"
    for observation in results where observation is VNRecognizedObjectObservation {
      guard let objectObservation = observation as? VNRecognizedObjectObservation else {
        continue
      }
      
      let width = self.originalImage!.size.width
      let height = self.originalImage!.size.height
      
      // Select only the label with the highest confidence.
      let topLabelObservation = objectObservation.labels[0]
      let bufferSize = CGSize(width: width, height: height)
      let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
      
      if topLabelObservation.identifier == label {
        let minY:CGFloat = height - objectBounds.minY // 画像の下側の値を返すので反転
        let bbox:[Float32] = [
          Float32(objectBounds.minX),
          Float32(minY - objectBounds.height),
          Float32(objectBounds.width),
          Float32(objectBounds.height)
        ]
        bboxes.append(contentsOf: bbox)
      }
    }
    let _bboxes = bboxes
    print(bboxes)
    test(img: self.originalImage!, boxes: _bboxes)
  }
    
  func test(img: UIImage, boxes: [Float32]) {
    // ==== pose ====
    let length = boxes.count / 4 * 3 * 17;
    var keypoints = [Float32](repeating: 0.0, count: length)
    var _boxes = boxes
    de.run(img, boxes: &_boxes ,boxNum: Int32(boxes.count), result: &keypoints)
    print(boxes)
    let resImage = de.renderHumanPose(img, keypoints: &keypoints, peopleNum: Int32(boxes.count/4), boxes: &_boxes)
    
    Task {
      await MainActor.run { [weak self] in
        if resImage != nil {
          self?.uiImage = resImage
        }
      }
    }
  }
  
  func prediction(imageBuffer: UIImage) async {
    self.originalImage = imageBuffer
    let exifOrientation: CGImagePropertyOrientation = .up
    let buff = imageBuffer.toPixelBuffer()!    
    let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: buff, orientation: exifOrientation, options: [:])
    do {
      try imageRequestHandler.perform(self.requests)
    } catch {
      print(error)
    }
  }
}
