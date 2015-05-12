//
//  BlockTalk
//  SyncanoChat
//
//  Created by RH Blanchfield on 5/10/15.
//  Copyright (c) 2015 artchiteq. All rights reserved.
//

import UIKit

class ViewController: JSQMessagesViewController, SyncanoSyncServerDelegate {
    
    
    let syncano = Syncano(domain: "bold-sun-280708", apiKey: "bc5d6d21e8e16a85fd492ca573ff6dd6715162dd")
    let syncServer = SyncanoSyncServer(domain: "bold-sun-280708", apiKey: "bc5d6d21e8e16a85fd492ca573ff6dd6715162dd")
    let projectId = "7371"
    let collectionId = "19982"
    
    var userName = ""
    var messages = [JSQMessage]()
    //var senderDisplayName:String = ""
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let savedUserName = NSUserDefaults.standardUserDefaults().stringForKey("userName") {
                 self.userName = savedUserName
             } else {
                 self.userName = "user" + String(arc4random_uniform(UInt32.max))
                 NSUserDefaults.standardUserDefaults().setObject(self.userName, forKey: "userName")
                 NSUserDefaults.standardUserDefaults().synchronize()
             }
        
        let params = SyncanoParameters_DataObjects_Get(projectId: projectId, collectionId: self.collectionId)
        self.syncano .dataGet(params, callback: { response in
            for object in response.data as [SyncanoData] {
                if let senderId = object.additional?["senderId"] as String? {
                    let message = JSQMessage(senderId: senderId, displayName: senderId, text: object.text)
                    self.messages += [message]
                }
            }
            self.collectionView.reloadData()
        })
        self.syncServer.delegate = self
        self.syncServer.connect(nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        func senderDisplayName() -> String! {
            return self.userName
        }
        
        func senderId() -> String! {
            return self.userName
        }
    }

 
    
     override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
             var data = self.messages[indexPath.row]
             return data
         }
    
     override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
             var data = self.messages[indexPath.row]
             if (data.senderId == self.senderId) {
                     return self.outgoingBubble
                 } else {
                     return self.incomingBubble
                 }
         }
    
     override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
             return nil
         }
    
     override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
             return self.messages.count;
         }
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
             let newMessage = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text);
             self.sendMessageToSyncano(newMessage);
             }
    
    override func didPressAccessoryButton(sender: UIButton!) {
         }
    
            func sendMessageToSyncano(message: JSQMessage) {
             let params = SyncanoParameters_DataObjects_New(projectId: projectId, collectionId: collectionId, state: "Pending")
             params.text = message.text
             params.additional = ["senderId" : message.senderId]
        
             self.syncano.dataNew(params, callback: { response in
                     if response.responseOK {
                             self.messages += [message]
                         }
                     self.finishSendingMessage()
                 })
         }
    func syncServerConnectionOpened(syncServer: SyncanoSyncServer!) {
             self.subscribeToCollection()
         }
    
     func syncServer(syncServer: SyncanoSyncServer!, connectionClosedWithError error: NSError!) {
             self.syncServer.connect(nil);
         }
    
     func syncServer(syncServer: SyncanoSyncServer!, notificationAdded addedData: SyncanoData!, channel: SyncanoChannel!) {
             if let senderId = addedData.additional?["senderId"] as String? {
                     let message = JSQMessage(senderId: senderId, displayName: senderId, text: addedData.text)
                     self.messages += [message]
                 }
             self.finishReceivingMessage()
         }
    
    func subscribeToCollection() {
             let params = SyncanoParameters_Subscriptions_SubscribeCollection(projectId: projectId, collectionId: collectionId, context: "connection")
             self.syncServer.subscriptionSubscribeCollection(params) { response in
                     //take care of errors here
                     if (response.responseOK) {
                         }
                 }
         }
}

