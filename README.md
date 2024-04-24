common/light.hlsl:

GetLightCookie(float3 vPositionWs): Returns the cookie texture projection for the light at the specified world space position.
Example usage: GetLightCookie(float3 vPositionWs);

GetLightColor(float3 vPositionWs): Retrieves the color of the light at the specified world space position.
Example usage: GetLightColor(float3 vPositionWs);

GetLightDirection(float3 vPositionWs): Provides the direction vector from the light to the specified world space position.
Example usage: GetLightDirection(float3 vPositionWs);

GetLightPosition(): Fetches the position of the light in world space.
Example usage: GetLightPosition();

GetLightAttenuation(float3 vPositionWs): Determines the attenuation of the light based on its distance from the specified world space position.
Example usage: GetLightAttenuation(float3 vPositionWs);

DynamicShadows(float3 vPositionWs): Evaluates whether dynamic shadows are active for the light at the specified world space position.
Example usage: DynamicShadows(float3 vPositionWs);

GetLightVisibility(float3 vPositionWs): Calculates the visibility of the light from the specified world space position, considering occlusions.
Example usage: GetLightVisibility(float3 vPositionWs);

common/lightbinner.hlsl:

GetEnvMapStartOffset(): Returns the starting offset index for environment maps.
Example usage: GetEnvMapStartOffset();

GetLightOffsetForTile(uint2 tile): Retrieves the starting offset for lights within a tile.
Example usage: GetLightOffsetForTile(uint2 tile);

GetNumLightsPerTile(uint2 tile): Returns the number of lights in a specified tile.
Example usage: GetNumLightsPerTile(uint2 tile);

LoadLightByTile(uint2 tile, uint lightIndex): Loads a light by its index within a specified tile.
Example usage: LoadLightByTile(uint2 tile, uint lightIndex);

StoreLight(uint2 tile, uint lightID): Stores a light's ID within a tile.
Example usage: StoreLight(uint2 tile, uint lightID);

GetTileForScreenPosition(float2 vPositionSs): Computes the tile index for a screen space position.
Example usage: GetTileForScreenPosition(float2 vPositionSs);

GetNumLights(uint2 vTile): Returns the number of lights in a given tile.
Example usage: GetNumLights(uint2 vTile);

TranslateLightIndex(uint iLightIndex, uint2 vTile): Translates a global light index to a tile-specific index.
Example usage: TranslateLightIndex(uint iLightIndex, uint2 vTile);

common/light.environment.hlsl:

GetTargetLuminanceOfCubemap(Material m): Determines the target luminance of a cubemap based on the material properties.
Example usage: GetTargetLuminanceOfCubemap(Material m);
GetEnvMapColor(Material m): Retrieves the color of an environment map for the specified material.
Example usage: GetEnvMapColor(Material m);
GetEnvMapPosition(float3 vPositionWs): Computes the position in the environment map for a given world space position.
Example usage: GetEnvMapPosition(float3 vPositionWs);
GetEnvMapAttenuation(): Gets the attenuation factor for environmental mapping.
Example usage: GetEnvMapAttenuation();
Init(float3 vPositionWs, float2 vPositionSs, Material m, uint lightIndex): Initializes an environmental light based on material and position.
Example usage: Init(float3 vPositionWs, float2 vPositionSs, Material m, uint lightIndex);
From(float3 vPositionWs, float2 vPositionSs, Material m, uint nLightIndex): Creates an environmental light from specified parameters.
Example usage: From(float3 vPositionWs, float2 vPositionSs, Material m, uint nLightIndex);
Count(float2 vPositionSs): Returns the number of environmental lights based on screen space position.
Example usage: Count(float2 vPositionSs);

common/light.static.hlsl:

Init(float3 vPositionWs, uint nLightIndex, float lightStrength): Initializes a light at the specified position with an index and strength.
Example usage: Init(float3 vPositionWs, uint nLightIndex, float lightStrength);

From(float3 vPositionWs, uint nLightIndex): Retrieves light data for a static light at a specific world space position.
Example usage: From(float3 vPositionWs, uint nLightIndex);

GetLightmappedLightIndices(float2 vLightmapUV): Fetches indices of lights mapped to a specific lightmap UV.
Example usage: GetLightmappedLightIndices(float2 vLightmapUV);

