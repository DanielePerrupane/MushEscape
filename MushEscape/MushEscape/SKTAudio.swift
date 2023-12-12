//
//  SKTAudio.swift
//  MushEscape
//
//  Created by Raffaele Marino  on 12/12/23.
//

import AVFoundation

class SKTAudio {
    static let shared = SKTAudio()
    
    var bgMusic: AVAudioPlayer?
    
    func playBGMusic(_ fileNamed: String) {
        if !SKTAudio.musicEnabled { return }
        
        guard let url = Bundle.main.url(forResource: fileNamed, withExtension: nil) else { return }
        
        do {
            bgMusic = try AVAudioPlayer(contentsOf: url)
            bgMusic?.numberOfLoops = -1
            bgMusic?.prepareToPlay()
            bgMusic?.play()
        } catch {
            print("Error: \(error.localizedDescription)")
            bgMusic = nil
        }
    }
    
    func stopBGMusic() {
        bgMusic?.stop()
    }
    
    static let keyMusic = "keyMusic"
    static var musicEnabled: Bool = {
        return !UserDefaults.standard.bool(forKey: keyMusic)
    }() {
        didSet {
            let value = !musicEnabled
            UserDefaults.standard.set(value, forKey: keyMusic)
            
            if value {
                SKTAudio.shared.stopBGMusic()
            }
        }
    }
}
