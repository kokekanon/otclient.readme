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

#include "uiverticallayout.h"
#include <framework/core/eventdispatcher.h>

#include "uiwidget.h"
#include <ranges>

void UIVerticalLayout::applyStyle(const OTMLNodePtr& styleNode)
{
    UIBoxLayout::applyStyle(styleNode);

    for (const auto& node : styleNode->children()) {
        if (node->tag() == "align-bottom")
            setAlignBottom(node->value<bool>());
    }
}

bool UIVerticalLayout::internalUpdate()
{
    bool changed = false;

    const auto& parentWidget = getParentWidget();
    if (!parentWidget)
        return false;

    const auto& paddingRect = parentWidget->getPaddingRect();
    Point pos = (m_alignBottom) ? paddingRect.bottomLeft() : paddingRect.topLeft();
    int preferredHeight = 0;

    const auto& action = [&](const UIWidgetPtr& widget) {
        if (!widget->isExplicitlyVisible())
            return;

        Size size = widget->getSize();

        int gap = (m_alignBottom) ? -(widget->getMarginBottom() + widget->getHeight()) : widget->getMarginTop();
        pos.y += gap;
        preferredHeight += gap;

        if (widget->isFixedSize()) {
            // center it
            if (widget->getTextAlign() & Fw::AlignLeft) {
                pos.x = paddingRect.left() + widget->getMarginLeft();
            } else if (widget->getTextAlign() & Fw::AlignLeft) {
                pos.x = paddingRect.bottom() - widget->getHeight() - widget->getMarginBottom();
                pos.x = std::max<int>(pos.x, paddingRect.left());
            } else {
                pos.x = paddingRect.left() + (paddingRect.width() - (widget->getMarginLeft() + widget->getWidth() + widget->getMarginRight())) / 2;
                pos.x = std::max<int>(pos.x, paddingRect.left());
            }
        } else {
            // expand width
            size.setWidth(paddingRect.width() - (widget->getMarginLeft() + widget->getMarginRight()));
            pos.x = paddingRect.left() + (paddingRect.width() - size.width()) / 2;
        }

        if (widget->setRect(Rect(pos - parentWidget->getVirtualOffset(), size)))
            changed = true;

        gap = (m_alignBottom) ? -widget->getMarginTop() : (widget->getHeight() + widget->getMarginBottom());
        gap += m_alignBottom ? -m_spacing : m_spacing;
        pos.y += gap;
        preferredHeight += gap;
    };

    if (m_alignBottom) {
        for (auto& it : std::ranges::reverse_view(parentWidget->m_children))
            action(it);
    } else for (const auto& widget : parentWidget->m_children)
        action(widget);

    preferredHeight -= m_spacing;
    preferredHeight += parentWidget->getPaddingTop() + parentWidget->getPaddingBottom();

    if (m_fitChildren && preferredHeight != parentWidget->getHeight()) {
        // must set the preferred width later
        g_dispatcher.deferEvent([=] {
            parentWidget->setHeight(preferredHeight);
        });
    }

    return changed;
}