GetLightmappedLightStrengths(float2 vLightmapUV): Fetches strength values of lights from a lightmap UV.
Example usage: GetLightmappedLightStrengths(float2 vLightmapUV);

From(float3 vPositionWs, float2 vLightmapUV, uint nLightIndex) (duplicated): Retrieves light data using additional lightmap UV information.
Example usage: From(float3 vPositionWs, float2 vLightmapUV, uint nLightIndex);

Count(): Returns the total count of static lights.
Example usage: Count();

common/light.tiledrendering.hlsl:

GetNumTiles(): Returns the number of tiles in the rendering area.
Example usage: GetNumTiles();

GetTileIdFlattened(uint2 tile): Converts a 2D tile ID to a flattened index.
Example usage: GetTileIdFlattened(uint2 tile);

GetTileIdFlattenedEnvMap(uint2 tile): Converts a 2D tile ID to a flattened index for environment maps.
Example usage: GetTileIdFlattenedEnvMap(uint2 tile);

GetLightCountIndex(uint2 tile): Retrieves the count index for lights in a given tile.
Example usage: GetLightCountIndex(uint2 tile);

GetCubeCountIndex(uint2 tile): Retrieves the count index for cube maps in a specified tile.
Example usage: GetCubeCountIndex(uint2 tile);

GetLightStartOffset(): Returns the starting offset for light data.
Example usage: GetLightStartOffset();

GetEnvMapStartOffset(): Returns the starting offset for environment map data.
Example usage: GetEnvMapStartOffset();

GetLightOffsetForTile(uint2 tile): Retrieves the starting light data offset for a specified tile.
Example usage: GetLightOffsetForTile(uint2 tile);

GetEnvMapOffsetForTile(uint2 tile): Retrieves the starting environment map data offset for a specified tile.
Example usage: GetEnvMapOffsetForTile(uint2 tile);

GetNumLightsPerTile(uint2 tile): Returns the number of lights in a given tile.
Example usage: GetNumLightsPerTile(uint2 tile);

LoadLightByTile(uint2 tile, uint lightIndex): Loads light data by tile and light index.
Example usage: LoadLightByTile(uint2 tile, uint lightIndex);

GetNumEnvMapsPerTile(uint2 tile): Retrieves the number of environment maps in a specific tile.
Example usage: GetNumEnvMapsPerTile(uint2 tile);

LoadEnvMapByTile(uint2 tile, uint envMapIndex): Loads environment map data by tile and environment map index.
Example usage: LoadEnvMapByTile(uint2 tile, uint envMapIndex);

StoreLight(uint2 tile, uint lightID): Stores a light ID within a specific tile.
Example usage: StoreLight(uint2 tile, uint lightID);

StoreEnvMap(uint2 tile, uint cubeID): Stores a cube map ID within a specific tile.
Example usage: StoreEnvMap(uint2 tile, uint cubeID);

GetTileForScreenPosition(float2 vPositionSs): Calculates the tile index for a given screen space position.
Example usage: GetTileForScreenPosition(float2 vPositionSs);

GetNumLights(uint2 vTile): Returns the number of lights for a specific tile.
Example usage: GetNumLights(uint2 vTile);

TranslateLightIndex(uint iLightIndex, uint2 vTile): Translates a global light index into a tile-specific light index.
Example usage: TranslateLightIndex(uint iLightIndex, uint2 vTile);

GetNumEnvMaps(uint2 vTile): Retrieves the number of environment maps for a given tile.
Example usage: GetNumEnvMaps(uint2 vTile);

TranslateEnvMapIndex(uint iEnvMapIndex, uint2 vTile): Translates a global environment map index into a tile-specific index.
Example usage: TranslateEnvMapIndex(uint iEnvMapIndex, uint2 vTile);

common/material.hlsl:

Init(): Initializes a material to default settings.
Example usage: Init();

From(PixelInput i): Creates a material based on pixel input, typically used to set material properties like color and texture based on the data provided by pixel shaders.
Example usage: From(PixelInput i);

lerp(Material a, Material b, float amount): Linearly interpolates between two materials a and b based on the amount, which ranges from 0 to 1. This can be used for blending materials in transitions or animations.
Example usage: lerp(Material a, Material b, float amount);

common/pixel.raytrace.ssr.hlsl:

