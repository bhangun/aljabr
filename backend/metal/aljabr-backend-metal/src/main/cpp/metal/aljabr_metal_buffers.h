/**
 * aljabr_metal_buffers.h — shared Metal buffer helpers.
 */

#ifndef ALJABR_METAL_BUFFERS_H
#define ALJABR_METAL_BUFFERS_H

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#include <stddef.h>

id<MTLBuffer> aljabr_metal_wrap_ptr(void* ptr, size_t bytes);
id<MTLBuffer> aljabr_metal_wrap_weight_ptr(const void* ptr, size_t bytes);

BOOL aljabr_metal_ensure_swiglu_scratch(size_t activation_bytes,
                                        id<MTLBuffer>* gate,
                                        id<MTLBuffer>* up,
                                        id<MTLBuffer>* combined);

BOOL aljabr_metal_ensure_swiglu_combined_scratch(size_t activation_bytes,
                                                 id<MTLBuffer>* combined);

#define wrap_ptr aljabr_metal_wrap_ptr
#define wrap_weight_ptr aljabr_metal_wrap_weight_ptr
#define ensure_swiglu_scratch aljabr_metal_ensure_swiglu_scratch
#define ensure_swiglu_combined_scratch aljabr_metal_ensure_swiglu_combined_scratch

#endif
