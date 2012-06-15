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

#ifndef _SYMBOL_TABLE_H
#define _SYMBOL_TABLE_H

#include <Symbol.h>

class SymbolTable {
public:
    SymbolTable(Image *img, const std::string &defaultSymbol, uint32_t base);
    Symbol *insert(const std::string &name, uint32_t addr, uint32_t size);
    Symbol *insertPltSymbol(uint32_t addr, uint32_t size);
    Symbol *find(uint32_t addr);

    bool read(FILE *fp);
    void dump();
    void dumpHistogram(uintmax_t totlaTime, const Options &options);
    void dumpCallEdge(const Options &options);
    void dumpDotFormat(std::set<std::string> &outputSymbol,
                       uintmax_t totalTime);

    uintmax_t getCumulativeTime();
    uintmax_t getSelfTime();

    void updateCumulativeTime();
    Symbol *getDefaultSymbol();
    Symbol *getPltSymbol();
private:
    Image *mImg;
    uint32_t mBase;
    void sortSymbol();
    bool mSortedFlag;
    bool mCumulativeTimeUpdatedFlag;
    std::vector<Symbol*> mSymbols;
    Symbol *mDefaultSymbol;
    Symbol *mPltSymbol;
};


#endif /* _SYMBOL_TABLE_H */
