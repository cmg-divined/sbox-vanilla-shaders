#ifndef COMMON_SHARED_H
#define COMMON_SHARED_H

// Todo: remove these
#define S_SPECULAR 1
#define ENABLE_NORMAL_MAPS 1

#include "system.fxc" // This should always be the first include in COMMON
#include "sbox_shared.fxc"
#include "common/classes/_classes.hlsl"

//
// Helpers
//

static const float ToDegrees = 57.2958f;
static const float ToRadians = 0.0174533f;

#endif