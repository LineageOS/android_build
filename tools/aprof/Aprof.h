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

#ifndef _APROF_H
#define _APROF_H

#include <stdint.h>
#include <string>
#include <stdio.h>
#include <list>
#include <vector>
#include <map>
#include <Options.h>
#include <SymbolTable.h>
#include <ImageCollection.h>

class Options;

class Aprof {
public:
    Aprof(Options &options);
    ~Aprof();

    void dumpHistogram();
    void dumpCallEdge();
    void dumpDotFormat();

private:
    Options &mOptions;
    ImageCollection mImages;

    bool readHeader(FILE *fp);
    bool readProfileFile();
    bool readHistogram(FILE *fp, bool isExe);
    bool readCallGraph(FILE *fp);
    bool readSymbols();
    void updateHistogram();
};

#endif /* _APROF_H */
