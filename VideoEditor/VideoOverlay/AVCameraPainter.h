//
//  AVCameraPainter
//  https://github.com/malczak/VideoCaptureOverlay
//

#import <Foundation/Foundation.h>
#import "AVFrameDrawer.h"
#import <GPUImage/GPUImage.h>

@interface AVCameraPainter : NSObject <GPUImageMovieWriterDelegate> {
}
@property (nonatomic, readonly) GPUImageMovie *movie;
@property (nonatomic, readonly) AVPlayer *mainPlayer;
@property (nonatomic, readonly) AVPlayerItem *playerItem;
@property (nonatomic, assign) BOOL isCaptureVideo;
@property (nonatomic, assign) BOOL shouldUseCaptureTime;
@property (nonatomic, assign) BOOL shouldCaptureAudio;
@property (nonatomic, assign) BOOL shouldRecordOverlay;

@property (nonatomic, readonly) BOOL isCapturing;
@property (nonatomic, readonly) BOOL isRecording;
@property (nonatomic, readonly) BOOL isPaused;

@property (nonatomic, readonly) GPUImageTwoInputFilter *composer;
@property (nonatomic, readonly) AVFrameDrawer *overlay;

@property (nonatomic, readonly) GPUImageVideoCamera *camera;
@property (nonatomic, readonly) GPUImageMovieWriter *writers;

/// @name Initialization and teardown

/** Iniialize camera recorder with sessionPreset and device

 See AVCaptureSession for acceptable values
 
 @param sessionPreset Session preset to use
 @param cameraPosition Camera to capture from
 */
//- (id)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition;
- (id)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition framRate:(int) frameRate captureVideo:(BOOL) isCaptureVideo;

/// @name Manage classes and options

-(void) setComposer:(GPUImageTwoInputFilter *) framesComposer;

-(void) setOverlay:(AVFrameDrawer *) framesOverlay;

/// @name Manage the camera video stream

/** Start camera capturing
 */
- (void)startCameraCapture;

/** Stop camera capturing
 */
- (void)stopCameraCapture;

/** Pause camera capturing
 */
- (void)pauseCameraCapture;

/** Resume camera capturing
 */
- (void)resumeCameraCapture;

/// @name Manage the camera recording

/** Start camera recording
 */
//- (void)startCameraRecordingWithURL:(NSURL*) url size:(CGSize) size metaData:(NSArray<AVMetadataItem*>*) metdata;
- (void)startCameraRecordingWithURL:(NSURL*) url size:(CGSize) size metaData:(NSArray<AVMetadataItem*>*) metadata outputSettings:(NSDictionary *)outputSettings;

/** Stop camera recording
 */
- (void)stopCameraRecordingWithCompetionHandler:(void (^)(AVCameraPainter*))handler;

/** Cancel current recording
 */
- (void)cancelCameraRecording;

/** Capture a still image of recorded video
 */
- (void)caputreStillImage;
- (void)dealloc;
- (void)deallocAfterComplete;
@end
