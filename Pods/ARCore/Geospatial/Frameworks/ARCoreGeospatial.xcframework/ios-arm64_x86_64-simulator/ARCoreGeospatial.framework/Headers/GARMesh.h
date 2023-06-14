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
#include <stdint.h>

NS_ASSUME_NONNULL_BEGIN

/** Struct to hold vertex coordinates. */
typedef struct {
  /** The X coordinate of this vertex. */
  float x;
  /** The Y coordinate of this vertex. */
  float y;
  /** The Z coordinate of this vertex. */
  float z;
} GARVertex;

/**
 * Struct to hold indices that represent a triangle. Triangle indices are in counter clockwise
 * winding order.
 */
typedef struct {
  /** The three indices that make up a triangle. */
  uint32_t indices[3];
} GARIndexTriangle;

/**
 * Object that holds geometry mesh and transform data for `GARStreetscapeGeometry`. This object
 * is immutable.
 */
@interface GARMesh : NSObject

/**
 * Number of vertices in the geometry mesh.
 */
@property(nonatomic, readonly) NSUInteger vertexCount;

/**
 * A buffer of `GARVertex`, which stores 3D vertex locations.
 *
 * These vertices are relative to the geometry transform of the geometry. Units are in meters.
 */
@property(nonatomic, readonly) const GARVertex *vertices;

/**
 * Number of triangles in the geometry mesh.
 *
 * This is equivalent to the number of elements in `#triangles`.
 */
@property(nonatomic, readonly) NSUInteger triangleCount;

/**
 * A buffer of `GARIndexTriangle`.
 *
 * The indices within each triangle are indices into the `#vertices` array.
 */
@property(nonatomic, readonly) const GARIndexTriangle *triangles;

/// @cond
/**
 * Created by `GARStreetscapeGeometry`.
 */
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
/// @endcond

@end

NS_ASSUME_NONNULL_END
