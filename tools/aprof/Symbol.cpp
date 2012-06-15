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

#include <Symbol.h>
#include <Options.h>
#include <stdio.h>
#include <debug.h>
#include <Image.h>

Symbol::Symbol(Image *img, const std::string &name,
               uint32_t addr, uint32_t size) :
         mImg(img),
         mName(name),
#ifdef ARM_SPECIFIC_HACKS
         /* If the symbol addresses a Thumb instruction,
            the value of address with bit zero set;
            so just discard it here.
          */
         mAddr(addr & (~(uint32_t)(1))),
#else
         mAddr(addr),
#endif
         mSize(size),
         mCumulativeTime(0),
         mSelfTime(0),
         mCalled(),
         mCallBy() {
}

const std::string &Symbol::getName() const{
    return mName;
}

std::string Symbol::getDotNodeName() const{
    return mImg->getName() + '_' + mName;
}

uint32_t Symbol::getAddr() const{
    return mAddr;
}

uint32_t Symbol::getSize() const{
    return mSize;
}

uintmax_t Symbol::getCumulativeTime() const{
    return mCumulativeTime;
}

uintmax_t Symbol::getSelfTime() const{
    return mSelfTime;
}

void Symbol::setCumulativeTime(uintmax_t time) {
    mCumulativeTime = time;
}

void Symbol::setSelfTime(uintmax_t time) {
    mSelfTime = time;
}

bool Symbol::inSameImage(const Symbol *sym) const {
    return sym->mImg == this->mImg;
}

static std::string percent2color(double p) {
    struct Color {
       int r,g,b;
    };
    Color maxColor = {255, 0, 0};
    Color minColor = {0, 0, 255};
    Color color;
    char buf[1024];
    color.r = minColor.r + (p * 0.01) * (maxColor.r - minColor.r);
    color.g = minColor.g + (p * 0.01) * (maxColor.g - minColor.g);
    color.b = minColor.b + (p * 0.01) * (maxColor.b - minColor.b);
    color.r = std::min(color.r, 255);
    color.g = std::min(color.g, 255);
    color.b = std::min(color.b, 255);
    sprintf(buf,"#%02x%02x%02x", color.r, color.g, color.b);
    return std::string(buf);
}

template<class T> static
double toPercent(T a, T b){
    if (b == 0) return 0;
    double p = (double)a/(double)b *100.0;
    return std::min(p, 100.0);
}

void Symbol::dumpDotFormat(std::set<std::string> &outputSymbol,
                           uintmax_t totalTime) {
    std::string dotNodeName = this->getDotNodeName();
    if (outputSymbol.count(dotNodeName) > 0) {
        return;
    }
    if (mCallBy.size() > 0 ||
        mCalled.size() > 0 ||
        mSelfTime > 0) {
        outputSymbol.insert(dotNodeName);
        double cummPercent = toPercent(mCumulativeTime, totalTime);
        double selfPercent = toPercent(mSelfTime, totalTime);
        uintmax_t count=0;
        std::string nodeColor = percent2color(cummPercent);
        for (CallInfo::iterator itr = mCallBy.begin();
             itr != mCallBy.end();
             ++itr) {
            count += itr->second;
        }
        if (count != 0) {
            PRINT("    \"%s\" ["
                  " label=\"%s\\n(%s)\\n%.2f %%\\n(%.2f %%)\\n%ju x\","
                  " color=\"%s\""
                  "];\n",
                 dotNodeName.c_str(),
                 this->getName().c_str(),
                 mImg->getName().c_str(),
                 cummPercent,
                 selfPercent,
                 count,
                 nodeColor.c_str());
        } else {
            PRINT("    \"%s\" ["
                  " label=\"%s\\n(%s)\\n%.2f %%\\n(%.2f %%)\","
                  " color=\"%s\""
                  "];\n",
                 dotNodeName.c_str(),
                 this->getName().c_str(),
                 mImg->getName().c_str(),
                 cummPercent,
                 selfPercent,
                 nodeColor.c_str());
        }
    }
    for (CallInfo::iterator itr = mCallBy.begin();
         itr != mCallBy.end();
         ++itr) {
        Symbol *sym = itr->first;
        unsigned count = itr->second;
        std::string symDotName =sym->getDotNodeName();
        /* Ouput edge if first time visit */
        if (outputSymbol.count(symDotName) == 0) {
            double timePercent = toPercent(sym->getCumulativeTime(),
                                           this->getCumulativeTime());
            PRINT("    \"%s\" -> \"%s\" ["
                  "label=\"%.2f %%\\n%u x\","
                  "arrowsize=%.2f,"
                  "penwidth=%.2f,"
                  "]\n",
                  symDotName.c_str(),
                  dotNodeName.c_str(),
                  timePercent,
                  count,
                  std::max(timePercent*0.02, 0.5),
                  std::max(timePercent*0.04, 0.5));
        }
        if (sym == this) {
            PRINT("    \"%s\" -> \"%s\" ["
                  "label=\"%u x\","
                  "arrowsize=1"
                  "]\n",
                  dotNodeName.c_str(),
                  dotNodeName.c_str(),
                  count);
        }
    }

    for (CallInfo::iterator itr = mCalled.begin();
         itr != mCalled.end();
         ++itr) {
        Symbol *sym = itr->first;
        unsigned count = itr->second;
        std::string symDotName =sym->getDotNodeName();
        /* Ouput edge if first time visit */
        if (outputSymbol.count(symDotName) == 0) {
            double timePercent = toPercent(this->getCumulativeTime(),
                                           sym->getCumulativeTime());
            PRINT("    \"%s\" -> \"%s\" ["
                  "label=\"%.2f %%\\n%u x\","
                  "arrowsize=%.2f,"
                  "penwidth=%.2f,"
                  "]\n",
                  dotNodeName.c_str(),
                  symDotName.c_str(),
                  timePercent,
                  count,
                  std::max(timePercent*0.02, 0.5),
                  std::max(timePercent*0.04, 0.5));
        }
    }
}

