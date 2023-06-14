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

#include <simd/simd.h>

#import <ARCoreGARSession/GARTrackingState.h>
#import <ARCoreGeospatial/GARMesh.h>
#import <ARCoreGeospatial/GARStreetscapeGeometryQuality.h>
#import <ARCoreGeospatial/GARStreetscapeGeometryType.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * `GARStreetscapeGeometry` represents a portion of nearby building or terrain geometry. A
 * `GARStreetscapeGeometry` is an immutable snapshot of the geometry at a particular timestamp.
 * See the
 * <a href="https://developers.google.com/ar/develop/ios/geospatial/streetscape-geometry">Streetscape
 * Geometry Developer Guide</a> for additional information.
 */
@interface GARStreetscapeGeometry : NSObject <NSCopying>

/**
 * 3D mesh representation of the `GARStreetscapeGeometry`'s geometry.
 */
@property(nonatomic, readonly) GARMesh *mesh;

/**
 * Transform of the geometry's mesh geometry relative to the session's world space. If
 * `#trackingState` is not `#GARTrackingStateTracking`, this value is arbitrary and invalid.
 */
@property(nonatomic, readonly) matrix_float4x4 meshTransform;

/** The current state of tracking for `GARStreetscapeGeometry`. */
@property(nonatomic, readonly) GARTrackingState trackingState;

/** Type of this `GARStreetscapeGeometry`. */
@property(nonatomic, readonly) GARStreetscapeGeometryType type;

/**
 * Unique Identifier for this `GARStreetscapeGeometry`. `isEqual:` will return `YES` for another
 * `GARStreetscapeGeometry` with the same identifier.
 */
@property(nonatomic, readonly) NSUUID *identifier;

/**
 * The mesh quality of this `GARStreetscapeGeometry`.
 */
@property(nonatomic, readonly) GARStreetscapeGeometryQuality quality;

/// @cond
/**
 * Instantiated by the library.
 */
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
/// @endcond

@end

NS_ASSUME_NONNULL_END
