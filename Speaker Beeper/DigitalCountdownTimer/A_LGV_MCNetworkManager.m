//
//  LGV_MCNetworkManager.m
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 1/9/14.
//  Copyright (c) 2014 Little Green Viper Software Development LLC. All rights reserved.
//

static          NSString    *s_sessionID            = @"SpeakerBeeper2.0Session";   ///< The ID we use for our session.
static  const   float       s_quickCheckTimeout     = 1.0;                          ///< How long we wait for an old commander before giving up.

#import "A_LGV_MCNetworkManager.h"

/*********************************************************/
/**
 \class A_LGV_MCNetworkManager
 \brief This manages the GameKit Node-to-Node networking.
 */
@interface A_LGV_MCNetworkManager ()

- (void)_sendReceivedDataInMainThread:(NSData*)inData;      ///< Used to send the received data to the timer, but in the main thread.
- (void)_sendErrorInMainThread:(NSError*)inError;           ///< A main-thread-executed rouine that calls the delegate to let them know we have a successful connection.
- (void)_sendNodeListChangedInMainThread;                   ///< A main-thread-executed rouine that calls the delegate to let them know nodelist changed.
- (void)_informDelegateConnectionRequest:(MCPeerID*)inNode; ///< This is called in the execution thread, and it will call the delegate handler in the main thread.
- (void)_informDelegateConnectionSuccess:(MCPeerID*)inNode; ///< This is called in the execution thread, and it will call the delegate handler in the main thread.
- (void)_informDelegateNodeDisconnected:(MCPeerID*)inNode;  ///< This is called in the execution thread, and it will call the delegate handler in the main thread.
- (void)_informDelegateError:(NSError*)inError;             ///< This is called in the execution thread, and it will call the delegate handler in the main thread.
- (void)_informDelegateNodeListChanged;                     ///< This is called in the execution thread, and it will call the delegate handler in the main thread.
- (void)_destroySession;                                    ///< Nuke our session entirely.
@end

@implementation A_LGV_MCNetworkManager

#pragma mark - Private Instance Methods

/*********************************************************/
/**
 \brief Called in the main thread to send data to the delegate.
 */
- (void)_sendReceivedDataInMainThread:(NSData*)inData     ///< This is an aggregator object, with the data and the Node.
{
    if ( [self delegate] && [[self delegate] respondsToSelector:@selector(connectionManager:receivedData:)] )
        {
        [[self delegate] connectionManager:self receivedData:inData];
        }
}

/*********************************************************/
/**
 \brief Called in the main thread to inform the delegate that a slave wants to connect.
 */
- (void)_sendConnectionRequestInMainThread:(MCPeerID*)inNode  ///< This is the Node that wants to connect.
{
    if ( [self delegate] && [[self delegate] respondsToSelector:@selector(receivedConnectionRequest:fromNode:)] )
        {
        [[self delegate] receivedConnectionRequest:self fromNode:inNode];
        }
}

/*********************************************************/
/**
 \brief Called in the main thread to inform the delegate that a connection was successful.
 */
- (void)_sendConnectionSuccessInMainThread:(MCPeerID*)inNode  ///< This is the Node that connected.
{
    if ( [self delegate] && [[self delegate] respondsToSelector:@selector(connectionSuccessful:toNode:)] )
        {
        [[self delegate] connectionSuccessful:self toNode:inNode];
        }
}

/*********************************************************/
/**
 \brief Called in the main thread to tell the delegate that a node disconnected.
 */
- (void)_sendNodeDisconnectedInMainThread:(MCPeerID*)inNode   ///< This is the Node that disconnected.
{
    if ( [self delegate] && [[self delegate] respondsToSelector:@selector(connection:nodeDisconnected:)] )
        {
        [[self delegate] connection:self nodeDisconnected:inNode];
        }
}

/*********************************************************/
/**
 \brief Called in the main thread, to tell the delegate that the session experienced an error.
 */
- (void)_sendErrorInMainThread:(NSError*)inError    ///< The error experienced by the session
{
    if ( [self delegate] && [[self delegate] respondsToSelector:@selector(connection:experiencedError:)] )
        {
        [[self delegate] connection:self experiencedError:inError];
        }
}

/*********************************************************/
/**
 \brief Called in the main thread, to tell the delegate that the nodelist changed.
 */
