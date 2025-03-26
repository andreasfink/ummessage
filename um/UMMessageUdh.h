//
//  UMMessageUdh.h
//  ummessage
//
//  Created by Andreas Fink on 26.03.2025.
//

#import <ulib/ulib.h>


typedef enum UdhIEI
{
    UdhIEI_concatenated                     = 0x00,
    UdhIEI_specialMessageIndication1        = 0x01,
    UdhIEI_reserved2                        = 0x02,
    UdhIEI_reserved3                        = 0x03,
    UdhIEI_applicationPort8bit              = 0x04,
    UdhIEI_applicationPort16bit             = 0x05,
    UdhIEI_smscControlParameters            = 0x06,
    UdhIEI_udhSourceIndicator               = 0x07,
    UdhIEI_concatenated16bitRef             = 0x08,
    UdhIEI_wirelessControlMessageProtocol   = 0x09,
    UdhIEI_emsTextFormatting                = 0x0A,
    UdhIEI_emsPredefinedSound               = 0x0B,
    UdhIEI_emsUserDefinedSound              = 0x0C,
    UdhIEI_emsPredefinedAnimation           = 0x0D,
    UdhIEI_emsLargeAnimation                = 0x0E,
    UdhIEI_emsSmallAnimation                = 0x0F,
    UdhIEI_emsLargePicture                  = 0x10,
    UdhIEI_emsSmallPicture                  = 0x11,
    UdhIEI_emsVariablePicture               = 0x12,
    UdhIEI_emsUserPromptIndicator           = 0x13,
    UdhIEI_emsExtendedObject                = 0x14,
    UdhIEI_emsReusedExtendedObject          = 0x15,
    UdhIEI_emsCompressionControl            = 0x16,
    UdhIEI_emsObjectDistributionIndicator   = 0x17,
    UdhIEI_emsStandardWvgObject             = 0x18,
    UdhIEI_emsCharacterSizeWvgObject        = 0x19,
    UdhIEI_emsExtendedObjectDataRequest     = 0x1A,
    UdhIEI_emailHeader                      = 0x20,
    UdhIEI_hyperlinkFormatElement           = 0x21,
    UdhIEI_replyAddressElement              = 0x22,
    UdhIEI_enhancedVoiceMailInformation     = 0x23,
    UdhIEI_nationalLanguageSingleShift      = 0x24,
    UdhIEI_nationalLanguageLockingShift     = 0x25,
} UdhIEI;


@interface UMMessageUdh : UMObject
{
    NSInteger   _iei;
    NSData      *_data;
}

@property(readwrite,assign) NSInteger   iei;
@property(readwrite,strong) NSData      *data;

- (UMMessageUdh *)initWithData:(NSData *)d atPosition:(int *)pos;
- (NSData *)encode;
- (void)prepareEncode;
@end
