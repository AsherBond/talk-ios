/**
 * @copyright Copyright (c) 2020 Ivan Sein <ivan@nextcloud.com>
 *
 * @author Ivan Sein <ivan@nextcloud.com>
 *
 * @license GNU GPL version 3 or any later version
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import <Foundation/Foundation.h>

#import "NCAPIController.h"
#import "NCRoom.h"
#import "NCChatController.h"
#import "CallViewController.h"

// Room
extern NSString * const NCRoomsManagerDidJoinRoomNotification;
extern NSString * const NCRoomsManagerDidLeaveRoomNotification;
extern NSString * const NCRoomsManagerDidUpdateRoomsNotification;
extern NSString * const NCRoomsManagerDidUpdateRoomNotification;
// Call
extern NSString * const NCRoomsManagerDidStartCallNotification;

typedef void (^UpdateRoomsCompletionBlock)(NSArray *roomsWithNewMessages, TalkAccount *account, NSError *error);
typedef void (^UpdateRoomsAndChatsCompletionBlock)(NSError *error);
typedef void (^SendOfflineMessagesCompletionBlock)(void);

@class ChatViewController;

@interface NCRoomController : NSObject

@property (nonatomic, strong) NSString *userSessionId;
@property (nonatomic, assign) BOOL inCall;
@property (nonatomic, assign) BOOL inChat;

@end

@interface NCRoomsManager : NSObject

@property (nonatomic, strong) ChatViewController *chatViewController;
@property (nonatomic, strong) CallViewController *callViewController;

// START - Public for swift migration
@property (nonatomic, strong) NSMutableDictionary *activeRooms; //roomToken -> roomController
@property (nonatomic, strong, nullable) NSString *joiningRoomToken;
@property (nonatomic, strong, nullable) NSString *joiningSessionId;
@property (nonatomic, assign) NSInteger joiningAttempts;
@property (nonatomic, strong, nullable) NSURLSessionTask *joinRoomTask;
@property (nonatomic, strong, nullable) NSURLSessionTask *leaveRoomTask;
@property (nonatomic, strong) NSString *upgradeCallToken;
@property (nonatomic, strong) NSString *pendingToStartCallToken;
@property (nonatomic, assign) BOOL pendingToStartCallHasVideo;
@property (nonatomic, strong) NSDictionary *highlightMessageDict;

- (void)checkForPendingToStartCalls;
// END

+ (instancetype)sharedInstance;
// Room
- (void)updateRoomsAndChatsUpdatingUserStatus:(BOOL)updateStatus onlyLastModified:(BOOL)onlyLastModified withCompletionBlock:(UpdateRoomsAndChatsCompletionBlock)block;
- (void)updateRoomsUpdatingUserStatus:(BOOL)updateStatus onlyLastModified:(BOOL)onlyLastModified;
- (void)updateRoom:(NSString *)token withCompletionBlock:(GetRoomCompletionBlock)block;
- (void)updatePendingMessage:(NSString *)message forRoom:(NCRoom *)room;
- (void)updateLastReadMessage:(NSInteger)lastReadMessage forRoom:(NCRoom *)room;
- (void)updateLastMessage:(NCChatMessage *)message withNoUnreadMessages:(BOOL)noUnreadMessages forRoom:(NCRoom *)room;
- (void)updateLastCommonReadMessage:(NSInteger)messageId forRoom:(NCRoom *)room;
// Chat
- (void)startChatInRoom:(NCRoom *)room;
- (void)leaveChatInRoom:(NSString *)token;
- (void)startChatWithRoomToken:(NSString *)token;
// Call
- (void)joinCallWithCallToken:(NSString *)token withVideo:(BOOL)video asInitiator:(BOOL)initiator recordingConsent:(BOOL)recordingConsent;
// Switch to
- (void)prepareSwitchToAnotherRoomFromRoom:(NSString *)token withCompletionBlock:(ExitRoomCompletionBlock)block;

@end
