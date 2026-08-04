import Flutter
import ImageIO
import UIKit
import Vision

class SceneDelegate: FlutterSceneDelegate {
  private let addShortcutType = "com.samugalasso.cashflowApp.add"
  private var receiptOcrChannel: FlutterMethodChannel?

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    configureReceiptOcrChannel()
    if let shortcutItem = connectionOptions.shortcutItem {
      DispatchQueue.main.async { [weak self] in
        _ = self?.handle(shortcutItem)
      }
    }
  }

  override func windowScene(
    _ windowScene: UIWindowScene,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    completionHandler(handle(shortcutItem))
  }

  private func handle(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
    guard shortcutItem.type == addShortcutType,
          let controller = window?.rootViewController as? FlutterViewController else {
      return false
    }
    controller.pushRoute("/add")
    return true
  }

  private func configureReceiptOcrChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "pocket_vault/receipt_ocr",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "recognize" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let arguments = call.arguments as? [String: Any],
            let path = arguments["path"] as? String,
            !path.isEmpty else {
        result(FlutterError(
          code: "invalid_path",
          message: "The receipt image path is missing.",
          details: nil
        ))
        return
      }
      self?.recognizeReceipt(at: path, result: result)
    }
    receiptOcrChannel = channel
  }

  private func recognizeReceipt(at path: String, result: @escaping FlutterResult) {
    DispatchQueue.global(qos: .userInitiated).async {
      guard let image = UIImage(contentsOfFile: path), let cgImage = image.cgImage else {
        DispatchQueue.main.async {
          result(FlutterError(
            code: "invalid_image",
            message: "The receipt image could not be decoded.",
            details: nil
          ))
        }
        return
      }

      let request = VNRecognizeTextRequest()
      request.recognitionLevel = .accurate
      request.usesLanguageCorrection = true
      request.recognitionLanguages = ["it-IT", "en-US", "es-ES"]
      request.minimumTextHeight = 0.008

      do {
        let handler = VNImageRequestHandler(
          cgImage: cgImage,
          orientation: CGImagePropertyOrientation(image.imageOrientation),
          options: [:]
        )
        try handler.perform([request])
        let observations = (request.results ?? []).sorted { first, second in
          let verticalDistance = abs(first.boundingBox.midY - second.boundingBox.midY)
          if verticalDistance > 0.015 {
            return first.boundingBox.midY > second.boundingBox.midY
          }
          return first.boundingBox.minX < second.boundingBox.minX
        }
        let lines: [[String: Any]] = observations.compactMap { observation in
          guard let candidate = observation.topCandidates(1).first else { return nil }
          return [
            "text": candidate.string,
            "confidence": Double(candidate.confidence),
            "x": Double(observation.boundingBox.minX),
            "y": Double(1 - observation.boundingBox.maxY),
            "width": Double(observation.boundingBox.width),
            "height": Double(observation.boundingBox.height),
          ]
        }
        DispatchQueue.main.async { result(lines) }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(
            code: "recognition_failed",
            message: error.localizedDescription,
            details: nil
          ))
        }
      }
    }
  }
}

private extension CGImagePropertyOrientation {
  init(_ orientation: UIImage.Orientation) {
    switch orientation {
    case .up: self = .up
    case .upMirrored: self = .upMirrored
    case .down: self = .down
    case .downMirrored: self = .downMirrored
    case .left: self = .left
    case .leftMirrored: self = .leftMirrored
    case .right: self = .right
    case .rightMirrored: self = .rightMirrored
    @unknown default: self = .up
    }
  }
}