ReferenceImportanceSampleGGX(float2 Xi, float roughness, float3 N): Samples a GGX distribution for roughness on a normal.
Example usage: ReferenceImportanceSampleGGX(float2 Xi, float roughness, float3 N);

ProjectPosition(float3 origin, float4x4 mat): Projects a 3D position using a matrix.
Example usage: ProjectPosition(float3 origin, float4x4 mat);

ProjectDirection(float3 origin, float3 direction, float3 screen_space_origin, float4x4 mat): Projects a direction vector from 3D to screen space.
Example usage: ProjectDirection(float3 origin, float3 direction, float3 screen_space_origin, float4x4 mat);

InvProjectPosition(float3 coord, float4x4 mat): Converts a screen space position back to world coordinates.
Example usage: InvProjectPosition(float3 coord, float4x4 mat);

FFX_SSSR_LoadDepth(int2 pixel_coordinate, int mip): Loads depth information for screen space specular reflections.
Example usage: FFX_SSSR_LoadDepth(int2 pixel_coordinate, int mip);

FFX_SSSR_ScreenSpaceToViewSpace(float3 screen_space_position): Converts a screen space position to view space.
Example usage: FFX_SSSR_ScreenSpaceToViewSpace(float3 screen_space_position);

ScreenSpaceToWorldSpace(float3 screen_space_position): Converts a screen space position to world space coordinates.
Example usage: ScreenSpaceToWorldSpace(float3 screen_space_position);

TraceSSRWorldRay(PixelInput i, float3 vReflectWs): Traces a ray in the world space for screen space reflections.
Example usage: TraceSSRWorldRay(PixelInput i, float3 vReflectWs);

common/shadingmodel.hlsl:

DoToolVisualizations(in float4 vColor, Material m, LightingTerms_t lightingTerms): Applies tool visualizations over the material rendering.
Example usage: DoToolVisualizations(in float4 vColor, Material m, LightingTerms_t lightingTerms);

DoAtmospherics(float3 vPositionWs, float2 vPositionSs, float4 vColor, bool bAdditiveBlending = false): Processes atmospheric effects for the given position and color.
Example usage: DoAtmospherics(float3 vPositionWs, float2 vPositionSs, float4 vColor, bool bAdditiveBlending = false);

DoPostProcessing(const Material material, float4 color): Applies post-processing effects based on the material and input color.
Example usage: DoPostProcessing(const Material material, float4 color);

MaterialToCombinerInput(Material m): Converts material properties to combiner input.
Example usage: MaterialToCombinerInput(Material m);

Shade(Material m): Calculates shading for the material.
Example usage: Shade(Material m);

MaterialToCombinerInput(PixelInput i, Material m): Converts material properties from pixel input to combiner input.
Example usage: MaterialToCombinerInput(PixelInput i, Material m);

Shade(PixelInput i, Material m): Calculates shading for the material based on pixel input.
Example usage: Shade(PixelInput i, Material m);

common/classes/Depth.hlsl:

Get(float2 screenPosition): Retrieves the depth value at a specified screen position.
Example usage: Get(float2 screenPosition);

Normalize(float depth): Normalizes the depth value to a standard range.
Example usage: Normalize(float depth);

GetNormalized(float2 screenPosition): Retrieves and normalizes the depth value at a specified screen position.
Example usage: GetNormalized(float2 screenPosition);

GetLinear(float2 screenPosition): Converts the depth value from non-linear to linear at a specified screen position.
Example usage: GetLinear(float2 screenPosition);

WorldPosition(float depth, float3 direction): Calculates the world position using a depth value and a direction vector.
Example usage: WorldPosition(float depth, float3 direction);

GetWorldPosition(float2 screenPosition): Calculates the world position from a screen position using depth information.
Example usage: GetWorldPosition(float2 screenPosition);

common/classes/Fog.hlsl:

Apply(float3 worldPos, float2 screenPos, float3 color): Applies fog effects based on world position, screen position, and base color.
Example usage: Apply(float3 worldPos, float2 screenPos, float3 color);

common/classes/Sheet.hlsl:

Blended(in float4 data, in float sequence, in float time, in float2 uv, out float2 a, out float2 b, out float blend): Calculates blended animation frames for textures based on input parameters, providing outputs for two texture coordinates and a blend factor.
Example usage: Blended(in float4 data, in float sequence, in float time, in float2 uv, out float2 a, out float2 b, out float blend);

