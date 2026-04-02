
from PIL import Image
import os

def remove_background(input_path):
    if not os.path.exists(input_path):
        print(f"Skipping {input_path} (not found)")
        return
        
    print(f"Processing {input_path}...")
    try:
        img = Image.open(input_path).convert("RGBA")
    except Exception as e:
        print(f"Error opening image: {e}")
        return

    width, height = img.size
    pixels = img.load()
    
    import sys
    sys.setrecursionlimit(20000)
    
    seeds = []
    # Check edges for background
    for x in range(0, width): 
        seeds.append((x, 0))
        seeds.append((x, height-1))
    for y in range(0, height): 
        seeds.append((0, y))
        seeds.append((width-1, y))
    
    stack = list(set(seeds))
    visited = set()

    while stack:
        x, y = stack.pop()
        if (x, y) in visited: continue
        if x < 0 or x >= width or y < 0 or y >= height: continue
        visited.add((x, y))
        r, g, b, a = pixels[x, y]
        if a == 0: continue
        # Target white or very light colors on the edges
        if r > 240 and g > 240 and b > 240: 
            pixels[x, y] = (r, g, b, 0)
            stack.extend([(x+1,y), (x-1,y), (x,y+1), (x,y-1)])
            
    img.save(input_path, "PNG")
    print("Done.")

if __name__ == "__main__":
    base = "/Users/applemima1111/Desktop/创作｜/电影邮票/电影邮票/Assets.xcassets"
    files = [
        f"{base}/envelope_closed.imageset/envelope_closed.png",
        f"{base}/envelope_pocket.imageset/envelope_pocket.png",
        f"{base}/stamp_frame.imageset/stamp_frame.png",
        f"{base}/wax_seal.imageset/wax_seal.png",
        f"{base}/wax_seal_upload_button_v2.imageset/wax_seal_v2.png"
    ]
    for f in files:
        remove_background(f)
