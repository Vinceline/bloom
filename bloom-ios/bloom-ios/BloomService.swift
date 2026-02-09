//
//  BloomService.swift
//  bloom-ios
//
//  Created by Vinceline Bertrand on 2/1/26.
//


import SwiftUI
import Combine


// MARK: - BloomService

class BloomService: ObservableObject {
    static let baseURL = "http://127.0.0.1:8080"

    @Published var isLoading: Bool = false
    @Published var statusMessage: String? = nil
    @Published var routedPillar: BloomPillar? = nil
    @Published var routedAction: String? = nil
    @Published var response: BloomResponse? = nil
    @Published var error: String? = nil

    private var delegate: SSEDelegate?
    private var session: URLSession?

    // NOTE: `context` must be JSON-serializable and conform to BloomContext schema
    func request(
        message: String,
        pillar: BloomPillar?,
        context: [String: Any],
        image: UIImage? = nil
    ) {
        // Cancel any existing stream before starting a new one
        session?.invalidateAndCancel()
        delegate = nil
        session = nil

        DispatchQueue.main.async {
            self.isLoading = true
            self.statusMessage = nil
            self.routedPillar = nil
            self.routedAction = nil
            self.response = nil
            self.error = nil
        }

        guard let url = URL(string: "\(BloomService.baseURL)/bloom") else {
            self.error = "Invalid server URL"
            self.isLoading = false
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
            self.error = "Failed to serialize request"
            self.isLoading = false
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = jsonData
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("text/event-stream", forHTTPHeaderField: "Accept")

        let delegate = SSEDelegate(service: self)
        self.delegate = delegate

        let session = URLSession(
            configuration: .default,
            delegate: delegate,
            delegateQueue: nil
        )
        self.session = session

        session.dataTask(with: req).resume()
    }

    private func encodeImage(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        return data.base64EncodedString()
    }

    // MARK: - SSE Event Handling

    func handleEvent(type: String, data: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            switch type {
            case "status":
                self.statusMessage = data

            case "routed":
                guard let jsonData = data.data(using: .utf8),
                      let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: String]
                else { return }

                self.routedPillar = BloomPillar(rawValue: obj["pillar"] ?? "")
                self.routedAction = obj["action"]

            case "result":
                guard let jsonData = data.data(using: .utf8) else { return }

                let decoder = JSONDecoder()
                // This is the magic line that fixes the mismatch:
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                do {
                    let decoded = try decoder.decode(BloomResponse.self, from: jsonData)
                    self.response = decoded
                    self.isLoading = false
                } catch {
                    print("Decoding error: \(error)") // This will show you exactly what field failed
                }

            case "error":
                guard let jsonData = data.data(using: .utf8),
                      let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: String]
                else { return }

                self.error = obj["error"]
                self.isLoading = false

            default:
                break
            }
        }
    }
}

// MARK: - SSE Delegate

private class SSEDelegate: NSObject, URLSessionDataDelegate {
    weak var service: BloomService?
    private var buffer: String = ""

    init(service: BloomService) {
        self.service = service
    }

  
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        guard let text = String(data: data, encoding: .utf8) else { return }
        buffer += text

        // SSE events are separated by double newlines
        while let range = buffer.range(of: "\n\n") {
            let eventString = String(buffer[..<range.upperBound])
            buffer.removeSubrange(..<range.upperBound) // Remove processed event from buffer
            parseEvent(eventString)
        }
    }

    private func parseEvent(_ raw: String) {
        var eventType: String = ""
        var eventData: String = ""

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

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        DispatchQueue.main.async { [weak self] in
            if let error = error {
                self?.service?.error = error.localizedDescription
            }
            self?.service?.isLoading = false
        }
    }
}
