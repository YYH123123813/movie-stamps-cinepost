
from PIL import Image, ImageChops

def remove_background(input_path):
    print(f"Processing {input_path}...")
    try:
        img = Image.open(input_path).convert("RGBA")
    except Exception as e:
        print(f"Error opening image: {e}")
        return

    width, height = img.size
    pixels = img.load()
    
    # Increase recursion limit just in case
    import sys
    sys.setrecursionlimit(20000)

    # Use a set of seeds from borders.
    # Top edge, Bottom edge, Left edge, Right edge.
    # For Envelope Pocket, top is white, bottom is paper? No, isolated on white.
    # For Stamp Frame, outside is white.
    
    seeds = []
    # Add top row
    for x in range(0, width, 10): seeds.append((x, 0))
    # Add bottom row
    for x in range(0, width, 10): seeds.append((x, height-1))
    # Add left col
    for y in range(0, height, 10): seeds.append((0, y))
    # Add right col
    for y in range(0, height, 10): seeds.append((width-1, y))
    
    stack = list(set(seeds)) # Unique
    visited = set()

    while stack:
        x, y = stack.pop()
        
        if (x, y) in visited:
            continue
            
        if x < 0 or x >= width or y < 0 or y >= height:
            continue
        
        visited.add((x, y))
        
        r, g, b, a = pixels[x, y]
        
        # If already transparent
        if a == 0:
            continue

        # Check if "White-ish" background
        is_background = False
        if r > 220 and g > 220 and b > 220: # Slightly stricter threshold
             if (abs(r-g) + abs(g-b) + abs(b-r)) < 30:
                is_background = True
        
        if is_background:
            pixels[x, y] = (r, g, b, 0) # Make transparent
            
            # Add neighbors efficiently
            steps = [(1,0), (-1,0), (0,1), (0,-1)]
            for dx, dy in steps:
                nx, ny = x+dx, y+dy
                if (nx, ny) not in visited:
                     stack.append((nx, ny))

    img.save(input_path, "PNG")
    print("Done.")

if __name__ == "__main__":
    files = [
        "/Users/applemima1111/Desktop/创作｜/电影邮票/电影邮票/Assets.xcassets/WaxSealButton.imageset/wax_seal.png",
        "/Users/applemima1111/Desktop/创作｜/电影邮票/电影邮票/Assets.xcassets/StampFrame.imageset/stamp_frame.png",
        "/Users/applemima1111/Desktop/创作｜/电影邮票/电影邮票/Assets.xcassets/EnvelopePocket.imageset/envelope_pocket.png"
    ]
    for f in files:
        remove_background(f)
