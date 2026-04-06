#!/usr/bin/env python3
"""Generate Pomodoro app icon (1024x1024 PNG) using Pillow."""

from PIL import Image, ImageDraw, ImageFilter
import math

SIZE = 1024
CENTER = SIZE // 2
img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# --- Background: macOS-style rounded square ---
BG_MARGIN = 40
BG_RADIUS = 200
bg_rect = [BG_MARGIN, BG_MARGIN, SIZE - BG_MARGIN, SIZE - BG_MARGIN]
draw.rounded_rectangle(bg_rect, radius=BG_RADIUS, fill=(250, 250, 250, 255))

# --- Tomato body ---
TOMATO_CX, TOMATO_CY = CENTER, CENTER + 45
TOMATO_RX, TOMATO_RY = 320, 300

# Main tomato - layered gradient
for i in range(30):
    t = i / 29.0
    rx = TOMATO_RX - t * 80
    ry = TOMATO_RY - t * 70
    offset_x = -t * 40
    offset_y = -t * 35
    r = int(210 - t * 35)
    g = int(55 - t * 20)
    b = int(45 - t * 12)
    bbox = [
        TOMATO_CX - rx + offset_x,
        TOMATO_CY - ry + offset_y,
        TOMATO_CX + rx + offset_x,
        TOMATO_CY + ry + offset_y,
    ]
    draw.ellipse(bbox, fill=(r, g, b, 255))

# Soft highlight
highlight_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
hd = ImageDraw.Draw(highlight_layer)
hcx, hcy = TOMATO_CX - 90, TOMATO_CY - 80
for i in range(20):
    t = i / 19.0
    rx = 70 - t * 55
    ry = 50 - t * 40
    alpha = int(25 - t * 22)
    hd.ellipse([hcx - rx, hcy - ry, hcx + rx, hcy + ry], fill=(255, 220, 200, alpha))
highlight_layer = highlight_layer.filter(ImageFilter.GaussianBlur(radius=8))
img = Image.alpha_composite(img, highlight_layer)
draw = ImageDraw.Draw(img)

# --- Stem ---
stem_base_y = TOMATO_CY - TOMATO_RY + 25
stem_pts = [
    (CENTER - 4, stem_base_y),
    (CENTER - 2, stem_base_y - 40),
    (CENTER + 2, stem_base_y - 75),
    (CENTER + 4, stem_base_y - 95),
]
draw.line(stem_pts, fill=(70, 110, 45, 255), width=20, joint="curve")

# --- Leaves ---
def draw_leaf(cx, cy, angle_deg, length, width, color=(65, 135, 50, 255)):
    leaf_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ld = ImageDraw.Draw(leaf_layer)
    angle = math.radians(angle_deg)
    perp = angle + math.pi / 2
    tip_x = cx + math.cos(angle) * length
    tip_y = cy + math.sin(angle) * length
    ctrl1_x = cx + math.cos(angle) * length * 0.45 + math.cos(perp) * width
    ctrl1_y = cy + math.sin(angle) * length * 0.45 + math.sin(perp) * width
    ctrl2_x = cx + math.cos(angle) * length * 0.45 - math.cos(perp) * width
    ctrl2_y = cy + math.sin(angle) * length * 0.45 - math.sin(perp) * width

    points = [(cx, cy)]
    steps = 24
    for i in range(steps + 1):
        t = i / steps
        x = (1 - t) ** 2 * cx + 2 * (1 - t) * t * ctrl1_x + t**2 * tip_x
        y = (1 - t) ** 2 * cy + 2 * (1 - t) * t * ctrl1_y + t**2 * tip_y
        points.append((x, y))
    for i in range(steps + 1):
        t = i / steps
        x = (1 - t) ** 2 * tip_x + 2 * (1 - t) * t * ctrl2_x + t**2 * cx
        y = (1 - t) ** 2 * tip_y + 2 * (1 - t) * t * ctrl2_y + t**2 * cy
        points.append((x, y))
    ld.polygon(points, fill=color)
    return leaf_layer

leaf_y = stem_base_y + 5
img = Image.alpha_composite(img, draw_leaf(CENTER, leaf_y, -145, 140, 38))
img = Image.alpha_composite(img, draw_leaf(CENTER, leaf_y, -115, 115, 32))
img = Image.alpha_composite(img, draw_leaf(CENTER - 5, leaf_y, -35, 140, 38))
img = Image.alpha_composite(img, draw_leaf(CENTER - 5, leaf_y, -65, 115, 32))
draw = ImageDraw.Draw(img)

# --- Timer ring (subtle, bottom-right of tomato) ---
timer_cx, timer_cy = TOMATO_CX + 30, TOMATO_CY + 25
timer_r = 95
# Track
arc_bbox = [timer_cx - timer_r, timer_cy - timer_r, timer_cx + timer_r, timer_cy + timer_r]
draw.arc(arc_bbox, start=0, end=360, fill=(255, 255, 255, 45), width=7)
# Progress: 25/60 = ~150 degrees
draw.arc(arc_bbox, start=-90, end=-90 + 150, fill=(255, 255, 255, 140), width=7)
# Dot at start (12 o'clock)
dot_x, dot_y = timer_cx, timer_cy - timer_r
draw.ellipse([dot_x - 7, dot_y - 7, dot_x + 7, dot_y + 7], fill=(255, 255, 255, 160))

# --- Bottom shadow under tomato (subtle) ---
shadow_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
sd = ImageDraw.Draw(shadow_layer)
sd.ellipse([
    TOMATO_CX - TOMATO_RX * 0.7,
    TOMATO_CY + TOMATO_RY - 20,
    TOMATO_CX + TOMATO_RX * 0.7,
    TOMATO_CY + TOMATO_RY + 30,
], fill=(0, 0, 0, 15))
shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(radius=15))

final = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
# Re-draw background
fd = ImageDraw.Draw(final)
fd.rounded_rectangle(bg_rect, radius=BG_RADIUS, fill=(250, 250, 250, 255))
final = Image.alpha_composite(final, shadow_layer)
# Composite tomato on top
bg_mask = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
bmd = ImageDraw.Draw(bg_mask)
bmd.rounded_rectangle(bg_rect, radius=BG_RADIUS, fill=(255, 255, 255, 255))
# Paste img content (tomato+leaves+stem) onto final
final = Image.alpha_composite(final, img)

final.save("Pomodoro/Resources/AppIcon.png")
print("Generated Pomodoro/Resources/AppIcon.png (1024x1024)")