- (void)_sendNodeListChangedInMainThread
{
    if ( [self delegate] && [[self delegate] respondsToSelector:@selector(connectionListChanged:)] )
        {
        [[self delegate] connectionListChanged:self];
        }
}

/*********************************************************/
/**
 \brief This is called in the execution thread, and it will call the delegate handler in the main thread.
 */
- (void)_informDelegateConnectionRequest:(MCPeerID*)inNode    ///< The node requesting connection.
{
    [self performSelectorOnMainThread:@selector(_sendConnectionRequestInMainThread:) withObject:inNode waitUntilDone:YES];
}

/*********************************************************/
/**
 \brief This is called in the execution thread, and it will call the delegate handler in the main thread.
 */
- (void)_informDelegateConnectionSuccess:(MCPeerID*)inNode    ///< The node that connected
{
    [self performSelectorOnMainThread:@selector(_sendConnectionSuccessInMainThread:) withObject:inNode waitUntilDone:YES];
}

/*********************************************************/
/**
 \brief This is called in the execution thread, and it will call the delegate handler in the main thread.
 */
- (void)_informDelegateNodeDisconnected:(MCPeerID*)inNode ///< The node that disconnected
{
    [self performSelectorOnMainThread:@selector(_sendNodeDisconnectedInMainThread:) withObject:inNode waitUntilDone:YES];
}

/*********************************************************/
/**
 \brief This is called in the execution thread, and it will call the delegate handler in the main thread.
 */
- (void)_informDelegateError:(NSError*)inError  ///< The error experienced by the session
{
    [self performSelectorOnMainThread:@selector(_sendErrorInMainThread:) withObject:inError waitUntilDone:YES];
}

/*********************************************************/
/**
 \brief This is called in the execution thread, and it will call the delegate handler in the main thread.
 */
- (void)_informDelegateNodeListChanged
{
    [self performSelectorOnMainThread:@selector(_sendNodeListChangedInMainThread) withObject:nil waitUntilDone:YES];
}

/*********************************************************/
/**
 \brief Take down our session completely.
 */
- (void)_destroySession
{
	if ( [self session] )
        {
        [[self session] setDelegate:nil];
        }
    
    _session = nil;
}

#pragma mark - Public Instance Methods

/*********************************************************/
/**
 \brief Default Initializer
 \returns self
 */
- (id)init
{
    return [self initWithDelegate:nil andServiceType:nil];
}

/*********************************************************/
/**
 \brief Will the last one out the door please turn off the lights?
 */
- (void)dealloc
{
    [self _destroySession];
}

/*********************************************************/
/**
 \brief Designated Initializer
 \returns self
 */
- (id)initWithDelegate:(NSObject<A_LGV_MCNetworkManagerDelegate>*)inDelegate    ///< The delegate that will "own" this manager
        andServiceType:(NSString*)inServiceType
{
    self = [super init];
    
    if ( self )
        {
        _delegate = inDelegate;
        _serviceType = inServiceType;
        _delegate = inDelegate;
        
        if ( inDelegate && [inDelegate respondsToSelector:@selector(getPeerID)] )
            {
            _session = [[MCSession alloc] initWithPeer:[inDelegate getPeerID]];
            
            if ( _session )
                {
                [_session setDelegate:self];
                }
            }
        }

    return self;
}

/*********************************************************/
/**
 \brief Sends data to Nodes.
 This is only valid for commander mode.
 */
- (NSError*)sendData:(NSData*)inData    ///< The data to be sent to the peer.
{
    NSError *error;
    return error;
}

#pragma mark - MCSession Data Receiver -

/*********************************************************/
/**
 \brief Called when we receive data from a connected Node.
 */
- (void)session:(MCSession *)inSession  ///< The connected session
 didReceiveData:(NSData *)inData        ///< The data we received from the node (peer)
       fromPeer:(MCPeerID *)inPeerID    ///< The peer ID of the sending node
{
#ifdef DEBUG
    NSLog ( @"LGV_MCNetworkManager::session:%@ didReceiveData:%@ fromPeer:%@", inSession, inData, inPeerID );
#endif
    
    [self performSelectorOnMainThread:@selector(_sendReceivedDataInMainThread:) withObject:inData waitUntilDone:YES];
}

#pragma mark - MCSessionDelegate Methods -

/*********************************************************/
/**
 \brief Called when we start receiving resources from a connected peer.
 */
