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

#ifndef _IMAGE_COLLECTION_H
#define _IMAGE_COLLECTION_H

#include <Image.h>
#include <Options.h>
#include <debug.h>

#include <list>
#include <set>
#include <string>
#include <stdint.h>

class ImageCollection {
public:
    ImageCollection(const Options &options);
    void insert(Image *img);
    Image *addImage(const std::string &imageName, uint32_t base,
                    uint32_t size, const Bins &bins, bool isExe);
    void updateHistogram();
    Image *findImage(uint32_t addr);
    void addEdge(uint32_t callerPC, uint32_t calleePC, uint32_t count);

    void dumpDotFormat();
    void dumpCallEdge();
    void dumpHistogram();
private:
    typedef std::list<Image*> _ImageCollection;
    _ImageCollection mImages;
    const Options &mOptions;
    uintmax_t mTotalTime;
};

#endif /* _IMAGE_COLLECTION_H */
