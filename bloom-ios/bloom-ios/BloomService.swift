//
//  BloomService.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/1/26.
//


import SwiftUI
import Combine

class BloomService: ObservableObject {
    static let baseURL = "http://127.0.0.1:8080"

    @Published var isLoading    = false
    @Published var routedPillar: BloomPillar? = nil
    @Published var routedAction: String?      = nil
    @Published var response:    BloomResponse? = nil
    @Published var error:       String?        = nil

    private var delegate: SSEDelegate?
    private var session:  URLSession?

    func request(
        message: String,
        pillar: BloomPillar?,
        context: [String: Any],
        image: UIImage? = nil
    ) {
        isLoading    = true
        routedPillar = nil
        routedAction = nil
        response     = nil
        error        = nil

        guard let url = URL(string: "\(BloomService.baseURL)/bloom") else {
            error = "Invalid server URL"
            isLoading = false
            return
        }

        var body: [String: Any] = [
            "message": message,
            "context": context
        ]
        if let p = pillar {
            body["pillar"] = p.rawValue
        }
        if let img = image, let b64 = encodeImage(img) {
            body["image_data"] = b64
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            error = "Failed to serialize request"
            isLoading = false
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod  = "POST"
        req.httpBody    = jsonData
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("text/event-stream", forHTTPHeaderField: "Accept")

        let delegate = SSEDelegate(service: self)
        self.delegate = delegate
        let session   = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        self.session  = session

        session.dataTask(with: req).resume()
    }

    private func encodeImage(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        return data.base64EncodedString()
    }

    func handleEvent(type: String, data: String) {
        DispatchQueue.main.async { [weak self] in
            guard let jsonData = data.data(using: .utf8) else { return }

            switch type {
            case "status":
                break

            case "routed":
                if let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: String] {
                    self?.routedPillar = BloomPillar(rawValue: obj["pillar"] ?? "")
                    self?.routedAction = obj["action"]
                }

            case "result":
                if let decoded = try? JSONDecoder().decode(BloomResponse.self, from: jsonData) {
                    self?.response = decoded
                }
                self?.isLoading = false

            case "error":
                if let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: String] {
                    self?.error = obj["error"]
                }
                self?.isLoading = false

            default:
                break
            }
        }
    }
}

// MARK: - SSE Delegate

private class SSEDelegate: NSObject, URLSessionDataDelegate {
    weak var service: BloomService?
    private var buffer = ""

    init(service: BloomService) { self.service = service }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let text = String(data: data, encoding: .utf8) else { return }
        buffer += text

        let events = buffer.components(separatedBy: "\n\n")
        buffer = events.last ?? ""

        for event in events.dropLast() { parseEvent(event) }
    }

    private func parseEvent(_ raw: String) {
        var eventType = ""
        var eventData = ""

        for line in raw.components(separatedBy: "\n") {
            if line.hasPrefix("event:") {
                eventType = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("data:") {
                eventData = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
            }
        }
        guard !eventType.isEmpty, !eventData.isEmpty else { return }
        service?.handleEvent(type: eventType, data: eventData)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let error = error { self?.service?.error = error.localizedDescription }
            self?.service?.isLoading = false
        }
    }
}