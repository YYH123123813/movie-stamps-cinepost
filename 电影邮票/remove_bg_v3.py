
from PIL import Image

def remove_background(input_path):
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
    for x in range(0, width, 10): seeds.append((x, 0))
    for x in range(0, width, 10): seeds.append((x, height-1))
    for y in range(0, height, 10): seeds.append((0, y))
    for y in range(0, height, 10): seeds.append((width-1, y))
    
    stack = list(set(seeds))
    visited = set()

    while stack:
        x, y = stack.pop()
        if (x, y) in visited: continue
        if x < 0 or x >= width or y < 0 or y >= height: continue
        visited.add((x, y))
        r, g, b, a = pixels[x, y]
        if a == 0: continue
        if r > 230 and g > 230 and b > 230: # Threshold for white background
            pixels[x, y] = (r, g, b, 0)
            stack.extend([(x+1,y), (x-1,y), (x,y+1), (x,y-1)])
            
    img.save(input_path, "PNG")
    print("Done.")

if __name__ == "__main__":
    files = [
        "/Users/applemima1111/Desktop/创作｜/电影邮票/电影邮票/Assets.xcassets/MonthlyEnvelope.imageset/envelope_closed.png"
    ]
    for f in files:
        remove_background(f)
