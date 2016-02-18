#import <Foundation/Foundation.h>

typedef enum DocType : NSUInteger {
    PDF,
    Image,
    Link,
    Unknown
} DocType;

@class ASDKSharedDocument;

@protocol ASDKSharedDocumentDownloadDelegate <NSObject>

- (void)documentDidFinishDownloading:(ASDKSharedDocument *)sharedDocument;
- (void)documentFailedToDownload:(ASDKSharedDocument *)sharedDocument;

@end

/* A PDF file, image, or link to a web page pushed from the agent to the consumer. */
@interface ASDKSharedDocument : NSObject {
    NSMutableData *_receivedData;
}

@property (nonatomic, weak) id<ASDKSharedDocumentDownloadDelegate> downloadDelegate;

@property (nonatomic, retain) NSNumber *idNumber;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) DocType docType;
@property (nonatomic, retain) NSString *mimeType;
@property (nonatomic, retain) NSString *characterEncoding;
@property (nonatomic, retain) NSData *contentData;
@property (nonatomic, assign) unsigned short errorCode;
@property (nonatomic, assign) NSInteger httpErrorCode;
@property (nonatomic, retain) NSString *errorDetails;
@property (nonatomic, assign) bool hasCloseLink;
- (id)initWithUrl:(NSURL *)url link:(BOOL)link __attribute__((deprecated));
- (id)initWithUrl:(NSURL *)url link:(bool)link hasCloseLink:(bool)hasCloseLink;
- (id)initWithMimeType:(NSString *)mimeType;
- (id)initWithMimeType:(NSString *)mimeType andContent:(NSData *)content hasCloseLink:(bool) hasCloseLink;
- (BOOL)isLink;
- (void)determineDocTypeFromMimeType;
- (void)downloadWithDelegate:(id<ASDKSharedDocumentDownloadDelegate>)delegate;
- (void)prepareToReceiveDataChunks;
- (void)addDataChunk:(NSData *)data;
- (void)doneReceivingDataChunks;

- (void)close;

@end