- (void)session:(MCSession *)inSession                          ///< The connected session
didStartReceivingResourceWithName:(NSString *)inResourceName    ///< The name of the received resource
       fromPeer:(MCPeerID *)inPeerID                            ///< The peer ID of the sending node
   withProgress:(NSProgress *)inProgress                        ///< the progress of the receiving operation (may be called repeatedly)
{
}

/*********************************************************/
/**
 \brief Called when we have finished receiving a resource from a connected node.
 */
- (void)session:(MCSession *)inSession                          ///< The connected session
didFinishReceivingResourceWithName:(NSString *)inResourceName   ///< The name of the resource that we loaded
       fromPeer:(MCPeerID *)inPeerID                            ///< The peer ID of the sending node
          atURL:(NSURL *)inLocalURL                             ///< The local URL of the received resource
      withError:(NSError *)inError                              ///< Any errors that we encountered during the transfer.
{
    
}

/*********************************************************/
/**
 \brief This is called when we receive a stream from a connected node.
 */
- (void)session:(MCSession *)inSession      ///< The connected session
didReceiveStream:(NSInputStream *)inStream  ///< The stream we are receiving
       withName:(NSString *)inStreamName    ///< the name of the stream
       fromPeer:(MCPeerID *)inPeerID        ///< The peer ID of the sending node
{
    
}

/*********************************************************/
/**
 \brief This is called when a connected peer changes state.
 */
- (void)session:(MCSession *)inSession  ///< The connected session
           peer:(MCPeerID *)inPeerID    ///< The peer ID of the node
 didChangeState:(MCSessionState)inState ///< The new state of the node
{
    assert ( false );   // This method should never be called.
#ifdef DEBUG
    NSLog ( @"THIS SHOULD NEVER BE CALLED!" );
#endif
}
@end

/*********************************************************/
/**
 \class LGV_MCNetworkManagerClient
 \brief This manages client nodes.
 */
@interface LGV_MCNetworkManagerClient ()
@property (strong, atomic, readwrite)   NSTimer                 *_quickCheckTimer;  ///<
@property (strong, atomic, readonly)    MCNearbyServiceBrowser  *_commanderBrowser; ///< This is what is used to browse for existing commanders.
@property (strong, atomic, readonly)    MCBrowserViewController *_commanderBrowserViewController;   ///< This controls a browser view for selecting commanders.
@property (weak, atomic, readwrite)     UIViewController        *_browserContext;   ///< If we are presenting a modal commander browser, then this is the context.
- (void)_searchForCommanders:(NSTimer*)inTimer;                                     ///< This is called to tell the app to present a browser for nearby commanders.
- (void)_stopSearchingForCommanders;                                                ///< Called to tell the network manager to stop looking for new commanders.
@end

@implementation LGV_MCNetworkManagerClient
#pragma mark - External (Public) methods

/*********************************************************/
/**
 \brief Designated initializer
 
 \returns self
 */
- (id)initWithDelegate:(NSObject<A_LGV_MCNetworkManagerDelegate>*)inDelegate    ///< The delegate that will receive messages from the connected commander
         andOriginalID:(MCPeerID*)inOriginalCommanderID                         ///< If we had a previous commander, its ID is given here. This can be nil (no previous commander).
{
    self = [super initWithDelegate:inDelegate andServiceType:nil];
    
    if ( self )
        {
        __commanderBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:[[self session] myPeerID] serviceType:s_LGV_CommanderAdvertiserService];
        _originalCommanderPeerID = inOriginalCommanderID;
        }
    
    return self;
}

/*********************************************************/
/**
 \brief Looks for commanders. If more than one, a browser is displayed to the user.
 */
- (void)findCommanders:(BOOL)inForceBrowser ///< If this is YES, the commander browser will be shown at all times. If NO, then the commander, if available, will be quietly reconnected.
{
    [self _stopSearchingForCommanders]; // Make sure we're not already looking...
    
    if ( [self session] && (![self selectedCommander] || inForceBrowser) )  // We only go in if we either don't already have a commander, or we are forcing a browser. We must also have an active session.
        {
        if ( [self originalCommanderPeerID] && [self _commanderBrowser] )    // See if the old commander is still around.
            {
            [[self _commanderBrowser] setDelegate:self];
            // You have one second to find an old commander.
            [self set_quickCheckTimer:[NSTimer timerWithTimeInterval:s_quickCheckTimeout target:self selector:@selector(_searchForCommanders:) userInfo:nil repeats:NO]];
            [[self _commanderBrowser] startBrowsingForPeers];
            }
        else
            {
            [self _searchForCommanders:nil];    // Otherwise, we go straight to the browser.
            }
        }
}