Single(float4 data, float sequence, float time, in float2 uv): Calculates a single frame texture coordinate based on animation data and a specific time.
Example usage: Single(float4 data, float sequence, float time, in float2 uv);

common/thirdparty/ffx_sssr.hlsl:

FFX_SSSR_InitialAdvanceRay: Initializes the ray tracing process by setting the initial position and traversal parameter.
Example usage: FFX_SSSR_InitialAdvanceRay(float3 origin, float3 direction, float3 inv_direction, float2 current_mip_resolution, float2 current_mip_resolution_inv, float2 floor_offset, float2 uv_offset, out float3 position, out float current_t);

FFX_SSSR_AdvanceRay: Advances the ray step by step in the specified direction, updating position and time accordingly.
Example usage: FFX_SSSR_AdvanceRay(float3 origin, float3 direction, float3 inv_direction, float2 current_mip_position, float2 current_mip_resolution_inv, float2 floor_offset, float2 uv_offset, float surface_z, inout float3 position, inout float current_t);

FFX_SSSR_GetMipResolution: Retrieves the resolution for a specified mip level based on screen dimensions.
Example usage: FFX_SSSR_GetMipResolution(float2 screen_dimensions, int mip_level);

FFX_SSSR_HierarchicalRaymarch: Performs a hierarchical ray march to find intersections, considering various levels of detail.
Example usage: FFX_SSSR_HierarchicalRaymarch(float3 origin, float3 direction, float2 screen_size, const int most_detailed_mip, const uint max_traversal_intersections, const bool mipChain, const bool backTracing, out bool valid_hit);

FFX_SSSR_ValidateHit: Validates a potential hit point to ensure it meets certain criteria (e.g., within screen bounds and not occluded).
Example usage: FFX_SSSR_ValidateHit(float3 hit, float2 uv, float3 world_space_ray_direction, float2 screen_size, float depth_buffer_thickness);

Conditional Statements (Misidentified as Functions)
Some conditional statements were mistakenly identified as functions, which I've noted below for clarity:

if(backTracing): Used to conditionally execute code if back tracing is enabled.
if(any(hit.xy < 0) || any(hit.xy > 1)): Checks if the hit coordinates are outside the viewport.
if(surface_z == 0.0) and if(surface_z == 1.0): Conditional checks for specific depth values indicating special conditions.
These functions and statements are crucial for implementing Screen Space Specular Reflections (SSSR) in shader programs, providing detailed control over how light reflections are computed based on screen space data.

common/utils/normal.hlsl:

TransformNormal(float3 vNormalTs, float3 vGeometricNormalWs, float3 vTangentUWs, float3 vTangentVWs): Transforms a tangent space normal to world space using the provided tangent and bitangent vectors.
Example usage: TransformNormal(float3 vNormalTs, float3 vGeometricNormalWs, float3 vTangentUWs, float3 vTangentVWs);

NormalWorldToTangent(float3 vNormalWs, float3 vGeometricNormalWs, float3 vTangentUWs, float3 vTangentVWs): Transforms a world space normal to tangent space using the provided tangent and bitangent vectors.
Example usage: NormalWorldToTangent(float3 vNormalWs, float3 vGeometricNormalWs, float3 vTangentUWs, float3 vTangentVWs);

common/utils/triplanar.hlsl:

Tex2DTriplanar(in Texture2D texture, in SamplerState samplerState, float3 vPositionWs, float3 vNormalWs, float2 vTile = 512.0f, float flBlend = 1.0f, float2 vTexScale = 1.0f): Samples a texture using triplanar mapping based on world position and normal, allowing control over tiling and blending.
Example usage: Tex2DTriplanar(in Texture2D texture, in SamplerState samplerState, float3 vPositionWs, float3 vNormalWs, float2 vTile, float flBlend, float2 vTexScale);

Tex2DTriplanar(in Texture2D texture, in SamplerState samplerState, PixelInput pixelInput, float2 vTile = 512.0f, float flBlend = 1.0f, float2 vTexScale = 1.0f): Performs triplanar texturing based on input from pixel data, with parameters for tiling, blending, and texture scaling.
Example usage: Tex2DTriplanar(in Texture2D texture, in SamplerState samplerState, PixelInput pixelInput, float2 vTile, float flBlend, float2 vTexScale);

