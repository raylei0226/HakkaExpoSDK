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

/** @defgroup GARTerrainAnchorState */

/**
 * @ingroup GARTerrainAnchorState
 * Describes the state of an asynchronous operation launched by
 * `GARSession#createAnchorWithCoordinate:altitudeAboveTerrain:eastUpSouthQAnchor:completionHandler:error:`.
 */
typedef NS_ENUM(NSInteger, GARTerrainAnchorState) {
  /** Not a valid value for a Terrain anchor operation. */
  GARTerrainAnchorStateNone = 0,

  /** This anchor has started the process of resolving, but it is not complete. */
  GARTerrainAnchorStateTaskInProgress
  __attribute__((deprecated("Not returned by async methods. "
                            "Replaced by GARFutureStatePending."))) = 1,

  /** This anchor has been resolved successfully. */
  GARTerrainAnchorStateSuccess = 2,

  /** Internal error. No recommended mitigation. */
  GARTerrainAnchorStateErrorInternal = -1,

  /**
   * The operation failed due to an authentication or authorization error. This may occur due to a
   * number of reasons:
   * - The Google Cloud project may not have enabled the ARCore API.
   * - If the session was created with an API Key, the API Key may be invalid or deleted, or
   *   restricted to exclude the app's bundle Id.
   * - If the session was not created with an API Key, a token may not have been provided, or the
   *   provided token may be invalid.
   * - The requested operation may not be permitted.
   */
  GARTerrainAnchorStateErrorNotAuthorized = -2,

  /** There is no terrain info at this location, such as the center of the ocean. */
  GARTerrainAnchorStateErrorUnsupportedLocation = -3,
};
