//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<blue_thermal_printer/BlueThermalPrinterPlugin.h>)
#import <blue_thermal_printer/BlueThermalPrinterPlugin.h>
#else
@import blue_thermal_printer;
#endif

#if __has_include(<charset_converter/CharsetConverterPlugin.h>)
#import <charset_converter/CharsetConverterPlugin.h>
#else
@import charset_converter;
#endif

#if __has_include(<flutter_bluetooth_basic/FlutterBluetoothBasicPlugin.h>)
#import <flutter_bluetooth_basic/FlutterBluetoothBasicPlugin.h>
#else
@import flutter_bluetooth_basic;
#endif

#if __has_include(<path_provider_ios/FLTPathProviderPlugin.h>)
#import <path_provider_ios/FLTPathProviderPlugin.h>
#else
@import path_provider_ios;
#endif

#if __has_include(<permission_handler_apple/PermissionHandlerPlugin.h>)
#import <permission_handler_apple/PermissionHandlerPlugin.h>
#else
@import permission_handler_apple;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [BlueThermalPrinterPlugin registerWithRegistrar:[registry registrarForPlugin:@"BlueThermalPrinterPlugin"]];
  [CharsetConverterPlugin registerWithRegistrar:[registry registrarForPlugin:@"CharsetConverterPlugin"]];
  [FlutterBluetoothBasicPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterBluetoothBasicPlugin"]];
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
}

@end
