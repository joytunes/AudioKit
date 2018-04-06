    //
    //  ViewController.swift
    //  macOSDevelopment
    //
    //  Created by Aurelius Prochazka, revision history on Github.
    //  Copyright © 2018 AudioKit. All rights reserved.
    //
    
    import AudioKit
    import AudioKitUI
    import Cocoa
    
    class ViewController: NSViewController {
        
        // Default controls
        @IBOutlet var playButton: NSButton!
        @IBOutlet var sliderLabel1: NSTextField!
        @IBOutlet var slider1: NSSlider!
        @IBOutlet var sliderLabel2: NSTextField!
        @IBOutlet var slider2: NSSlider!
        @IBOutlet var slider1Value: NSTextField!
        @IBOutlet var slider2Value: NSTextField!
        @IBOutlet var inputSource: NSPopUpButton!
        @IBOutlet var chooseAudioButton: NSButton!
        @IBOutlet var inputSourceInfo: NSTextField!
        @IBOutlet var loopButton: NSButton!
        
        var openPanel: NSOpenPanel?
        
        var audioTitle: String {
            guard let av = player?.audioFile else { return "" }
            return av.url.lastPathComponent
        }
        
        // Define components ⏦ ⏚ ⎍ ⍾ ⚙︎
        var speechSynthesizer = AKSpeechSynthesizer()
        var booster = AKBooster()
        var player: AKPlayer?
        var node: AKNode? {
            didSet {
                updateInfo()
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
        }
        
        @IBAction func start(_ sender: Any) {
            booster.gain = slider1.doubleValue
            AudioKit.output = booster
            do {
                try AudioKit.start()
            } catch {
                AKLog("AudioKit did not start!")
            }
            initspeechSynthesizer()
            handleUpdateParam(slider1)
            handleUpdateParam(slider2)
        }
        
        private func updateInfo() {
            chooseAudioButton.isEnabled = node == player
            //inputSourceInfo.stringValue = node == player ? "🔊 \(audioTitle)" : "🔊 ⏦ \(speechSynthesizer.frequency) hz"
        }
        private func initspeechSynthesizer() {
            guard node != speechSynthesizer else { return }
            booster.disconnectInput()
            speechSynthesizer >>> booster
            node = speechSynthesizer
            //speechSynthesizer.stop()
        }
        
        private func initPlayer() {
            if player == nil {
                chooseAudio(chooseAudioButton)
                return
            }
            updateInfo()
            guard node != player else { return }
            guard let player = player else { return }
            
            booster.disconnectInput()
            player >>> booster
            node = player
        }
        
        @IBAction func changeInput(_ sender: NSPopUpButton) {
            guard let title = sender.selectedItem?.title else { return }
            if title == "speechSynthesizer" {
                initspeechSynthesizer()
            } else if title == "Player" {
                initPlayer()
            }
        }
        
        @IBAction func choosespeechSynthesizer(_ sender: Any) {
            initspeechSynthesizer()
        }
        
        @IBAction func chooseAudio(_ sender: Any) {
            guard let window = view.window else { return }
            if openPanel == nil {
                openPanel = NSOpenPanel()
                openPanel!.message = "Open Audio File"
                openPanel!.allowedFileTypes = EZAudioFile.supportedAudioFileTypes() as? [String]
            }
            guard let openPanel = openPanel else { return }
            openPanel.beginSheetModal(for: window, completionHandler: { response in
                if response == NSApplication.ModalResponse.OK {
                    if let url = openPanel.url {
                        self.open(url: url)
                    }
                }
            })
        }
        
        @IBAction func setLoopState(_ sender: NSButton) {
            player?.isLooping = sender.state == .on
        }
        
        /// open an audio URL for playing
        func open(url: URL) {
            if player == nil {
                player = AKPlayer(url: url)
                player?.completionHandler = handleAudioComplete
                player?.isLooping = loopButton.state == .on
                player?.bufferLooping = false
            } else {
                do {
                    try player?.load(url: url)
                } catch {}
            }
            initPlayer()
            
            AKLog("Opened \(url.lastPathComponent)")
        }
        
        @IBAction func handlePlay(_ sender: NSButton) {
            let state = sender.state == .on
            if node == speechSynthesizer {
                speechSynthesizer.sayHello()
                //state ? speechSynthesizer.start() : speechSynthesizer.stop()
                
            } else if node == player {
                state ? player?.resume() : player?.pause()
            }
        }
        
        private func handleAudioComplete() {
            if !(player?.isLooping ?? false) {
                playButton?.state = .off
            }
        }
        
        @IBAction func handleUpdateParam(_ sender: NSSlider) {
            if sender == slider1 {
                booster.gain = slider1.doubleValue
                slider1Value.stringValue = String(describing: roundTo(booster.gain, decimalPlaces: 3))
            } else if sender == slider2 {
                booster.rampTime = slider2.doubleValue
                slider2Value.stringValue = String(describing: roundTo(booster.rampTime, decimalPlaces: 3))
            }
        }
        
        private func roundTo(_ value: Double, decimalPlaces: Int) -> Double {
            let decimalValue = pow(10.0, Double(decimalPlaces))
            return round(value * decimalValue) / decimalValue
        }
        
    }
