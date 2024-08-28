
#include "uigraph.h"
#include <framework/graphics/fontmanager.h>
#include <framework/core/eventdispatcher.h>
#include <framework/graphics/drawpool.h>
#include <framework/graphics/drawpoolmanager.h>
#include <framework/graphics/coordsbuffer.h>
#include <framework/graphics/bitmapfont.h>
#include <framework/graphics/drawpoolmanager.h>
UIGraph::UIGraph()
{
}

void UIGraph::drawSelf(DrawPoolType drawPane)
{
    if (drawPane != DrawPoolType::FOREGROUND)
        return;

    UIWidget::drawSelf(drawPane);

    Rect dest = getPaddingRect();

    float offsetX = dest.left();
    float offsetY = dest.top();
    size_t elements = std::min<size_t>(m_values.size(), dest.width() / (m_width * 2) - 1);
    size_t start = m_values.size() - elements;
    int minVal = 0xFFFFFF, maxVal = -0xFFFFFF;
    for (size_t i = start; i < m_values.size(); ++i) {
        if (minVal > m_values[i])
            minVal = m_values[i];
        if (maxVal < m_values[i])
            maxVal = m_values[i];
    }
    // round
    maxVal = (1 + maxVal / 10) * 10;
    minVal = (minVal / 10) * 10;
    float step = (float)(dest.height()) / std::max<float>(1, (maxVal - minVal));
    std::vector<Point> points;
    for (size_t i = start, j = 0; i < m_values.size(); ++i) {
        points.push_back(Point(offsetX + j * m_width, offsetY + 1 + (maxVal - m_values[i]) * step));
        j += 2;
    }

    if (elements > 0) {
        // Dibujar la línea
        CoordsBufferPtr coordsBuffer = CoordsBufferPtr(new CoordsBuffer);
        for (size_t i = 0; i < points.size() - 1; ++i) {
            coordsBuffer->addLine(points[i], points[i + 1]);
        }
        g_drawPool.addTexturedCoordsBuffer(nullptr, coordsBuffer, m_color);

        // Dibujar el título
        if (!m_title.empty()) {
            g_drawPool.addText(m_font, m_title, dest, Fw::AlignTopCenter);
        }

        // Dibujar las etiquetas
        if (m_showLabes) {
            g_drawPool.addText(m_font, std::to_string(m_values.back()), dest, Fw::AlignTopRight);
            g_drawPool.addText(m_font, std::to_string(maxVal), dest, Fw::AlignTopLeft);
            g_drawPool.addText(m_font, std::to_string(minVal), dest, Fw::AlignBottomLeft);
        }
    }
}

void UIGraph::clear()
{
    m_values.clear();
}

void UIGraph::addValue(int value, bool ignoreSmallValues)
{
    if (ignoreSmallValues) {
        if (!m_values.empty() && m_values.back() <= 2 && value <= 2 && ++m_ignores <= 10)
            return;
        m_ignores = 0;
    }
    m_values.push_back(value);
    while (m_values.size() > m_capacity)
        m_values.pop_front();
}

void UIGraph::onStyleApply(const std::string& styleName, const OTMLNodePtr& styleNode)
{
    UIWidget::onStyleApply(styleName, styleNode);

    for (const OTMLNodePtr& node : styleNode->children()) {
        if (node->tag() == "line-width")
            setLineWidth(node->value<int>());
        else if (node->tag() == "capacity")
            setCapacity(node->value<int>());
        else if (node->tag() == "title")
            setTitle(node->value<std::string>());
        else if (node->tag() == "show-labels")
            setShowLabels(node->value<bool>());
    }
}
