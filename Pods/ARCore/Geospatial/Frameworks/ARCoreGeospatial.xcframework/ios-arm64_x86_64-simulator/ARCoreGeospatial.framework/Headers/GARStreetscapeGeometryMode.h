/*
 * Copyright 2022 Google LLC. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

/** @defgroup GARStreetscapeGeometryMode */

/**
 * @ingroup GARStreetscapeGeometryMode
 * Describes the behavior of the Geospatial Streetscape Geometry API. The Streetscape
 * Geometry API provides polygon meshes of terrain, buildings, and other structures in a radius
 * surrounding the device. See the
 * <a href="https://developers.google.com/ar/develop/ios/geospatial/streetscape-geometry">Streetscape
 * Geometry Developer Guide</a> for additional information.
 *
 * When Streetscape Geometry is enabled, `GARFrame.streetscapeGeometries` can be used to obtain
 * `GARStreetscapeGeometry`s. Additionally, `GARSession#raycastStreetscapeGeometry:direction:error:`
 * can be used to perform a hit-test using Streetscape Geometry.
 *
 * The Streetscape Geometry API requires both `GARSessionConfiguration#streetscapeGeometryMode` to
 * be set to `#GARStreetscapeGeometryModeEnabled` and for `GARSessionConfiguration#geospatialMode`
 * to be set to `#GARGeospatialModeEnabled`.
 *
 * The default value is `#GARStreetscapeGeometryModeDisabled`. Use
 * `GARSessionConfiguration.streetscapeGeometryMode` to set the desired mode.
 */
typedef NS_ENUM(NSInteger, GARStreetscapeGeometryMode) {
  /**
   * The Streetscape Geometry API is disabled.
   *
   * This is the default mode.
   */
  GARStreetscapeGeometryModeDisabled = 0,

  /**
   * The Streetscape Geometry API is enabled. `GARFrame.streetscapeGeometries` can be used to obtain
   * `GARStreetscapeGeometry`s. Additionally,
   * `GARSession#raycastStreetscapeGeometry:direction:error:` can be used to perform a hit-test
   * using Streetscape Geometry.
   *
   * Use `GARSessionConfiguration.streetscapeGeometryMode` to set the desired mode.
   */
  GARStreetscapeGeometryModeEnabled = 1,
};
