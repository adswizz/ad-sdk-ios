//
//  ViewController.swift
//  BasicDVRRequestExample
//
//  Created by Adrian Manolache on 07.07.2021.
//

import UIKit
import AdswizzSDK
import AVFoundation

class ViewController: UIViewController {
    var streamManager: AdswizzAdStreamManager?
    let url = URL(string: "http://sdk.mobile.streaming.adswizz.com:8500/kissFM/playlist.m3u8")
    let adServer = "demo.deliveryengine.adswizz.com"
    var dvrPlayButtons = [UIButton]()
    let kViewTag = 101
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        createUI()
        
        isPlaying = false
        
        do {
            try createStreamManager()
        } catch {
            print("Error creating stream manager \(error)")
        }
    }
    
    func createStreamManager() throws {
        // Create a new stream manager
        streamManager = try AdswizzAdStreamManager.Builder()
            .with(adServer: adServer)               //Mandatory
            .with(httpProtocol: .https)             //Optional: defaults to https protocol for the ad server
            .with(companionZones: "")               //Optional: companion zone provided by a PIM
            .build()
        streamManager?.delegate = self
        
        // The SDK doesn't query information about dvr support from a stream. To be able to perform DVR, the user must explicitly mark a stream as such by adding the .dvr capability to the adstreammanagersettings object
        let settings = AdStreamManagerSettings()
        settings.addCapability(.dvr)
        streamManager?.adStreamManagerSettings = settings
    }
    
    @objc func playStopStream(button: UIButton) {
        guard let url = url else { return }
    
        if isPlaying {
            resetDVRButtonsBackground()
            streamManager?.stop()
        } else {
            try? streamManager?.play(with: url)
        }
        isPlaying = !isPlaying
    }
    
    @objc func pauseResumeStream(button: UIButton) {
        if isPaused {
            streamManager?.resume()
        } else {
            streamManager?.pause()
        }
        isPaused = !isPaused
    }
    
    private func updateUI(with metadata: DVRMetadata?) {
        guard let metadata = metadata else { return }
        (startLabel.viewWithTag(kViewTag) as? UITextField)?.text = "\(metadata.start)"
        (endLabel.viewWithTag(kViewTag) as? UITextField)?.text = "\(metadata.end)"
        (bufferLabel.viewWithTag(kViewTag) as? UILabel)?.text = "\(metadata.length)"
    }
    var showDVRUI: Bool = false {
        didSet {
            dvrStackView.isHidden = !showDVRUI
        }
    }
    var dvrMetadata: DVRMetadata? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.updateUI(with: self?.dvrMetadata)
            }
        }
    }
    var isPlaying: Bool = false {
        didSet {
            playStopButton.setTitle((!isPlaying ? "Play" : "Stop") + " stream", for: .normal)
            if !isPlaying {
                isPaused = false
            }
            showDVRUI = isPlaying
        }
    }
    var isPaused: Bool = false {
        didSet {
            pauseResumeButton.setTitle((!isPaused ? "Pause" : "Resume") + " stream", for: .normal)
        }
    }
    
    func styledButton() -> UIButton {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.black, for: .selected)
        return button
    }
    
    func styledTextfield() -> UITextField {
        let textField = UITextField()
        textField.layer.backgroundColor = UIColor.white.cgColor
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 0.0
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = false
        textField.layer.shadowRadius = 2.0
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        textField.layer.shadowOpacity = 1.0
        textField.layer.shadowRadius = 1.0
        return textField
    }
    
    lazy var verticalStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = UIStackView.spacingUseSystem
        return stack
    }()
    lazy var horizontalStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = UIStackView.spacingUseSystem
        return stack
    }()
    lazy var playStopButton: UIButton = {
        let button = styledButton()
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.titleLabel?.font = UIFont(descriptor: UIFontDescriptor.init(), size: 16)
        button.setTitle("Play stream", for: .normal)
        button.setTitle("Stop stream", for: .selected)
        button.addTarget(self, action: #selector(playStopStream(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    lazy var pauseResumeButton: UIButton = {
        let button = styledButton()
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.titleLabel?.font = UIFont(descriptor: UIFontDescriptor.init(), size: 16)
        button.setTitle("Pause stream", for: .normal)
        button.setTitle("Resume stream", for: .selected)
        button.addTarget(self, action: #selector(pauseResumeStream(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    func addInfoLabel(stackView: UIStackView, text: String) -> UIStackView {
        let infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.text = text
        infoLabel.font = UIFont(name: "Arial", size: 12)
        infoLabel.numberOfLines = 0
        infoLabel.textColor = .black

        let verticalStackView = UIStackView(arrangedSubviews: [infoLabel, stackView])
        verticalStackView.distribution = .fillProportionally
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 10
        
        return verticalStackView
    }
    
    func labelAndTextFieldView(labelText: String, textFieldText: String, descriptionLabel: String) -> UIStackView {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = labelText
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let textField = styledTextfield()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = textFieldText
        textField.tag = kViewTag
        textField.textAlignment = .right
        //textField.isUserInteractionEnabled = false
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        let stackView = UIStackView(arrangedSubviews: [label, textField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return addInfoLabel(stackView: stackView, text: descriptionLabel)
    }
    
    func labelAndLabelView(labelText: String, secondLabelText: String, descriptionLabel: String) -> UIStackView {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = labelText
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let label2 =  UILabel()
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.text = secondLabelText
        label2.tag = kViewTag
        label2.textAlignment = .right

        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        let stackView = UIStackView(arrangedSubviews: [label, label2])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return addInfoLabel(stackView: stackView, text: descriptionLabel)
    }
    
    lazy var startLabel: UIStackView = {
        return labelAndTextFieldView(labelText: "Start: ", textFieldText: "-1", descriptionLabel: "DVRMetadata.start : Contains the first valid unix timestamp in milli the user can perform DVR at.")
    }()
    lazy var endLabel: UIStackView = {
        return labelAndTextFieldView(labelText: "End: ", textFieldText: "-1", descriptionLabel: "DVRMetadata.end : Contains last first valid unix timestamp in milli the user can perform DVR at.")
    }()
    lazy var bufferLabel: UIStackView = {
        return labelAndLabelView(labelText: "Buffer: ", secondLabelText: "-1", descriptionLabel: "DVRMetadata.length : The maximum capacity of the sound buffer stored for DVR purposes")
    }()
    lazy var playFromTimestampStackView: UIStackView = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "DVR supports play from an arbitrary timestamp. Input any UNIX time in milli and press Play it to hear sound from that position in time."
        label.numberOfLines = 0
        label.font = UIFont(name: "Arial", size: 12.0)
        let textField = styledTextfield()
        textField.text = "0"
        textField.keyboardType = .numberPad
        textField.tag = kViewTag
        textField.textAlignment = .right
        let button = styledButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(playFromTimestamp(button:)), for: .touchUpInside)
        button.setTitle("Play it!", for: .normal)
        dvrPlayButtons.append(button)
        let verticalStackView = UIStackView(arrangedSubviews: [label, textField, button])
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.distribution = .fillProportionally
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 10
        return verticalStackView
    }()
    lazy var dvrStackView: UIStackView = {
        let startEndBufferStackView = UIStackView()
        let insets = UIEdgeInsets(top: 10, left: 10, bottom: -10, right: -10)
        startEndBufferStackView.addArrangedSubview(startLabel, withMargin: insets)
        startEndBufferStackView.addArrangedSubview(endLabel, withMargin: insets)
        startEndBufferStackView.addArrangedSubview(bufferLabel, withMargin: insets)
        
        startEndBufferStackView.translatesAutoresizingMaskIntoConstraints = false
        startEndBufferStackView.axis = .vertical
        startEndBufferStackView.spacing = 8
 
        startEndBufferStackView.addArrangedSubview(playFromTimestampStackView, withMargin: insets)
        
        startEndBufferStackView.addArrangedSubview(showsStackView, withMargin: insets)
        
        return startEndBufferStackView
    }()
    lazy var showsStackView: UIStackView = {
        let buttons = (0 ..< 4).map { (index: Int) -> UIButton in
            let button = styledButton()
            button.tag = index
            button.setTitle("Show \(index + 1)", for: .normal)
            button.addTarget(self, action: #selector(playShow(button:)), for: .touchUpInside)
            return button
        }
        dvrPlayButtons += buttons
        
        let infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.text = "Each of the following buttons will perform DVR at a different location between the start and end positions. Starting timestamps are set at 0%, 25%, 50% and 75%, calculated as follows: position = start + (end - start) * percent."
        infoLabel.numberOfLines = 0
        infoLabel.font = UIFont(name: "Arial", size: 12.0)
        infoLabel.textColor = .black
        
        let horizontalStackView = UIStackView(arrangedSubviews: buttons)
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.spacing = 10
        
        let verticalStackView = UIStackView(arrangedSubviews: [infoLabel, horizontalStackView])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 8
        verticalStackView.distribution = .fill
        
        return verticalStackView
    }()
    
    @objc func playFromTimestamp(button: UIButton) {
        resetDVRButtonsBackground()
        button.backgroundColor = .systemGreen
        
        guard let url = url else { return }
        let timestamp = Int((playFromTimestampStackView.viewWithTag(kViewTag) as? UITextField)?.text ?? "") ?? 0
        streamManager?.stop()
        do {
            try streamManager?.play(with: url, timestamp: NSNumber(value: timestamp))
        } catch {
            print("Error \(error) playing stream \(url) with dvr \(timestamp)")
        }
    }
    
    private func resetDVRButtonsBackground() {
        dvrPlayButtons.forEach {
            $0.backgroundColor = .systemBlue
        }
    }
    
    @objc func playShow(button: UIButton) {
        let index = button.tag
        resetDVRButtonsBackground()
        button.backgroundColor = .systemGreen
        
        guard let url = url, let metadata = dvrMetadata else { return }
        let start = metadata.start
        let end = metadata.end
        let interval = (end - start) / 4 * index
        let timestamp = Int(start + interval)
        (playFromTimestampStackView.viewWithTag(kViewTag) as? UITextField)?.text = "\(timestamp)"
        print("DVR FROM timestamp=\(timestamp)")
        streamManager?.stop()
        do {
            try streamManager?.play(with: url, timestamp: NSNumber(value: timestamp))
        } catch {
            print("Error \(error) playing stream \(url) with dvr \(timestamp)")
        }
    }
        
    func createUI() {
        title = "DVR Streaming"

        horizontalStackView.addArrangedSubview(playStopButton)
        horizontalStackView.addArrangedSubview(pauseResumeButton)
        
        view.addSubview(verticalStackView)
        verticalStackView.addSubview(dvrStackView)
        verticalStackView.addSubview(horizontalStackView)
     
        NSLayoutConstraint.activate([
            verticalStackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16.0),
            verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            verticalStackView.heightAnchor.constraint(equalToConstant: 550),
            
            dvrStackView.heightAnchor.constraint(equalToConstant: 500),
            dvrStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dvrStackView.topAnchor.constraint(equalTo: verticalStackView.topAnchor),
            dvrStackView.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor),
            
            horizontalStackView.heightAnchor.constraint(equalToConstant: 45),
            horizontalStackView.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor),
            horizontalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: verticalStackView.bottomAnchor)
        ])
    }
    
}

