#import <Foundation/Foundation.h>
#import "IPCSender.h"

// Stub implementation for standalone builds (without MRYIPCCenter dependency)
#define STANDALONE_BUILD 1

@implementation IPCSender

- (id)init {
  if (self = [super init]) {
#ifndef STANDALONE_BUILD
    self.center = [MRYIPCCenter centerNamed:@"com.enzodjabali.iosmb-server"];
#endif
  }
  
  return self;
}

- (void)sendFakeText {
#ifndef STANDALONE_BUILD
  [self.center callExternalVoidMethod:@selector(sendText:) withArguments:@{ @"text": @"", @"subject": @"", @"address": @"", @"attachment": @[] }];
#endif
}

- (void)sendText:(NSString *)text withSubject:(NSString *)subject toAddress:(NSString *)address withAttachments:(NSArray *)paths {
#ifndef STANDALONE_BUILD
  [self.center callExternalVoidMethod:@selector(sendText:) withArguments:@{ @"text": text, @"subject": subject, @"address": address, @"attachment": paths }];
#endif
}

- (void)sendReaction:(NSNumber *)reactionId forGuid:(NSString *)guid forChatId:(NSString *)chat_id forPart:(NSNumber *)part {
#ifndef STANDALONE_BUILD
  [self.center callExternalVoidMethod:@selector(sendReaction:) withArguments:@{ @"reactionId": reactionId, @"guid": guid, @"chat_id": chat_id, @"part": part }];
#endif
}

- (void)setIsLocallyTyping:(bool)isTyping forChatId:(NSString *)chat_id {
#ifndef STANDALONE_BUILD
  [self.center callExternalVoidMethod:@selector(setIsLocallyTyping:) withArguments:@{ @"chat_id": chat_id, @"typing": @(isTyping) }];
#endif
}

- (void)deleteChat:(NSString *)chat_id {
#ifndef STANDALONE_BUILD
  [self.center callExternalVoidMethod:@selector(deleteChat:) withArguments:@{ @"chat": chat_id }];
#endif
}

- (void)setAsRead:(NSString *)chat_id {
#ifndef STANDALONE_BUILD
  NSArray* chats = [chat_id componentsSeparatedByString:@","]; 
  for (NSString* chat in chats) {
    [self.center callExternalVoidMethod:@selector(setAsRead:) withArguments:chat];
  }
#endif
}

@end


@implementation IPCWatcher {
#ifndef STANDALONE_BUILD
  MRYIPCCenter* _center;
#endif
}

-(id)initWithCallback:(void(^)(NSString *))callback 
  withServerStopCallback:(void(^)(id))callbackStop
  withSetMessageAsReadCallback:(void(^)(NSDictionary *))readCallback
  withRemoveChatCallback:(void(^)(NSString *))removeChatCallback {
  if (self = [super init]) {
#ifndef STANDALONE_BUILD
    _center = [MRYIPCCenter centerNamed:@"com.enzodjabali.iosmb-server-listener"];
    
    self.setTexts = callback;
    self.stopWebserver = callbackStop;
    self.setMessageAsRead = readCallback;
    self.removeChat = removeChatCallback;
    
    [_center addTarget:self action:@selector(listener:)];
    [_center addTarget:self action:@selector(listenerStop:)];
    [_center addTarget:self action:@selector(listenerSetAsRead:)];
    [_center addTarget:self action:@selector(listenerRemoveChat:)];
#endif
  }
  
  return self;
}

-(void)listener:(NSString*)text {
  self.setTexts(text);
}

-(void)listenerStop:(id)val {
  self.stopWebserver(val);
}

-(void)listenerSetAsRead:(NSDictionary*)dict {
  self.setMessageAsRead(dict);
}

-(void)listenerRemoveChat:(NSString*)chat_id {
  self.removeChat(chat_id);
}

@end
