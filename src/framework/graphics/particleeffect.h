/*
 * Copyright (c) 2010-2025 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#pragma once

#include "declarations.h"
#include <framework/luaengine/luaobject.h>
#include <framework/otml/otml.h>

class ParticleEffectType final : public LuaObject
{
public:
    void load(const OTMLNodePtr& node);

    std::string getName() { return m_name; }
    std::string getDescription() { return m_description; }
    OTMLNodePtr getNode() { return m_node; }

private:
    std::string m_name;
    std::string m_description;
    OTMLNodePtr m_node;
};

class ParticleEffect
{
public:
    ParticleEffect() = default;

    void load(const ParticleEffectTypePtr& effectType);
    bool hasFinished() const { return m_systems.empty(); }
    void render() const;
    void update();

    const ParticleEffectTypePtr& getEffectType() { return m_effectType; }

private:
    std::vector<ParticleSystemPtr> m_systems;
    ParticleEffectTypePtr m_effectType;
};
