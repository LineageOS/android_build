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

#ifndef COMMON_H
#define COMMON_H

#define unlikely(expr) __builtin_expect (expr, 0)
#define likely(expr)   __builtin_expect (expr, 1)

#define MIN(a,b) ((a)<(b)?(a):(b)) /* no side effects in arguments allowed! */

static inline int is_host_little(void)
{
    short val = 0x10;
    return ((char *)&val)[0] != 0;
}

static inline long switch_endianness(long val)
{
	long newval;
	((char *)&newval)[3] = ((char *)&val)[0];
	((char *)&newval)[2] = ((char *)&val)[1];
	((char *)&newval)[1] = ((char *)&val)[2];
	((char *)&newval)[0] = ((char *)&val)[3];
	return newval;
}

#endif/*COMMON_H*/
