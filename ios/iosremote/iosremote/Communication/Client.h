/*
 * This file is part of the LibreOffice project.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

#import <Foundation/Foundation.h>
#import "Server.h"
#import "CommunicationManager.h"
#import "Receiver.h"

@interface Client : NSObject

-(void) connect;

- (id) initWithServer:(Server*)server
            managedBy:(CommunicationManager*)manager
        interpretedBy:(Receiver*)receiver;

-(void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode;

@end