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

#ifndef _OPTIONS_H
#define _OPTIONS_H

#include <string>
#include <vector>
#include <stdint.h>

typedef std::vector<std::string> LibPaths;
extern int verbose;

class Options {
public:
    Options(int argc, char **argv);

    std::string imgFile;
    std::string profFile;
    LibPaths libPaths;

    uint32_t version;
    uint32_t sampleRate;
    uint32_t pointerSize;

    uintmax_t toMS(uintmax_t time) const;

    enum OutputFormat{
        TEXT,
        DOT,
    };
    enum OutputFormat outputFormat;
private:
    void parseCmdLine(int argc, char **argv);
};

#endif
