import Foundation

import AVKit

class AudioPlayer : NSObject, AVAudioPlayerDelegate {
    private var seekToStart = true
    
    private var timer: Timer?
    private var player: AVAudioPlayer?
    var plugin : SwiftAudioWaveformsPlugin
    var playerKey :String
    init(plugin : SwiftAudioWaveformsPlugin,playerKey : String){
        self.plugin = plugin
        self.playerKey = playerKey
    }
    
    
    func preparePlayer(path: String?,volume: Double?,result:  @escaping FlutterResult){
            if(!(path ?? "").isEmpty){
                let audioUrl = URL.init(fileURLWithPath: path!)
                player = try! AVAudioPlayer(contentsOf: audioUrl)
                player?.prepareToPlay()
                player?.volume = Float(volume ?? 1.0)
                result(true)
            }else {
                result(FlutterError(code: Constants.audioWaveforms, message: "Audio file path can't be empty or null", details: nil))
            }
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer,
                                     successfully flag: Bool){
            if(seekToStart){
                player.currentTime = 0
            } else {
                    player.currentTime = player.duration
                //TODO: 
                plugin.flutterChannel.invokeMethod(Constants.onDidFinishPlayingAudio, arguments: [Constants.isPlayindFinished : true, Constants.playerKey: playerKey])
                    player.stop()
            }
        
    }
    
    func startPlyer(result:  @escaping FlutterResult,seekToStart:Bool?){
            self.seekToStart = seekToStart ?? true
            player?.play()
            player?.delegate = self
            startListening()
            result(true)
    }
    
    func pausePlayer(result:  @escaping FlutterResult){
            stopListening()
            player?.pause()
            result(true)
    }
    
    func stopPlayer(result:  @escaping FlutterResult){
            stopListening()
            player?.stop()
            player = nil
            timer = nil
            result(true)
    }
    
    
    func getDuration(_ type:DurationType,_ result:  @escaping FlutterResult) throws {
            if type == .Current {
                let ms = (player?.currentTime ?? 0) * 1000
                result(Int(ms))
            }else{
                let ms = (player?.duration ?? 0) * 1000
                result(Int(ms))
            }
    }
    
    func setVolume(_ volume: Double?,_ result : @escaping FlutterResult) {
            player?.volume = Float(volume ?? 1.0)
            result(true)
    }
    
    func seekTo(_ time: Int?,_ result : @escaping FlutterResult) {
            player?.currentTime = Double(time!/1000)
            result(true)
    }
    
    func startListening(){
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: {_ in
            let ms = (self.player?.currentTime ?? 0) * 1000
            self.plugin.onCurrentDuration(duration: Int(ms),playerKey: self.playerKey)
        })
    }
    
    func stopListening(){
        timer?.invalidate()
        timer = nil
    }
}