extension ViewController: AdStreamManagerDelegate {
    func adStreamManager(_ adstreamManager: AdStreamManager, didReceive dvrMetadata: DVRMetadata?) {
        self.dvrMetadata = dvrMetadata
        print("dvrMetadata=\(String(describing: dvrMetadata))")
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, willStartPlaying url: URL) {
        
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, adBreakStarted manager: AdManager) {
        
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, stateChanged state: MediaPlayerStatus) {
        
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, adBreakEnded manager: AdManager) {
        
    }
    
    func adStreamManager(_ adstreamManager: AdStreamManager, metadataChanged metadata: [AVMetadataItem]) {
        
    }
    
    func adStreamManagerWillReconnect(_ adstreamManager: AdStreamManager) {
        
    }
    
    func adStreamManagerPlayerShouldPause(_ adstreamManager: AdStreamManager) {
        
    }
    
    func adStreamManagerPlayerShouldResume(_ adstreamManager: AdStreamManager) {
        
    }
}

extension UIStackView {

    func addArrangedSubview(_ v:UIView, withMargin m:UIEdgeInsets )
    {
        let containerForMargin = UIView()
        containerForMargin.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: containerForMargin.topAnchor, constant:m.top ),
            v.bottomAnchor.constraint(equalTo: containerForMargin.bottomAnchor, constant: m.bottom ),
            v.leftAnchor.constraint(equalTo: containerForMargin.leftAnchor, constant: m.left),
            v.rightAnchor.constraint(equalTo: containerForMargin.rightAnchor, constant: m.right)
        ])
        containerForMargin.backgroundColor = .lightGray
        containerForMargin.layer.cornerRadius = 8
        containerForMargin.layer.masksToBounds = true
        addArrangedSubview(containerForMargin)
    }
}