/*********************************************************/
/**
 \brief Presents the Commander browser.
 */
- (void)presentCommanderBrowser:(UIViewController*)inPresentingContext  ///< The view controller that will host this modal window/screen.
{
    __commanderBrowserViewController = [[MCBrowserViewController alloc] initWithBrowser:[self _commanderBrowser] session:[self session]];
    [[self _commanderBrowserViewController] setDelegate:self];
    __browserContext = inPresentingContext;
    
    if ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ) // iPad does popover
        {
        
        }
    else    // Phone does modal.
        {
        [inPresentingContext presentViewController:[self _commanderBrowserViewController] animated:YES completion:nil];
        }
}

/*********************************************************/
/**
 \brief Called to dismiss the commander browser.
 */
- (void)dismissCommanderBrowser
{
    if ( [self _browserContext] )
        {
        [[self _browserContext] dismissViewControllerAnimated:YES completion:nil];
        }
    
    __commanderBrowserViewController = nil;
    __browserContext = nil;
    
    if ( [[self delegate] respondsToSelector:@selector(dismissCommanderBrowser:)] )
        {
        [[self delegate] performSelectorOnMainThread:@selector(dismissCommanderBrowser:) withObject:self waitUntilDone:YES];
        }
}

#pragma mark - Internal (Private) methods

/*********************************************************/
/**
 \brief This is called to tell the app to present a browser for nearby commanders.
 */
- (void)_searchForCommanders:(NSTimer*)inTimer  ///< If this was called from a timeout, then this is the timer object.
{
    [self _stopSearchingForCommanders];
    
    if ( [[self delegate] respondsToSelector:@selector(presentCommanderBrowser:)] )
        {
        [[self delegate] performSelectorOnMainThread:@selector(presentCommanderBrowser:) withObject:self waitUntilDone:YES];
        }
}

/*********************************************************/
/**
 \brief Called to tell the network manager to stop looking for new commanders.
 */
- (void)_stopSearchingForCommanders
{
    if ( [self _quickCheckTimer] )
        {
        [[self _quickCheckTimer] invalidate];    // Make sure that we nuke any previous timer.
        }
    
    [self set_quickCheckTimer:nil];
    
    // Make sure the browser isn't browsing.
    [[self _commanderBrowser] stopBrowsingForPeers];
    [[self _commanderBrowser] setDelegate:nil];
    __commanderBrowserViewController = nil;
}

#pragma mark - MCNearbyServiceBrowserDelegate Methods -

/*********************************************************/
/**
 \brief Called if there was an error in the browsing service.
 */
- (void)browser:(MCNearbyServiceBrowser *)inBrowser ///< The browser object
didNotStartBrowsingForPeers:(NSError *)inError      ///< The error that prevented our browsing
{
#ifdef DEBUG
    NSLog ( @"Service Browser Error: %@", inError);
#endif
}

/*********************************************************/
/**
 \brief Called when a peer has been discovered.
 */
- (void)browser:(MCNearbyServiceBrowser *)inBrowser ///< The browser object
      foundPeer:(MCPeerID *)inPeerID                ///< The ID of the discovered peer
withDiscoveryInfo:(NSDictionary *)inInfo            ///< Discovery info for that peer.
{
#ifdef DEBUG
    NSLog ( @"Client Found Peer: %@", inPeerID );
#endif
}

/*********************************************************/
/**
 \brief Called when a discovered peer is lost to the browser.
 */
- (void)browser:(MCNearbyServiceBrowser *)inBrowser ///< The browser object
       lostPeer:(MCPeerID *)inPeerID                ///< The ID of the lost node
{
#ifdef DEBUG
    NSLog ( @"Client Lost Peer: %@", inPeerID );
#endif
}

#pragma mark - Superclass Overload Methods -

/*********************************************************/
/**
 \brief This is called when a connected peer changes state.
 */
