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

#include <SymbolTable.h>
#include <Image.h>

#include <debug.h>
#include <elf.h>

#include <algorithm>

SymbolTable::SymbolTable(Image *img, const std::string &defaultSymbol,
                         uint32_t base) :
              mImg(img),
              mBase(base),
              mSortedFlag(false),
              mCumulativeTimeUpdatedFlag(false),
              mSymbols(),
              mDefaultSymbol(new Symbol(img, defaultSymbol, base, 0)),
              mPltSymbol(NULL) {
}

Symbol *SymbolTable::insert(const std::string &name,
                         uint32_t addr,
                         uint32_t size) {
    mSortedFlag = false;
    mCumulativeTimeUpdatedFlag = false;
    Symbol *sym = new Symbol(mImg, name, addr, size);
    mSymbols.push_back(sym);
    return sym;
}

Symbol *SymbolTable::insertPltSymbol(uint32_t addr, uint32_t size) {
    FAILIF(mPltSymbol != NULL, "PLT Symbol already set in %s!", mImg->getName().c_str());
    std::string pltSymbolName = mImg->getName() + "@plt";
    mPltSymbol = new Symbol(mImg, pltSymbolName, addr, size);
    return mPltSymbol;
}

static bool symbolCmp(const Symbol *lhs, const Symbol *rhs) {
    return lhs->getAddr() < rhs->getAddr();
}

/*
 * Make symbols are ordered in the table for fast query.
 */
void SymbolTable::sortSymbol() {
    if (!mSortedFlag) {
        std::sort(mSymbols.begin(), mSymbols.end(), symbolCmp);
        mSortedFlag = true;
    }
}

void SymbolTable::dumpCallEdge(const Options &options) {
    sortSymbol();
    uintmax_t cumulativeTime = getCumulativeTime();
    uintmax_t selfTime = getSelfTime();
    if (cumulativeTime == 0 &&
        selfTime == 0) {
        return;
    }
    PRINT("-------------------------------------------------------------\n");
    PRINT("Image           : %s\n", mImg->getName().c_str());
    PRINT("Cumulative time : %jd ms\n", options.toMS(cumulativeTime));
    PRINT("Self time       : %jd ms\n", options.toMS(selfTime));
    PRINT("  Function  %% time");
    PRINT("  cumulative        self");
    PRINT("       Count  Call by\n");
    for (std::vector<Symbol*>::iterator itr = mSymbols.begin();
         itr != mSymbols.end();
         ++itr) {
        Symbol *sym = *itr;
        sym->dumpCallByInfo(options);
    }
}

Symbol *SymbolTable::getDefaultSymbol() {
    return mDefaultSymbol;
}
Symbol *SymbolTable::getPltSymbol() {
    return mPltSymbol;
}

void SymbolTable::dumpDotFormat(std::set<std::string> &outputSymbol,
                                uintmax_t totalTime) {
    this->getDefaultSymbol()->dumpDotFormat(outputSymbol, totalTime);
    for (std::vector<Symbol*>::iterator itr = mSymbols.begin();
         itr != mSymbols.end();
         ++itr) {
        Symbol *sym = *itr;
        sym->dumpDotFormat(outputSymbol, totalTime);
    }
}

Symbol *SymbolTable::find(uint32_t addr) {
    if (mSymbols.empty()) return mDefaultSymbol;
    sortSymbol();
    for (std::vector<Symbol*>::reverse_iterator itr = mSymbols.rbegin();
         itr != mSymbols.rend();
         ++itr) {
        if (addr >= (*itr)->getAddr()) {
            return (*itr);
        }
    }
    if (mPltSymbol &&
        addr >= mPltSymbol->getAddr() &&
        addr <  mPltSymbol->getAddr() + mPltSymbol->getSize() ) {
        return mPltSymbol;
    }
    return mDefaultSymbol;
}

void SymbolTable::dump() {
    sortSymbol();
    for (std::vector<Symbol*>::iterator itr = mSymbols.begin();
         itr != mSymbols.end();
         ++itr) {
        Symbol *sym = *itr;
        PRINT("%16x %16x %s\n", sym->getAddr(),
                                sym->getSize(),
                                sym->getName().c_str());
    }
}

void SymbolTable::dumpHistogram(uintmax_t totalTime, const Options &options) {
    sortSymbol();
    mDefaultSymbol->dumpHistogram(totalTime, options);
    if (mPltSymbol) mPltSymbol->dumpHistogram(totalTime, options);
    for (std::vector<Symbol*>::iterator itr = mSymbols.begin();
         itr != mSymbols.end();
         ++itr) {
        (*itr)->dumpHistogram(totalTime, options);
    }
}

