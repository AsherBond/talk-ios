//
// SPDX-FileCopyrightText: 2023 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: GPL-3.0-or-later
//

import UIKit
import SDWebImage

@objcMembers class AvatarView: UIView, AvatarProtocol {

    private let userStatusSizePercentage = 0.38

    public let avatarImageView = AvatarImageView(frame: .zero)
    public let favoriteImageView = UIImageView()
    private let userStatusImageView = UIImageView()
    private let userStatusLabel = UILabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }

    private func commonInit() {
        self.addSubview(avatarImageView)
        self.addSubview(favoriteImageView)
        self.addSubview(userStatusImageView)
        self.addSubview(userStatusLabel)

        avatarImageView.contentMode = .scaleAspectFit
        favoriteImageView.contentMode = .scaleAspectFill
        userStatusImageView.contentMode = .center
        userStatusLabel.textAlignment = .center

        userStatusImageView.isHidden = true
        userStatusLabel.isHidden = true

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        favoriteImageView.translatesAutoresizingMaskIntoConstraints = false
        userStatusImageView.translatesAutoresizingMaskIntoConstraints = false
        userStatusLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            avatarImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            avatarImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            avatarImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),

            favoriteImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: userStatusSizePercentage),
            favoriteImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: userStatusSizePercentage),
            favoriteImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: 2),
            favoriteImageView.topAnchor.constraint(equalTo: topAnchor, constant: -4),

            userStatusImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: userStatusSizePercentage),
            userStatusImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: userStatusSizePercentage),
            userStatusImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: 2),
            userStatusImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2),

            userStatusLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: userStatusSizePercentage),
            userStatusLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: userStatusSizePercentage),
            userStatusLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 2),
            userStatusLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.clipsToBounds = true

        userStatusImageView.layer.cornerRadius = userStatusImageView.frame.height / 2
        userStatusImageView.clipsToBounds = true
    }

    public func prepareForReuse() {
        // Fix problem of rendering downloaded image in a reused cell
        avatarImageView.cancelCurrentRequest()
        avatarImageView.image = nil

        favoriteImageView.image = nil

        userStatusImageView.image = nil
        userStatusImageView.backgroundColor = .clear

        userStatusLabel.text = nil
    }

    func cancelCurrentRequest() {
        self.avatarImageView.cancelCurrentRequest()
    }

    // MARK: - Conversation avatars

    public func setAvatar(for room: NCRoom) {
        self.avatarImageView.setAvatar(for: room)
    }

    public func setGroupAvatar() {
        self.avatarImageView.setGroupAvatar()
    }

    public func setMailAvatar() {
        self.avatarImageView.setMailAvatar()
    }

    // MARK: - User avatars

    public func setActorAvatar(forMessage message: NCChatMessage, withAccount account: TalkAccount) {
        self.avatarImageView.setActorAvatar(forMessage: message, withAccount: account)
    }

    public func setActorAvatar(forId actorId: String?, withType actorType: String?, withDisplayName actorDisplayName: String?, withRoomToken roomToken: String?, using account: TalkAccount) {
        self.avatarImageView.setActorAvatar(forId: actorId, withType: actorType, withDisplayName: actorDisplayName, withRoomToken: roomToken, using: account)
    }

    // MARK: - User status

    public func setStatus(for room: NCRoom, with backgroundColor: UIColor) {
        if room.type == .oneToOne, let roomStatus = room.status {
            if roomStatus != "dnd", let roomStatusIcon = room.statusIcon {
                setUserStatusIcon(roomStatusIcon, with: backgroundColor)
            } else {
                setUserStatus(roomStatus, with: backgroundColor)
            }
        } else if room.isPublic {
            if let statusImage = UIImage(named: "link") {
                let diameter = statusImageSize(padding: 2)
                let size = CGSize(width: diameter, height: diameter)
                if let configuredImage = NCUtils.renderAspectImage(image: statusImage, ofSize: size, centerImage: true)?.withRenderingMode(.alwaysTemplate) {
                    setUserStatusImage(configuredImage, with: backgroundColor)
                    userStatusImageView.tintColor = .label
                }
            }
        } else if room.isFederated {
            if let statusImage = statusImageWith(name: "globe", color: .label, padding: 3) {
                setUserStatusImage(statusImage, with: backgroundColor)
            }
        }
    }

    private func setUserStatus(_ userStatus: String, with backgroundColor: UIColor) {
        if userStatus == "online" {
            if let statusImage = statusImageWith(name: "checkmark.circle.fill", color: .systemGreen, padding: 2) {
                setUserStatusImage(statusImage, with: backgroundColor)
            }
        } else if userStatus == "away" {
            if let statusImage = statusImageWith(name: "clock.fill", color: .systemYellow, padding: 2) {
                setUserStatusImage(statusImage, with: backgroundColor)
            }
        } else if userStatus == "busy" {
            if let statusImage = statusImageWith(name: "circle.fill", color: .systemRed, padding: 2) {
                setUserStatusImage(statusImage, with: backgroundColor)
            }
        } else if userStatus == "dnd" {
            var dndImageName = "minus.circle.fill"
            if #available(iOS 16.1, *) {
                dndImageName = "wrongwaysign.fill"
            }
            if let statusImage = statusImageWith(name: dndImageName, color: .systemRed, secondaryColor: .white, padding: 2) {
                setUserStatusImage(statusImage, with: backgroundColor)
            }
        }
    }

    private func setUserStatusImage(_ userStatusImage: UIImage, with backgroundColor: UIColor) {
        userStatusImageView.backgroundColor = backgroundColor
        userStatusImageView.image = userStatusImage

        userStatusImageView.isHidden = false
        userStatusLabel.isHidden = true
    }

    private func setUserStatusIcon(_ userStatusIcon: String, with backgroundColor: UIColor) {
        userStatusLabel.text = userStatusIcon
        userStatusLabel.font = .systemFont(ofSize: userStatusLabel.frame.height - 6)

        userStatusImageView.isHidden = true
        userStatusLabel.isHidden = false
    }

    private func statusImageWith(name: String, color: UIColor, secondaryColor: UIColor? = nil, padding: CGFloat) -> UIImage? {
        let sizeConfiguration = UIImage.SymbolConfiguration(pointSize: statusImageSize(padding: padding))

        // Multicolor image
        if let secondaryColor {
            let colorConfiguration = UIImage.SymbolConfiguration(paletteColors: [secondaryColor, color])
            let combinedSymbolConfiguration = colorConfiguration.applying(sizeConfiguration)
            if let statusImage = UIImage(systemName: name)?
                .applyingSymbolConfiguration(combinedSymbolConfiguration) {
                return statusImage
            }
        }

        // Single color image
        if let statusImage = UIImage(systemName: name)?
            .withTintColor(color, renderingMode: .alwaysOriginal)
            .applyingSymbolConfiguration(sizeConfiguration) {
            return statusImage
        }

        return nil
    }

    private func statusImageSize(padding: CGFloat) -> CGFloat {
        return self.frame.size.height * userStatusSizePercentage - padding * 2
    }
}
