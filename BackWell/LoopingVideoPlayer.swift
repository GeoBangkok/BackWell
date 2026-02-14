//
//  LoopingVideoPlayer.swift
//  SkinGlowing
//
//  Looping video background player

import SwiftUI
import AVKit
import AVFoundation

struct LoopingVideoPlayer: UIViewRepresentable {
    let videoName: String

    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(videoName: videoName)
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class LoopingPlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?

    init(videoName: String) {
        super.init(frame: .zero)

        // Load video from data asset
        guard let asset = NSDataAsset(name: videoName) else {
            print("Could not find video asset: \(videoName)")
            return
        }

        // Write to temp file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(videoName).mp4")

        do {
            try asset.data.write(to: tempURL)

            // Create player
            let playerItem = AVPlayerItem(url: tempURL)
            let player = AVQueuePlayer(playerItem: playerItem)
            playerLayer.player = player
            playerLayer.videoGravity = .resizeAspectFill

            // Create looper
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)

            // Start playing
            player.play()
            player.isMuted = true

            layer.addSublayer(playerLayer)
        } catch {
            print("Error loading video: \(error)")
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}