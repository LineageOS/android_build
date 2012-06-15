/*
 * Copyright (C) 2012 The Android Open Source Project
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

#ifndef _LIB_APROF_H
#define _LIB_APROF_H

#include <stdint.h>

#define APROF_TAG "APROF\0\0\0"
#define APROF_TAG_LENGTH 8
#define APROF_VERSION 0x1

#define APROF_ON 1
#define APROF_OFF 0

typedef struct {
    /* Constant literal "APROF\0\0\0" */
    char tag[APROF_TAG_LENGTH];
    /* Indicate the version of aprof file format */
    uint32_t version;
    /*
     * Indicate the sampel rate,
     * unit is sample times per second.
     */
    uint32_t sample_rate;
    /*
     * Indicate the pointer size in target,
     * for future extension.
     */
    uint32_t pointer_size;
} aprof_header;

/*
 * Histogram records
 */
typedef struct {
    uint32_t img_name_len;
    char *img_name;
    /*
     * Base address for image
     */
    uint32_t base;
    /*
     * Size of the image size
     */
    uint32_t size;
    /*
     * bin represent an equal amount of text-space.
     */
    uint32_t bin_size; /* How many bins? */
    uint32_t bin_mapped_size; /* Each bin mapping to how many byte? */
    uint16_t *bins;
} histogram32_header;

/*
 * Call graph edge
 */
typedef struct {
    uint32_t caller_pc;
    uint32_t callee_pc;
    uint32_t count;
} call_graph32_edge;

/*
 * Call graph records
 */
typedef struct {
    uint32_t num_edges;
    call_graph32_edge *edges;
} call_graph32_header;

/*
 * Define for header type
 */

#define APROF_EXECUTABLE_HISTOGRAM_HEADER 0x1
#define APROF_HISTOGRAM_HEADER 0x2
#define APROF_CALL_GRAPH_HEADER 0x3

#endif /* _LIB_APROF_H */