void Symbol::dumpHistogram(uintmax_t totalTime, const Options &options) {
    /*
     * Only dump symbol ever called.
     */
    if (mCumulativeTime != 0 ||
        mSelfTime != 0 ||
        !mCalled.empty()){
        uintmax_t called = 0;
        for (CallInfo::iterator itr = mCallBy.begin();
             itr != mCallBy.end();
             ++itr) {
            called += itr->second;
        }
        double percent = toPercent(mSelfTime, totalTime);
        uintmax_t selfTimePerCall = 0;
        uintmax_t cumuTimePerCall = 0;
        if (called) {
            selfTimePerCall = mSelfTime/called;
            cumuTimePerCall = mCumulativeTime/called;
        }
        PRINT("%6.2f %10ju %10ju ",
              percent,
              options.toMS(mCumulativeTime),
              options.toMS(mSelfTime));
        PRINT("%10ju %10ju %10ju   %s\n",
              called, selfTimePerCall,
              cumuTimePerCall, getName().c_str());
    }
}

void Symbol::updateCumulativeTime(uintmax_t cumulativeTime) {
    INFO("   Update cumulative time for %s..."
         " ori : %ju update : %ju\n",
         getName().c_str(), mCumulativeTime, mCumulativeTime + cumulativeTime);
    this->mCumulativeTime += cumulativeTime;
    for (CallInfo::iterator itr = mCallBy.begin();
         itr != mCallBy.end();
         ++itr) {
        Symbol *sym = itr->first;
        if (sym->tag != tag) {
            INFO("    Symbol = %s updating\n", sym->mName.c_str());
            sym->tag = tag; /* make sure only traversal once */
            sym->updateCumulativeTime(cumulativeTime);
        }
    }
}

void Symbol::updateCumulativeTime() {
    tag = this;
    if (mSelfTime == 0) return;
    this->mCumulativeTime += mSelfTime;
    INFO("Update cumulative time from %s...\n", getName().c_str());
    for (CallInfo::iterator itr = mCallBy.begin();
         itr != mCallBy.end();
         ++itr) {
        Symbol *sym = itr->first;
        if (sym->tag != tag) {
            INFO("    Symbol = %s updating\n", sym->mName.c_str());
            sym->tag = tag; /* make sure only traversal once */
            sym->updateCumulativeTime(mSelfTime);
        }
    }
}

void Symbol::addCalledSymbol(Symbol *sym, unsigned count) {
    mCalled[sym] += count;
}

void Symbol::addCallBySymbol(Symbol *sym, unsigned count) {
    mCallBy[sym] += count;
}

void Symbol::dumpCallByInfo(const Options &options) const {
    if (mCumulativeTime == 0 &&
        mSelfTime == 0 &&
        mCallBy.empty()) return;
    PRINT(" %-18s %10ju  %10ju\n", getName().c_str(),
                                  options.toMS(getCumulativeTime()),
                                  options.toMS(getSelfTime()));
    for (CallInfo::const_iterator itr = mCallBy.begin();
         itr != mCallBy.end();
         ++itr) {
        const Symbol *sym = itr->first;
        unsigned count = itr->second;
        double timePercent = toPercent(sym->getCumulativeTime(),
                                       this->getCumulativeTime());
        PRINT("            %2.2f", timePercent);
        PRINT("  %10ju", options.toMS(sym->getCumulativeTime()));
        PRINT("  %10ju", options.toMS(sym->getSelfTime()));
        PRINT("  %10u  %s\n", count, sym->getName().c_str());
    }
}
