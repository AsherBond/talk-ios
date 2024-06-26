/**
 * @copyright Copyright (c) 2020 Marcel Müller <marcel-mueller@gmx.de>
 *
 * @author Marcel Müller <marcel-mueller@gmx.de>
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
#import <UIKit/UIKit.h>

#import "NCMessageParameter.h"

@class NCChatFileStatus;

NS_ASSUME_NONNULL_BEGIN

@interface NCMessageFileParameter : NCMessageParameter

@property (nonatomic, strong) NSString * _Nullable path;
@property (nonatomic, strong) NSString *mimetype;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, assign) BOOL previewAvailable;
@property (nonatomic, strong, nullable) NCChatFileStatus *fileStatus;
@property (nonatomic, assign) int previewImageHeight;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;

@end

NS_ASSUME_NONNULL_END
