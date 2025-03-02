/**
 * SPDX-FileCopyrightText: 2020 Nextcloud GmbH and Nextcloud contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "ReplyMessageView.h"

#import "SLKUIConstants.h"

#import "NCAppBranding.h"
#import "NCChatMessage.h"
#import "QuotedMessageView.h"

#import "NextcloudTalk-Swift.h"

@interface ReplyMessageView ()
@property (nonatomic, strong) UIView *quoteContainerView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *hConstraints;
@end

@implementation ReplyMessageView
@synthesize visible = _visible;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureSubviews];
    }
    return self;
}

- (void)configureSubviews
{
    self.backgroundColor = [NCAppBranding backgroundColor];
    
    [self addSubview:self.quoteContainerView];
    [self addSubview:self.cancelButton];
    [self.layer addSublayer:self.topBorder];

    [_quoteContainerView addSubview:self.quotedMessageView];
    
    NSDictionary *views = @{
        @"quoteContainerView": self.quoteContainerView,
        @"quotedMessageView": self.quotedMessageView,
        @"cancelButton": self.cancelButton
    };
    
    self.hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[quoteContainerView]-4-[cancelButton(44)]-4-|" options:0 metrics:nil views:views];
    [self addConstraints:self.hConstraints];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[quotedMessageView(quoteContainerView)]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[quoteContainerView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cancelButton]|" options:0 metrics:nil views:views]];

    // Center the quotedMessageView inside the container view (if we add a padding in the layout above, we need to break constraints when height is 0)
    NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:self.quotedMessageView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.quoteContainerView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1.0f
                                                                         constant:0.0f];

    [self.quoteContainerView addConstraints:@[centerConstraint]];
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.topBorder.frame = CGRectMake(0, 0, self.bounds.size.width, 1);
}

- (CGSize)intrinsicContentSize
{
    // This will indicate the size of the view when calling systemLayoutSizeFittingSize in SLKTextViewController
    // QuoteMessageView(60) + 2*Padding(8)
    return CGSizeMake(UIViewNoIntrinsicMetric, 76);
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    if (_topBorder && [self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
        // We use a CGColor so we loose the automatic color changing of dynamic colors -> update manually
        _topBorder.backgroundColor = [UIColor systemGray6Color].CGColor;
    }
}


#pragma mark - SLKReplyViewProtocol

- (void)dismiss
{
    if (self.isVisible) {
        self.visible = NO;
    }
}


#pragma mark - Getters

- (UIView *)quoteContainerView
{
    if (!_quoteContainerView) {
        _quoteContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _quoteContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _quoteContainerView;
}


- (QuotedMessageView *)quotedMessageView
{
    if (!_quotedMessageView) {
        _quotedMessageView = [[QuotedMessageView alloc] init];
        _quotedMessageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _quotedMessageView;
}

- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [_cancelButton setImage:[UIImage systemImageNamed:@"xmark.circle"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (CALayer *)topBorder
{
    if (!_topBorder) {
        _topBorder = [CAGradientLayer layer];
        _topBorder.frame = CGRectMake(0.0, 0.0, self.frame.size.width, 1);
        _topBorder.backgroundColor = [UIColor systemGray6Color].CGColor;
    }
    return _topBorder;
}


#pragma mark - ReplyMessageView

- (void)presentReplyViewWithMessage:(NCChatMessage *)message withUserId:(NSString *)userId
{
    if (!message) {
        return;
    }
    
    self.message = message;
    self.quotedMessageView.actorLabel.text = ([message.actorDisplayName isEqualToString:@""]) ? NSLocalizedString(@"Guest", nil) : message.actorDisplayName;
    self.quotedMessageView.messageLabel.text = message.parsedMarkdownForChat.string;
    self.quotedMessageView.highlighted = [message isMessageFrom:userId];

    TalkAccount *account = message.account;
    if (account) {
        [self.quotedMessageView.avatarView setActorAvatarForMessage:message withAccount:account];
    }

    [self.cancelButton setHidden:NO];

    // Reset button size to 44 in case it was hidden before
    self.hConstraints[2].constant = 44;

    self.visible = YES;
}

- (void)hideCloseButton
{
    [self.cancelButton setHidden:YES];
    // With 2*4 padding (left and right to the button) we add 8 to have 16 as we have on the left side of the quoteView
    self.hConstraints[2].constant = 8;
}


@end
