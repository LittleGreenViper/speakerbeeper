//
//  A_LGV_MCNetworkManager.h
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 1/9/14.
//  Copyright (c) 2014 Little Green Viper Software Development LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@class A_LGV_MCNetworkManager;

/*********************************************************/
/**
 \protocol A_LGV_MCNetworkManagerDelegate
 \brief This describes the functions to be used by the delegate.
        These methods are all called on the main thread.
 */
@protocol A_LGV_MCNetworkManagerDelegate <NSObject>
/*********************************************************/
/**
 \brief Returns the peer ID to be used by the network manager.
 */
- (MCPeerID*)getPeerID;

/*********************************************************/
/**
 \brief This is called to let the delegate know that they should re-scan the connection list.
 */
- (void)connectionListChanged:(A_LGV_MCNetworkManager*)inConnectionManager;       ///< The connection manager that is managing our Node browser.

/*********************************************************/
/**
 \brief This is called to let the delegate know that they
        have receieved a request for a connection from a
        Node.
 */
- (void)receivedConnectionRequest:(A_LGV_MCNetworkManager*)inConnectionManager  ///< The connection manager that is managing this.
                         fromNode:(MCPeerID*)inNode;                            ///< The Node requesting the connection.

/*********************************************************/
/**
 \brief This is called to report a successful Node connection.
 */
- (void)connectionSuccessful:(A_LGV_MCNetworkManager*)inConnectionManager   ///< The connection manager that is managing this.
                      toNode:(MCPeerID*)inNode;                             ///< The Node to whom we are now connected.

/*********************************************************/
/**
 \brief Called when data is received from a Node.
 */
- (void)connectionManager:(A_LGV_MCNetworkManager*)inConnectionManager  ///< The connection manager that is managing this.
             receivedData:(NSData*)inData;                              ///< The data that was received

/*********************************************************/
/**
 \brief Called if a node disconnects.
 */
- (void)connection:(A_LGV_MCNetworkManager*)inConnectionManager         ///< The connection manager that is managing our Node browser.
  nodeDisconnected:(MCPeerID*)inNode;                                   ///< The node that disconnected.

/*********************************************************/
/**
 \brief Called if the connection experiences an error.
 */
- (void)connection:(A_LGV_MCNetworkManager*)inConnectionManager         ///< The connection manager that is managing our Node browser.
  experiencedError:(NSError*)inError;                                   ///< The error experienced by the connection.

@optional

/*********************************************************/
/**
 \brief Called to tell the delegate to call us back, and present the commander browser.
 */
- (void)presentCommanderBrowser:(A_LGV_MCNetworkManager*)inConnectionManager;   ///< The connection manager that is managing our Node browser.

/*********************************************************/
/**
 \brief Called to tell the delegate to dismiss the commander browser.
 */
- (void)dismissCommanderBrowser:(A_LGV_MCNetworkManager*)inConnectionManager;   ///< The connection manager that is managing our Node browser.
@end

/*********************************************************/
/**
 \class A_LGV_MCNetworkManager
 \brief This manages the Multipeer Connectivity Node-to-Node networking.
        This is an abstract class that needs to be subclassed
        for actual implementation.
 */
@interface A_LGV_MCNetworkManager : NSObject <MCSessionDelegate>
@property   (weak, nonatomic, readwrite)NSObject<A_LGV_MCNetworkManagerDelegate>    *delegate;              ///< Contains the delegate object for this manager.
@property   (strong, atomic, readwrite) MCSession                                   *session;               ///< This is the active connection session.
@property   (strong, atomic, readwrite) NSString                                    *serviceType;           ///< The service type for this session.

- (id)initWithDelegate:(NSObject<A_LGV_MCNetworkManagerDelegate>*)inDelegate andServiceType:(NSString*)inServiceType;   ///< Designated initializer

- (NSError*)sendData:(NSData*)inData;                   ///< Commander sends data to slaves.
@end

/*********************************************************/
/**
 \class LGV_MCNetworkManagerClient
 \brief This manages client nodes.
 */
@interface LGV_MCNetworkManagerClient : A_LGV_MCNetworkManager <MCNearbyServiceBrowserDelegate, MCBrowserViewControllerDelegate>
@property (strong, atomic, readonly)    MCPeerID                *selectedCommander;         ///< If a commander has been selected, its node is indicated here.
@property (strong, atomic, readwrite)   MCPeerID                *originalCommanderPeerID;   ///< If there was a previous commander, its ID is kept here.
- (id)initWithDelegate:(NSObject<A_LGV_MCNetworkManagerDelegate>*)inDelegate andOriginalID:(MCPeerID*)inOriginalCommanderID;    ///< Designated initializer
- (void)findCommanders:(BOOL)inForceBrowser;                                                ///< Looks for commanders. If more than one, a browser is displayed to the user.
- (void)presentCommanderBrowser:(UIViewController*)inPresentingContext;                     ///< This presents the commander browser.
- (void)dismissCommanderBrowser;                                                            ///< Dismisses the commander browser.
@end

/*********************************************************/
/**
 \class LGV_MCNetworkManagerServer
 \brief This manages server nodes.
 */
@interface LGV_MCNetworkManagerServer : A_LGV_MCNetworkManager <MCNearbyServiceAdvertiserDelegate>
@property (strong, atomic, readonly)    MCNearbyServiceAdvertiser   *serviceAdvertiser;     ///< This handles advertising the commander service.

- (id)initWithDelegate:(NSObject<A_LGV_MCNetworkManagerDelegate>*)inDelegate;   ///< Designated initializer
@end


