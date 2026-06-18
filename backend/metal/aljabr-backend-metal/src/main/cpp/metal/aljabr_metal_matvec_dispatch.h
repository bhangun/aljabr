/**
 * aljabr_metal_matvec_dispatch.h — low-level custom matvec Metal dispatch.
 */

#ifndef ALJABR_METAL_MATVEC_DISPATCH_H
#define ALJABR_METAL_MATVEC_DISPATCH_H

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

int aljabr_metal_dispatch_matvec_tb_half(void* C,
                                         const void* A,
                                         const void* B,
                                         int K,
                                         int N,
                                         id<MTLComputePipelineState> pipeline,
                                         NSUInteger threads);

int aljabr_metal_dispatch_matvec_tb_half_x4(void* C,
                                            const void* A,
                                            const void* B,
                                            int K,
                                            int N,
                                            id<MTLComputePipelineState> pipeline,
                                            NSUInteger threads);

int aljabr_metal_dispatch_matvec_tb_half_x8(void* C,
                                            const void* A,
                                            const void* B,
                                            int K,
                                            int N,
                                            id<MTLComputePipelineState> pipeline,
                                            NSUInteger threads);

int aljabr_metal_dispatch_matvec_t_half(void* C,
                                        const void* A,
                                        const void* B,
                                        int K,
                                        int N,
                                        id<MTLComputePipelineState> pipeline,
                                        NSUInteger threads);

int aljabr_metal_dispatch_matvec_tb_half_pair(void* C0,
                                              void* C1,
                                              const void* A,
                                              const void* B0,
                                              const void* B1,
                                              int K,
                                              int N,
                                              id<MTLComputePipelineState> pipeline,
                                              NSUInteger threads);

int aljabr_metal_dispatch_matvec_tb_half_triple_mixed(void* C0,
                                                      void* C1,
                                                      void* C2,
                                                      const void* A,
                                                      const void* B0,
                                                      const void* B1,
                                                      const void* B2,
                                                      int K,
                                                      int N0,
                                                      int N1,
                                                      int N2,
                                                      id<MTLComputePipelineState> pipeline,
                                                      NSUInteger threads);

#define dispatch_matvec_tb_half aljabr_metal_dispatch_matvec_tb_half
#define dispatch_matvec_tb_half_x4 aljabr_metal_dispatch_matvec_tb_half_x4
#define dispatch_matvec_tb_half_x8 aljabr_metal_dispatch_matvec_tb_half_x8
#define dispatch_matvec_t_half aljabr_metal_dispatch_matvec_t_half
#define dispatch_matvec_tb_half_pair aljabr_metal_dispatch_matvec_tb_half_pair
#define dispatch_matvec_tb_half_triple_mixed aljabr_metal_dispatch_matvec_tb_half_triple_mixed

#endif