postprocess/common.hlsl: 

GetLuminance(float3 vColor): Calculates the luminance of a color in RGB format.
Example usage: GetLuminance(float3 vColor);

DistanceFalloff(float currentDistance, float startDistance, float endDistance, float falloffExponent): Computes the falloff based on distance with an exponential factor to smooth transitions.
Example usage: DistanceFalloff(float currentDistance, float startDistance, float endDistance, float falloffExponent);

postprocess/functions.hlsl:

Saturation(float3 vColor, float flSaturationAmount, bool saturateResult = true): Adjusts the saturation of a color and optionally clamps the result.
Example usage: Saturation(float3 vColor, float flSaturationAmount, saturateResult);

PaniniProjection(float2 vTexCoords, float flDistance): Applies the Panini projection to texture coordinates to reduce distortion.
Example usage: PaniniProjection(float2 vTexCoords, float flDistance);

MotionBlur(Texture2D tColorBuffer, SamplerState sSampler, float2 vTexCoords, float2 vVelocityVector, int sNumSamples): Applies motion blur based on velocity vectors.
Example usage: MotionBlur(Texture2D tColorBuffer, SamplerState sSampler, float2 vTexCoords, float2 vVelocityVector, sNumSamples);

GaussianBlur(Texture2D tColorBuffer, SamplerState sSampler, float2 vTexCoords, float2 flSize): Performs Gaussian blur over a texture with a specified size.
Example usage: GaussianBlur(Texture2D tColorBuffer, SamplerState sSampler, float2 vTexCoords, flSize);

CircleOfConfusion(float flDepth, float flFocalLength, float flFocalDistance, float flFocalRegion, float flAperture): Calculates the circle of confusion for depth of field effects based on depth and camera properties.
Example usage: CircleOfConfusion(float flDepth, flFocalLength, flFocalDistance, flFocalRegion, flAperture);

Sharpen(Texture2D tColorBuffer, SamplerState sSampler, float3 vColor, float2 vTexCoords, float flStrength): Applies a sharpening filter to the texture.
Example usage: Sharpen(Texture2D tColorBuffer, SamplerState sSampler, float3 vColor, float2 vTexCoords, flStrength);

raytracing/intersection.hlsl:

IntersectBox(float3 vPosStartWS, float3 invDir, unsigned int nodeNum, float3 vMaxs, float3 vMins): Computes the intersection of a ray with an axis-aligned bounding box.
Example usage: IntersectBox(float3 vPosStartWS, float3 invDir, unsigned int nodeNum, float3 vMaxs, float3 vMins);

IntersectSphere(in float3 vOrigin, in float3 vDir, in float3 vCenter, float fRadius): Calculates the intersection of a ray with a sphere.
Example usage: IntersectSphere(in float3 vOrigin, in float3 vDir, in float3 vCenter, float fRadius);

raytracing/reflections.hlsl:

ReferenceImportanceSampleGGX(float2 Xi, float roughness, float3 N): Samples a GGX distribution based on input roughness and normal.
Example usage: ReferenceImportanceSampleGGX(float2 Xi, float roughness, float3 N);

ProjectPosition(float3 origin, float4x4 mat): Projects a 3D point using a transformation matrix.
Example usage: ProjectPosition(float3 origin, float4x4 mat);

ProjectDirection(float3 origin, float3 direction, float3 screen_space_origin, float4x4 mat): Projects a direction vector using a transformation matrix.
Example usage: ProjectDirection(float3 origin, float3 direction, float3 screen_space_origin, float4x4 mat);

WorldTrace(PixelInput i, float3 vReflectWs): Traces a ray in the world based on input pixel data and reflection direction.
Example usage: WorldTrace(PixelInput i, float3 vReflectWs);

raytracing/sdf.hlsl: 
sdBox(float3 p, float3 b): Signed distance function for a box.
Example usage: sdBox(float3 p, float3 b);

sdSphere(float3 p, float s): Signed distance function for a sphere.
Example usage: sdSphere(float3 p, float s);

