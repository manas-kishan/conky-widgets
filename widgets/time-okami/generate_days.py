#!/usr/bin/env python3
import os
from PIL import Image, ImageDraw, ImageFont

days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
script_dir = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.abspath(os.path.join(script_dir, "../.."))
font_path = os.path.join(repo_root, "fonts", "Okami.otf")
output_dir = os.path.join(script_dir, "assets", "days")
os.makedirs(output_dir, exist_ok=True)

# Generate for both +45 and -45
font_size = 32
font = ImageFont.truetype(font_path, font_size)

for day in days:
    text = day.upper()
    # Measure text
    dummy_img = Image.new("RGBA", (1, 1), (0, 0, 0, 0))
    d = ImageDraw.Draw(dummy_img)
    bbox = d.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0] + 20
    th = bbox[3] - bbox[1] + 20
    
    # Create canvas
    img = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Vermilion crimson E63946
    d.text((10 - bbox[0], 10 - bbox[1]), text, font=font, fill=(230, 57, 70, 255))
    
    # +45 (slanted up-right)
    rot_up = img.rotate(45, expand=True, resample=Image.BICUBIC)
    # Trim transparent borders
    rot_up_bbox = rot_up.getbbox()
    if rot_up_bbox:
        rot_up = rot_up.crop(rot_up_bbox)
    rot_up.save(os.path.join(output_dir, f"{day}.png"))
    
    # -45 (slanted down-right)
    rot_down = img.rotate(-45, expand=True, resample=Image.BICUBIC)
    rot_down_bbox = rot_down.getbbox()
    if rot_down_bbox:
        rot_down = rot_down.crop(rot_down_bbox)
    rot_down.save(os.path.join(output_dir, f"{day}_down.png"))

print("All day images generated successfully in", output_dir)
