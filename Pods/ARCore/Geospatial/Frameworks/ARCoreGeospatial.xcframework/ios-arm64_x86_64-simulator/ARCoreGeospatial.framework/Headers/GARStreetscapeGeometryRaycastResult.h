/*
 * Copyright 2018 Google LLC. All Rights Reserved.
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

@class GARStreetscapeGeometry;

/**
 * The result returned from |raycastStreetscapeGeometry:direction:error:| containing the transform
 * of the hit location, the distance from the camera, and the geometry which was hit.
 */
@interface GARStreetscapeGeometryRaycastResult : NSObject

/**
 * The transformation matrix that defines the raycast result's rotation, translation and scale
 * relative to the world.
 */
@property(nonatomic, readonly) simd_float4x4 worldTransform;

/** The distance between camera and intersection in meters. */
@property(nonatomic, readonly) float distance;

/** The instance of `GARStreetscapeGeometry` that has an intersection with the ray. */
@property(nonatomic, readonly) GARStreetscapeGeometry *streetscapeGeometry;

/// @cond
/**
 * Instantiated by the library.
 */
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
/// @endcond

@end
