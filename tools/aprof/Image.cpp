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

#include <Image.h>
#include <Options.h>
#include <debug.h>

#include <string.h>
#include <stdint.h>
#include <assert.h>
#include <limits.h>
#include <fcntl.h>

Image::Image(const std::string &imageName, uint32_t base,
             uint32_t size, const Bins &bins,
             const Options &options, bool isExe) :
          mOptions(options),
          mImageName(imageName),
          mBase(base),
          mSize(size),
          mBins(bins),
          mSymbolTable(this,
                       std::string("<")+imageName+std::string(">"),
                       base),
          mUpdateHistogramFlag(false),
          mIsExecutable(isExe) {
}

Image::~Image() {
}

bool Image::addrInImage(uint32_t addr) {
    return (addr >= mBase &&
            addr <  (mBase+mSize));
}

Symbol *Image::querySymbol(uint32_t addr) {
    return mSymbolTable.find(addr);
}

void Image::dumpDotFormat(std::set<std::string> &outputSymbol,
                          uintmax_t totalTime) {
    updateHistogram();
    mSymbolTable.dumpDotFormat(outputSymbol, totalTime);
}

void Image::dumpHistogram(uintmax_t totalTime) {
    updateHistogram();
    mSymbolTable.dumpHistogram(totalTime, mOptions);
}

void Image::updateHistogram() {
    if (mUpdateHistogramFlag) return;
    mUpdateHistogramFlag = true;

    size_t i, binLen = mBins.size();
    /*
     * Caclulate self execution time for each symbol,
     * self time mean the execution time exclude the innder function.
     */
    for (i=0;i<binLen;++i) {
        if (mBins[i] == 0) continue;
        uint32_t addr = (i * 2 * 2)  + mBase;
        Symbol *symbol = mSymbolTable.find(addr);
        INFO("Symbol %s(%x) : %ju ms\n",
             symbol->getName().c_str(),
             addr, mOptions.toMS(mBins[i]));
        symbol->setSelfTime(symbol->getSelfTime() + mBins[i]);
    }

    /*
     * Now, caclulate cumulative execution time for each symbol,
     * cumulative time inculude the execution time of innder function.
     */
    mSymbolTable.updateCumulativeTime();
}

static FILE *findFile(const std::string &filename,
                      const Options &options,
                      bool isExecutable) {
    const LibPaths &libPaths = options.libPaths;
    FILE *fd = NULL;
    if (isExecutable) {
        if (filename != basename(options.imgFile.c_str()) ) {
            WARING("Waring! the image name of executable are "
                   "difference from the profiling file.\n");
        }
        fd = fopen(options.imgFile.c_str(), "r");
        if (fd != NULL) return fd;
    }

    fd = fopen(filename.c_str(), "r");
    if (fd != NULL) return fd;
    for (LibPaths::const_iterator itr = libPaths.begin();
         itr != libPaths.end();
         ++itr) {
        std::string path = *itr;
        path += "/";
        path += filename;
        fd = fopen(path.c_str(), "r");
        if (fd != NULL) return fd;
    }
    INFO("Can't found %s\n", filename.c_str());
    FAILIF(isExecutable, "Can't find executable image '%s'\n",
                         filename.c_str());
    return NULL;
}

bool Image::readSymbol() {
    /*
     * Invalidate the histogram data.
     */
    mUpdateHistogramFlag = false;

    FILE *fd = findFile(mImageName, mOptions, mIsExecutable);
    return mSymbolTable.read(fd);
}

const std::string &Image::getName() const{
    return mImageName;
}

void Image::dumpCallEdge() {
    mSymbolTable.dumpCallEdge(mOptions);
}
