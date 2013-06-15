// -*- Mode: ObjC; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
//
// This file is part of the LibreOffice project.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.


#import "CommunicationManager.h"
#import "Client.h"
#import "Server.h"
#import "CommandTransmitter.h"
#import "CommandInterpreter.h"
#import "libreoffice_sdremoteViewController.h"
#import <dispatch/dispatch.h>

@interface CommunicationManager()

@property (nonatomic, strong) Client* client;
@property (nonatomic, strong) CommandInterpreter* interpreter;
@property (nonatomic, strong) CommandTransmitter* transmitter;
@property (atomic, strong) NSMutableSet* servers;
@property (nonatomic, strong) id connectionConnectedObserver;
@property (nonatomic, strong) id connectionDisconnectedObserver;

@end

// Singlton Pattern
@implementation CommunicationManager

@synthesize client = _client;
@synthesize state = _state;
@synthesize interpreter = _interpreter;
@synthesize transmitter = _transmitter;
@synthesize servers = _servers;
@synthesize delegate = _delegate;
@synthesize connectionConnectedObserver = _connectionConnectedObserver;
@synthesize connectionDisconnectedObserver = _connectionDisconnectedObserver;

+ (CommunicationManager *)sharedComManager
{
    static CommunicationManager *sharedComManager = nil;
    
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedComManager = [[super allocWithZone:nil] init];
    });
    
    return sharedComManager;
}


- (void) connectionStatusHandler:(NSNotification *)note
{
    if([[note name] isEqualToString:@"connection.status.connected"]){
        NSLog(@"Connected");
        self.transmitter = [[CommandTransmitter alloc] initWithClient:self.client];
        self.state = CONNECTED;
        [self.delegate setPinLabelText:[NSString stringWithFormat:@"%@", [self getPairingPin]]];
    } else if ([[note name] isEqualToString:@"connection.status.disconnected"]){
        NSLog(@"Connection Failed");
        self.state = DISCONNECTED;
        [self.client disconnect];
    }
}

- (id) init
{
    self = [super init];
    self.state = DISCONNECTED;
    
    [[NSNotificationCenter defaultCenter]addObserver: self
                                            selector: @selector(connectionStatusHandler:)
                                                name: @"connection.status.connected"
                                              object: nil];
    [[NSNotificationCenter defaultCenter]addObserver: self
                                            selector: @selector(connectionStatusHandler:)
                                                name: @"connection.status.disconnected"
                                              object: nil];
    
    return self;
}



- (id) initWithExistingServers
{
    self = [self init];
    
    NSUserDefaults * userDefaluts = [NSUserDefaults standardUserDefaults];
    
    if(!userDefaluts)
        NSLog(@"userDefaults nil");
    
    NSData *dataRepresentingExistingServers = [userDefaluts objectForKey:@"ExistingServers"];
    if (dataRepresentingExistingServers != nil)
    {
        NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingExistingServers];
        if (oldSavedArray != nil)
            self.servers = [[NSMutableSet alloc] initWithArray:oldSavedArray];
        else
            self.servers = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void) connectToServer:(Server*)server
{
    [self.servers addObject:server];
    if (self.state == CONNECTING || self.state == CONNECTED) {
        return;
    } else {
            self.state = CONNECTING;
            [self.client disconnect];
            // initialise it with a given server
            self.client = [[Client alloc]initWithServer:server managedBy:self interpretedBy:self.interpreter];
            [self.client connect];
    }
}


- (NSNumber *) getPairingPin{
    return [self.client pin];
}

- (NSString *) getPairingDeviceName
{
    return [self.client name];
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedComManager];
}





@end
