// pune asta in locul originalului
//  ViewController.swift
//  TestAudioKitUI
//
//  Created by Cosmin Vlaicu on 31/03/2020.
//  Copyright © 2020 Cosmin Vlaicu. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class CustomTap: NSObject, EZAudioFFTDelegate {
    
    internal let bufferSize: UInt32 = 2048
    internal var fft: EZAudioFFT?
    
    /// Array of FFT data
    open var fftData = [Double](zeros: 1024)
    
    /// Initialze the FFT calculation on a given node
    ///
    /// - parameter input: Node on whose output the FFT will be computed
    ///
    public init(_ input: AKNode) {
        super.init()
        fft = EZAudioFFT(maximumBufferSize: vDSP_Length(bufferSize), sampleRate: Float(AKSettings.sampleRate), delegate: self)
        input.avAudioNode.installTap(onBus: 0, bufferSize: bufferSize, format: AudioKit.format) { [weak self] (buffer, time) -> Void in
            guard let strongSelf = self else { return }
            buffer.frameLength = strongSelf.bufferSize
            let offset = Int(buffer.frameCapacity - buffer.frameLength)
            let tail = buffer.floatChannelData?[0]
            strongSelf.fft!.computeFFT(withBuffer: &tail![offset],
                                       withBufferSize: strongSelf.bufferSize)
        }
    }
    
    /// Callback function for FFT computation
    @objc open func fft(_ fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        DispatchQueue.main.async { () -> Void in
            for i in 0..<1024 {
                self.fftData[i] = Double(fftData[i])
            }
        }
    }
}

class ViewController: UIViewController {
    
    let minimum: Double = 60
    let maximum: Double = 560

    var mic = AKMicrophone()
    var filter = AKLowPassFilter()
    var tracker: AKFrequencyTracker?
    var silence: AKBooster?
    var debugIncrement = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        mic = AKMicrophone()
        filter = AKLowPassFilter(mic)
        filter.cutoffFrequency = 1001
        filter.resonance = 998
        
        tracker = AKFrequencyTracker(filter)
        silence = AKBooster(tracker, gain: 0)
        
        AudioKit.output = silence
        
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        
        print("plm")
        sleep(5)
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
            print(self.tracker?.frequency)
            let timeInterval = NSDate().timeIntervalSince1970
            print(timeInterval)
                })

        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        do {
//            try AudioKit.start()
//        } catch {
//            AKLog("AudioKit did not start!")
//        }

//        mic.start()

//        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
//
//            for i in 0...510 {
//
//                let re = self.fftTap!.fftData[i]
//                let im = self.fftTap!.fftData[i + 1]
//                let normBinMag = 2.0 * sqrt(re * re + im * im)/self.FFT_SIZE
//                let amplitude = (20.0 * log10(normBinMag))
//
//                print("bin: \(i/2) \t ampl.: \(amplitude)")
//            }
//
//
//        })
    }
    



}