- (void)session:(MCSession*)inSession   ///< The connected session
           peer:(MCPeerID*)inPeerID     ///< The peer ID of the node
 didChangeState:(MCSessionState)inState ///< The new state of the node
{
#ifdef DEBUG
    NSLog ( @"Client Peer: %@ did change state %d:", inPeerID, (int)inState );
#endif
    if ( inState == MCSessionStateConnected )
        {
        _selectedCommander = inPeerID;
        [self dismissCommanderBrowser];
        }
    else
        {
        if ( inState == MCSessionStateNotConnected )
            {
            if ( inPeerID == [self selectedCommander] )
                {
                _selectedCommander = nil;
                }
            
            [self dismissCommanderBrowser];
            }
        }
}

#pragma mark - MCBrowserViewControllerDelegate Methods -

/*********************************************************/
/**
 \brief Called to vet a peer, and see if it should be presented.
 */
- (BOOL)browserViewController:(MCBrowserViewController *)inBrowserViewController                ///< The browser view controller.
      shouldPresentNearbyPeer:(MCPeerID*)inPeerID                                               ///< The ID of the peer to be presented.
            withDiscoveryInfo:(NSDictionary*)inInfo                                             ///< Discovery info for that peer.
{
#ifdef DEBUG
    NSLog ( @"Client shouldPresentNearbyPeer: %@", inPeerID );
#endif
    return YES;
}

/*********************************************************/
/**
 \brief Called when a the browser is done.
 */
- (void)browserViewControllerDidFinish:(MCBrowserViewController*)inBrowserViewController        ///< The browser view controller.
{
    [self dismissCommanderBrowser];
}

/*********************************************************/
/**
 \brief Called when the browser was canceled (no change).
 */
- (void)browserViewControllerWasCancelled:(MCBrowserViewController*)inBrowserViewController     ///< The browser view controller.
{
    [self dismissCommanderBrowser];
}
@end

/*********************************************************/
/**
 \class LGV_MCNetworkManagerServer
 \brief This manages server nodes.
 */
@implementation LGV_MCNetworkManagerServer
/*********************************************************/
/**
 \brief Designated Initializer
 
 \returns self
 */
- (id)initWithDelegate:(NSObject<A_LGV_MCNetworkManagerDelegate>*)inDelegate    ///< The delegate for this manager.
{
    self = [super initWithDelegate:inDelegate andServiceType:s_LGV_CommanderAdvertiserService];
    
    if ( self )
        {
        NSDictionary    *discoveryInfo = nil;
        
        _serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:[[self session] myPeerID] discoveryInfo:discoveryInfo serviceType:s_LGV_CommanderAdvertiserService];
        
        if ( _serviceAdvertiser )
            {
            [[self serviceAdvertiser] setDelegate:self];
            [[self serviceAdvertiser] startAdvertisingPeer];
            }
        }
    
    return self;
}

#pragma mark - Superclass Overload Methods -

/*********************************************************/
/**
 \brief This is called when a connected peer changes state.
 */
- (void)session:(MCSession*)inSession   ///< The connected session
           peer:(MCPeerID*)inPeerID     ///< The peer ID of the node
 didChangeState:(MCSessionState)inState ///< The new state of the node
{
#ifdef DEBUG
    NSLog ( @"Server Peer: %@ did change state %d:", inPeerID, (int)inState );
#endif
}

#pragma mark - MCNearbyServiceAdvertiserDelegate Methods -

/*********************************************************/
/**
 \brief Called if the advertiser encounters an error.
 */
- (void)advertiser:(MCNearbyServiceAdvertiser*)inAdvertiser       ///< The advertiser object.
didNotStartAdvertisingPeer:(NSError*)inError                      ///< The error that happened.
{
#ifdef DEBUG
    NSLog ( @"Service Advertiser Error: %@", inError);
#endif
}

/*********************************************************/
/**
 \brief Called when a slave wants to connect.
 */
- (void)advertiser:(MCNearbyServiceAdvertiser*)inAdvertiser     ///< The advertiser object.
didReceiveInvitationFromPeer:(MCPeerID*)inPeerID                ///< The peer ID of the connecting peer.
       withContext:(NSData*)inContext                           ///< Invitation data.
 invitationHandler:(void (^)(BOOL accept, MCSession *session))inInvitationHandler   ///< The C function to call, telling it to accept or decline the invitation.
{
#ifdef DEBUG
    NSLog ( @"Server Peer: %@ wants to connect.", inPeerID );
#endif
    
    assert ( inInvitationHandler != nil );
    
    if ( inInvitationHandler )
        {
        inInvitationHandler ( YES, [self session] );    // We're completely promiscuous. If someone wants in, they get in.
        }
}
@end

