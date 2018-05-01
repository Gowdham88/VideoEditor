#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AudioMixer.h"
#import "GenericAudioMixer.h"
#import "IAudioMixer.hpp"
#import "IMixer.hpp"
#import "iOS/GLESVideoMixer.h"
#import "IVideoMixer.hpp"
#import "RTMPSession.h"
#import "RTMPTypes.h"
#import "Apple/PixelBufferSource.h"
#import "iOS/CameraSource.h"
#import "iOS/GLESUtil.h"
#import "iOS/MicSource.h"
#import "ISource.hpp"
#import "StreamSession.h"
#import "IStreamSession.hpp"
#import "IThroughputAdaptation.h"
#import "TCPThroughputAdaptation.h"
#import "Buffer.hpp"
#import "h264/Golomb.h"
#import "JobQueue.hpp"
#import "pixelBuffer/Apple/PixelBuffer.h"
#import "pixelBuffer/GenericPixelBuffer.h"
#import "pixelBuffer/IPixelBuffer.hpp"
#import "util.h"
#import "H264Encode.h"
#import "MP4Multiplexer.h"
#import "AspectTransform.h"
#import "IEncoder.hpp"
#import "IMetaData.hpp"
#import "iOS/AACEncode.h"
#import "iOS/H264Encode.h"
#import "IOutput.hpp"
#import "IOutputSession.hpp"
#import "ITransform.hpp"
#import "PositionTransform.h"
#import "RTMP/AACPacketizer.h"
#import "RTMP/H264Packetizer.h"
#import "Split.h"
#import "VCPreviewView.h"
#import "VCSimpleSession.h"
#import "BasicVideoFilterBGRA.h"
#import "BasicVideoFilterBGRAinYUVAout.h"
#import "FisheyeVideoFilter.h"
#import "GrayscaleVideoFilter.h"
#import "InvertColorsVideoFilter.h"
#import "SepiaVideoFilter.h"
#import "FilterFactory.h"
#import "IFilter.hpp"
#import "IVideoFilter.hpp"

FOUNDATION_EXPORT double videocoreVersionNumber;
FOUNDATION_EXPORT const unsigned char videocoreVersionString[];

