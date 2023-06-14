/*
 * Copyright 2023 Google LLC. All Rights Reserved.
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

/** @defgroup GARStreetscapeGeometryQuality */

/**
 * @ingroup GARStreetscapeGeometryQuality
 * Describes the quality of a `GARStreetscapeGeometry`'s mesh. The values
 * correspond to the levels of detail (LOD) defined by the
 * <a href="https://portal.ogc.org/files/?artifact_id=16675">CityGML 2.0 standard</a>.
 *
 * Obtained by `GARStreetscapeGeometry.quality`.
 */
typedef NS_ENUM(NSInteger, GARStreetscapeGeometryQuality) {
  /**
   * The quality of the streetscape geometry geometry is not defined, e.g.,
   * `GARStreetscapeGeometryType` is `#GARStreetscapeGeometryTypeTerrain`.
   */
  GARStreetscapeGeometryQualityNone = 0,

  /**
   * The `#GARStreetscapeGeometryTypeBuilding` mesh geometry is the building
   * footprint extruded up to a single flat top. The building contains
   * empty space above any angled roofs.
   */
  GARStreetscapeGeometryQualityBuildingLOD_1 = 1,

  /**
   * The `#GARStreetscapeGeometryTypeBuilding` mesh geometry is the building
   * footprint with rough heightmap. The geometry will closely follow simple
   * angled roofs. Chimneys and roof vents on top of roofs will poke outside
   * of the mesh.
   */
  GARStreetscapeGeometryQualityBuildingLOD_2 = 2,
};