sdCapsule(float3 p, float3 a, float3 b, float r): Signed distance function for a capsule.
Example usage: sdCapsule(float3 p, float3 a, float3 b, float r);

sdCylinder(float3 p, float h, float r): Signed distance function for a cylinder.
Example usage: sdCylinder(float3 p, float h, float r);

map(float3 vPosWs, int instance = 0): Maps a 3D position to a signed distance field.
Example usage: map(float3 vPosWs, int instance);

softshadow(in float3 ro, in float3 rd, float mint, float maxt, float roughness, int instance = 0): Computes soft shadows for a ray within a signed distance field.
Example usage: softshadow(in float3 ro, in float3 rd, mint, maxt, roughness, instance);

TraceSDF(float3 vNormalWs, float flRoughness, float3 vViewRayWs, float3 vPosWs): Traces a signed distance field to compute interactions with materials or lights.
Example usage: TraceSDF(float3 vNormalWs, float flRoughness, float3 vViewRayWs, float3 vPosWs);

terrain/TerrainClipmap.hlsl
roundToIncrement(float2 value, float increment): Rounds a 2D vector to the nearest increment specified.
Example usage: roundToIncrement(float2 value, float increment);

terrain/TerrainCommon.hlsl
Terrain_Normal(Texture2D HeightMap, float2 uv, out float3 TangentU, out float3 TangentV): Computes the normal at a given UV coordinate on a height map and outputs the tangent vectors.
Example usage: Terrain_Normal(Texture2D HeightMap, float2 uv, out float3 TangentU, out float3 TangentV);

Terrain_ProcGrid(in float2 p, out float3 albedo, out float roughness): Processes grid data to output albedo and roughness properties.
Example usage: Terrain_ProcGrid(in float2 p, out float3 albedo, out float roughness);

Terrain_Debug(PixelInput i, Material m): Provides debugging visualizations based on pixel input and material properties.
Example usage: Terrain_Debug(PixelInput i, Material m);

Terrain_WireframeColor(uint lodLevel): Determines the color of the wireframe based on the level of detail.
Example usage: Terrain_WireframeColor(uint lodLevel);

terrain/TerrainNoTile.hlsl
hash4(float2 p): Generates a 4-component hash from a 2D input vector, typically used for procedural texturing or similar non-repeating patterns.
Example usage: hash4(float2 p);

textureNoTile2(Texture2D tex, SamplerState sampler, in float2 uv, float v): Samples a texture without tiling artifacts using a secondary method.
Example usage: textureNoTile2(Texture2D tex, SamplerState sampler, in float2 uv, float v);

textureNoTileCalcUVs(in float2 uv): Calculates UV coordinates to be used for non-tiling texture sampling.
Example usage: textureNoTileCalcUVs(in float2 uv);

textureNoTile(Texture2D tex, SamplerState sampler, in NoTileUVs ntuvs): Samples a texture based on pre-computed non-tiling UVs.
Example usage: textureNoTile(Texture2D tex, SamplerState sampler, in NoTileUVs ntuvs);

ui/pixel.hlsl:

UI_CommonProcessing_Pre(PS_INPUT i): Pre-processes input for user interface elements in the pixel shader.
Example usage: UI_CommonProcessing_Pre(PS_INPUT i);

UI_CommonProcessing_Post(PS_INPUT i, PS_OUTPUT o): Post-processes output after initial rendering steps for user interface elements.
Example usage: UI_CommonProcessing_Post(PS_INPUT i, PS_OUTPUT o);

ui/scissor.hlsl:

GetWorldPixelPosition(PS_INPUT i): Calculates the world position of a pixel from its shader input.
Example usage: GetWorldPixelPosition(PS_INPUT i);

IsOutsideBox(float2 vPos, float4 vRect, float4 vRadius, float4x4 matTransform): Determines if a position is outside a defined rectangular area, taking transformations into account.
Example usage: IsOutsideBox(float2 vPos, float4 vRect, float4 vRadius, float4x4 matTransform);

SoftwareScissoring(PS_INPUT i): Implements a software-based scissoring test to clip pixels that are outside a specific area.
Example usage: SoftwareScissoring(PS_INPUT i);

vertex.hlsl:

MainVs(VS_INPUT i): Main vertex shader function that processes vertex inputs and passes them to the pixel shader.
Example usage: MainVs(VS_INPUT i);
