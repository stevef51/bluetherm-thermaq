//
//  TLRange.h
//  ThermaLib
//
//  Copyright © 2017 Electronic Temperature Instruments Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLDevice.h"

@interface TLRange : NSObject

/**
* @brief The low value for the current range
*/
@property (assign) float low;

/**
* @brief The high value for the current range
*/
@property (assign) float high;

/**
* @brief Create a range with the current high an low values
* @param low The low value of the range
* @param high The high value of the range
* @return TLRange The new range object created  with the values supplied
*/
+(TLRange *) newWithLow: (float)low
                   high: (float)high;

/**
* @brief Return the range in the units specified. Currently used for converting from C to F and back.
* @param units The units to convert to
* @return TLRange The new range from the conversion.
*/
-(TLRange *) rangeInUnits: (TLDeviceUnit)units;

@end
