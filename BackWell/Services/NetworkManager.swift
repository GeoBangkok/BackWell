//
//  NetworkManager.swift
//  SkinWell
//
//  Network connectivity and error handling
//

import Foundation
import Network
import SwiftUI
import Combine

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()

    @Published var isConnected = true
    @Published var connectionType = NWInterface.InterfaceType.wifi

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        startMonitoring()
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied

                if let interface = path.availableInterfaces.first {
                    self.connectionType = interface.type
                }
            }
        }

        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    func checkConnectivity() -> Bool {
        return isConnected
    }
}

// MARK: - Enhanced Error Handling

struct APIErrorHandler {
    static func handleError(_ error: Error) -> (title: String, message: String) {
        if let apiError = error as? APIError {
            switch apiError {
            case .invalidURL:
                return ("Configuration Error", "The service is temporarily unavailable. Please try again later.")

            case .invalidResponse:
                return ("Connection Error", "Unable to process the response. Please check your connection and try again.")

            case .httpError(let statusCode):
                switch statusCode {
                case 401:
                    return ("Authentication Error", "Your session has expired. Please restart the app.")
                case 403:
                    return ("Access Denied", "You don't have permission to access this feature.")
                case 429:
                    return ("Too Many Requests", "Please wait a moment before trying again.")
                case 500...599:
                    return ("Server Error", "Our servers are experiencing issues. Please try again later.")
                default:
                    return ("Error", "Something went wrong (Error \(statusCode)). Please try again.")
                }

            case .parsingError:
                return ("Processing Error", "Unable to analyze your image. Please try a different photo.")

            case .noData:
                return ("No Data", "No results were returned. Please try again.")

            case .noConnection:
                return ("No Internet", "Please check your internet connection and try again.")
            }
        } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
            return ("No Internet Connection", "Please check your internet connection and try again.")
        } else if (error as NSError).code == NSURLErrorTimedOut {
            return ("Request Timeout", "The request took too long. Please try again.")
        } else {
            return ("Unexpected Error", "An unexpected error occurred: \(error.localizedDescription)")
        }
    }
}

// MARK: - Loading State Manager

class LoadingStateManager: ObservableObject {
    @Published var isLoading = false
    @Published var loadingMessage = ""
    @Published var progress: Double = 0

    func startLoading(message: String = "Processing...") {
        DispatchQueue.main.async {
            self.isLoading = true
            self.loadingMessage = message
            self.progress = 0
        }
    }

    func updateProgress(_ value: Double, message: String? = nil) {
        DispatchQueue.main.async {
            self.progress = value
            if let msg = message {
                self.loadingMessage = msg
            }
        }
    }

    func stopLoading() {
        DispatchQueue.main.async {
            self.isLoading = false
            self.loadingMessage = ""
            self.progress = 0
        }
    }
}

// MARK: - Retry Logic

struct RetryConfiguration {
    let maxAttempts: Int
    let delay: TimeInterval
    let backoffMultiplier: Double

    static let `default` = RetryConfiguration(
        maxAttempts: 3,
        delay: 1.0,
        backoffMultiplier: 2.0
    )
}

class RetryManager {
    static func retry<T>(
        operation: @escaping () async throws -> T,
        config: RetryConfiguration = .default
    ) async throws -> T {
        var lastError: Error?
        var delay = config.delay

        for attempt in 1...config.maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                print("Attempt \(attempt) failed: \(error.localizedDescription)")

                if attempt < config.maxAttempts {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    delay *= config.backoffMultiplier
                }
            }
        }

        throw lastError ?? APIError.noData
    }
}

// MARK: - Enhanced Loading View

struct EnhancedLoadingView: View {
    let message: String
    let progress: Double?
    @State private var animationAmount = 0.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 25) {
                // Animated logo
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.purple)
                    .rotationEffect(.degrees(animationAmount))
                    .onAppear {
                        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                            animationAmount = 360
                        }
                    }

                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                if let progress = progress {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .frame(width: 200)
                        .scaleEffect(x: 1, y: 2)

                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Theme.purple)
                    .shadow(color: Theme.purple.opacity(0.5), radius: 20, x: 0, y: 10)
            )
        }
    }
}

// MARK: - Error Alert View

struct ErrorAlertView: View {
    let title: String
    let message: String
    let onRetry: (() -> Void)?
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(Theme.error)

            Text(title)
                .font(.headline)
                .foregroundColor(Theme.textPrimary)

            Text(message)
                .font(.body)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 15) {
                Button(action: onDismiss) {
                    Text("Cancel")
                        .font(.body)
                        .foregroundColor(Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                }

                if let onRetry = onRetry {
                    Button(action: onRetry) {
                        Text("Retry")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.purple)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding(25)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Theme.shadow, radius: 10, x: 0, y: 5)
        .padding(.horizontal, 30)
    }
}

// MARK: - Cache Manager for Offline Support

class CacheManager {
    static let shared = CacheManager()
    private let cacheDirectory: URL

    private init() {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("SkinWellCache")

        // Create cache directory if it doesn't exist
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func cacheAnalysis(_ result: SkinScanResult, for key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(result) {
            let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
            try? data.write(to: fileURL)
        }
    }

    func getCachedAnalysis(for key: String) -> SkinScanResult? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        guard let data = try? Data(contentsOf: fileURL) else { return nil }

        let decoder = JSONDecoder()
        return try? decoder.decode(SkinScanResult.self, from: data)
    }

    func clearCache() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}