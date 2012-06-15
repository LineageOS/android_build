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

#include <ImageCollection.h>

ImageCollection::ImageCollection(const Options &options) :
                  mImages(),
                  mOptions(options),
                  mTotalTime(0) {
}

Image *ImageCollection::addImage(const std::string &imageName,
                                 uint32_t base,
                                 uint32_t size,
                                 const Bins &bins,
                                 bool isExe) {
    Image *img = new Image(imageName, base, size, bins, mOptions, isExe);
    mImages.push_back(img);
    for (Bins::const_iterator itr = bins.begin();
         itr != bins.end();
         ++itr) {
        mTotalTime += *itr;
    }
    return img;
}

void ImageCollection::dumpDotFormat() {
    for (_ImageCollection::iterator itr = mImages.begin();
         itr != mImages.end();
         ++itr) {
        (*itr)->updateHistogram();
    }
    std::set<std::string> outputSymbol;
    for (_ImageCollection::iterator itr = mImages.begin();
         itr != mImages.end();
         ++itr) {
        (*itr)->dumpDotFormat(outputSymbol, mTotalTime);
    }
}

void ImageCollection::dumpHistogram() {
    PRINT("  %%    cumulative     self ");
    PRINT("                self        total\n");
    PRINT(" time    seconds     seconds");
    PRINT("      calls    ms/call    ms/call   name\n");
    for (_ImageCollection::iterator itr = mImages.begin();
         itr != mImages.end();
         ++itr) {
        (*itr)->updateHistogram();
    }
    for (_ImageCollection::iterator itr = mImages.begin();
         itr != mImages.end();
         ++itr) {
        (*itr)->dumpHistogram(mTotalTime);
    }
}

Image *ImageCollection::findImage(uint32_t addr) {
    /*
     * Find current address is locate in which image.
     */
    for (_ImageCollection::iterator itr = mImages.begin();
         itr != mImages.end();
         ++itr) {
        if ((*itr)->addrInImage(addr)) {
            return *itr;
        }
    }
    return NULL;
}

void ImageCollection::dumpCallEdge() {
    for (_ImageCollection::iterator itr = mImages.begin();
         itr != mImages.end();
         ++itr) {
        Image *img = *itr;
        img->dumpCallEdge();
    }
}

void ImageCollection::addEdge(uint32_t callerPC,
                              uint32_t calleePC,
                              uint32_t count) {
    Image *callerImg = findImage(callerPC);
    Image *calleeImg = findImage(calleePC);
    if (callerImg == NULL) {
        ERROR("Unknown calller address %x", callerPC);
        return;
    }
    if (calleeImg == NULL) {
        ERROR("Unknown calllee address %x", calleePC);
        return;
    }
    Symbol *caller = callerImg->querySymbol(callerPC);
    Symbol *callee = calleeImg->querySymbol(calleePC);

    caller->addCalledSymbol(callee, count);
    callee->addCallBySymbol(caller, count);
}
