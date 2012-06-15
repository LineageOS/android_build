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

#ifndef _SYMBOL_H
#define _SYMBOL_H

#include <vector>
#include <map>
#include <set>
#include <string>
#include <stdint.h>

class Image;
class Symbol;
class Options;

typedef std::map<Symbol *, unsigned> CallInfo;

class Symbol {
public:
    Symbol(Image *img, const std::string &name,
           uint32_t addr, uint32_t size);

    const std::string &getName() const;
    std::string getDotNodeName() const;
    uint32_t getAddr() const;
    uint32_t getSize() const;

    uintmax_t getCumulativeTime() const;
    uintmax_t getSelfTime() const;

    void setCumulativeTime(uintmax_t time);
    void setSelfTime(uintmax_t time);

    void dumpHistogram(uintmax_t totalTime, const Options &options);
    void updateCumulativeTime();

    void dumpDotFormat(std::set<std::string> &outputSymbol,
                       uintmax_t totalTime);

    bool inSameImage(const Symbol *sym) const;

    void addCalledSymbol(Symbol *sym, unsigned count);
    void addCallBySymbol(Symbol *sym, unsigned count);

    void dumpCallByInfo(const Options &options) const;
private:
    void updateCumulativeTime(uintmax_t cumulativeTime);

    Image *mImg;
    std::string mName;
    uint32_t mAddr;
    uint32_t mSize;

    uintmax_t mCumulativeTime;
    uintmax_t mSelfTime;

    CallInfo mCalled;
    CallInfo mCallBy;

    /*
     * Use for update cumulative time
     */
    Symbol *tag;
};

#endif