uintmax_t SymbolTable::getCumulativeTime() {
    uintmax_t cumulativeTime = mDefaultSymbol->getCumulativeTime();
    for (std::vector<Symbol*>::iterator itr = mSymbols.begin();
         itr != mSymbols.end();
         ++itr) {
        cumulativeTime += (*itr)->getCumulativeTime();
    }
    return cumulativeTime;
}

uintmax_t SymbolTable::getSelfTime() {
    uintmax_t selfTime = mDefaultSymbol->getSelfTime();
    for (std::vector<Symbol*>::iterator itr = mSymbols.begin();
         itr != mSymbols.end();
         ++itr) {
        selfTime += (*itr)->getSelfTime();
    }
    return selfTime;
}

void SymbolTable::updateCumulativeTime(){
    if (mCumulativeTimeUpdatedFlag) return;
    mCumulativeTimeUpdatedFlag = true;
    mDefaultSymbol->updateCumulativeTime();
    for (std::vector<Symbol*>::iterator itr = mSymbols.begin();
         itr != mSymbols.end();
         ++itr) {
        (*itr)->updateCumulativeTime();
    }
}

static bool verifyElf(Elf32_Ehdr *ehdr) {
  if (ehdr->e_ident[EI_MAG0] != ELFMAG0) return false;
  if (ehdr->e_ident[EI_MAG1] != ELFMAG1) return false;
  if (ehdr->e_ident[EI_MAG2] != ELFMAG2) return false;
  if (ehdr->e_ident[EI_MAG3] != ELFMAG3) return false;
  return true;
}


bool SymbolTable::read(FILE *fp) {
    if (fp == NULL) {
        return false;
    }

    fseek(fp, 0l, SEEK_END);
    long int filesize = ftell(fp);
    fseek(fp, 0l, SEEK_SET);

    /* Use vector<char> for automatic release memory */
    std::vector<char> auto_data(filesize);
    char *data = &auto_data[0];
    size_t result = fread(data, 1, filesize, fp);
    if (result != (size_t)filesize) {
      return false;
    }


    Elf32_Ehdr *ehdr = (Elf32_Ehdr *)data;
    if (!verifyElf(ehdr)) return false;
    Elf32_Shdr *shdrs = (Elf32_Shdr*)(data + ehdr->e_shoff);
    if (ehdr->e_shstrndx == SHN_XINDEX) return false;
    Elf32_Shdr *shstrtab = &shdrs[ehdr->e_shstrndx];
    Elf32_Shdr *strtab = NULL;
    Elf32_Shdr *symtab = NULL;
    Elf32_Shdr *dynsym = NULL;
    Elf32_Shdr *dynstr = NULL;

    int shnum = ehdr->e_shnum;
    for (int i=0;i<shnum;++i) {
        Elf32_Shdr *shdr = &shdrs[i];
        std::string sectionName = (const char*)(data +
                                                shstrtab->sh_offset +
                                                shdr->sh_name);
        if (sectionName == ".symtab") {symtab = shdr;}
        if (sectionName == ".strtab") {strtab = shdr;}
        if (sectionName == ".dynsym") {dynsym = shdr;}
        if (sectionName == ".dynstr") {dynstr = shdr;}
        if (sectionName == ".plt") {
            this->insertPltSymbol(shdr->sh_addr+mBase,
                                  shdr->sh_size);
        }
    }

    bool hasDynInfo = dynsym != NULL && dynstr != NULL;
    /* Use .dynsym/.dynstr section as symbol/string table if
     * .symtab/.strtab not found. */
    if ((symtab == NULL || strtab == NULL)) {
        if (hasDynInfo) {
            symtab = dynsym;
            strtab = dynstr;
        } else {
            ERROR("Not found symbol table or string table!\n");
            return false;
        }
    }

    Elf32_Sym *syms = (Elf32_Sym*)(data + symtab->sh_offset);
    Elf32_Word numSym = (symtab->sh_size / symtab->sh_entsize);

    for (Elf32_Word i=0;i<numSym;++i){
        Elf32_Sym *sym= &syms[i];
        const char *symName = (const char *)(data +
                                             strtab->sh_offset +
                                             sym->st_name);
        /* We only care about function here. */
        if (ELF32_ST_TYPE(sym->st_info) != STT_FUNC) {
            continue;
        }
        /* Insert to symbol talbe if not undefine symbol */
        if (sym->st_shndx != SHN_UNDEF &&
            sym->st_shndx < shnum) {
             Symbol *symbol = this->insert(symName,
                                           sym->st_value+mBase,
                                           sym->st_size);
             INFO("Symbol %s, address : %x size : %x\n", symName,
                  symbol->getAddr(),
                  symbol->getSize());
        }
    }



    return true;
}
