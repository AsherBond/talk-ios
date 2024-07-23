//
// SPDX-FileCopyrightText: 2022 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: GPL-3.0-or-later
//

import UIKit

@objcMembers class NCSplitViewPlaceholderViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = NSLocalizedString("Join a conversation or start a new one", comment: "")
        subtitleLabel.text = NSLocalizedString("Say hi to your friends and colleagues!", comment: "")
        logoImage.image = UIImage(named: "app-logo-callkit")?.withTintColor(UIColor.systemGray)

        adjustTheming()

        NotificationCenter.default.addObserver(self, selector: #selector(self.appStateChanged(notification:)), name: NSNotification.Name.NCAppStateHasChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.serverCapabilitiesUpdated(notification:)), name: NSNotification.Name.NCServerCapabilitiesUpdated, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        let roomsTableViewController = NCUserInterfaceController.sharedInstance().roomsTableViewController
        roomsTableViewController?.removeRoomSelection()
    }

    func adjustTheming() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: NCAppBranding.themeTextColor()]
        self.navigationController?.navigationBar.tintColor = NCAppBranding.themeTextColor()
        self.navigationController?.navigationBar.barTintColor = NCAppBranding.themeColor()
        self.navigationController?.navigationBar.isTranslucent = false

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: NCAppBranding.themeTextColor()]
        appearance.backgroundColor = NCAppBranding.themeColor()
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.compactAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
    }

    func appStateChanged(notification: Notification) {
        adjustTheming()
    }

    func serverCapabilitiesUpdated(notification: Notification) {
        adjustTheming()
    }
}
