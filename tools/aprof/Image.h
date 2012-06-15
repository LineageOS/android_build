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

#ifndef _IMAGE_H
#define _IMAGE_H

#include <Options.h>
#include <SymbolTable.h>

#include <map>
#include <set>
#include <string>
#include <vector>
#include <stdint.h>

typedef std::map<Symbol*, uint32_t> Histogram;
typedef std::vector<uint16_t> Bins;

class Image {
public:

    Image(const std::string &imageName, uint32_t base,
          uint32_t size, const Bins &bins,
          const Options &options, bool isExe);
    ~Image();

    const std::string &getName() const;
    bool readSymbol();
    void updateHistogram();
    bool addrInImage(uint32_t addr);
    Symbol *querySymbol(uint32_t addr);
    void dumpCallEdge();
    void dumpHistogram(uintmax_t totalTime);
    void dumpDotFormat(std::set<std::string> &outputSymbol,
                       uintmax_t totalTime);
private:
    const Options &mOptions;
    std::string mImageName;
    uint32_t mBase;
    uint32_t mSize;
    Bins mBins;
    SymbolTable mSymbolTable;
    bool mUpdateHistogramFlag;
    bool mIsExecutable;
};

#endif /* _IMAGE_H */
