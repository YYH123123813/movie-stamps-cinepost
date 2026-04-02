
from PIL import Image, ImageChops

def remove_background(input_path, output_path):
    print(f"Processing {input_path}...")
    try:
        img = Image.open(input_path).convert("RGBA")
    except Exception as e:
        print(f"Error opening image: {e}")
        return

    width, height = img.size
    pixels = img.load()
    
    # Simple stack-based flood fill from corners
    # We use a set for visited to avoid infinite loops, but since we modify pixels to transparent,
    # checking transparency is also a valid visited check.
    
    stack = [(0, 0), (width-1, 0), (0, height-1), (width-1, height-1)]
    visited = set()
    
    # Increase recursion limit just in case, though we use iterative stack
    import sys
    sys.setrecursionlimit(10000)

    while stack:
        x, y = stack.pop()
        
        if (x, y) in visited:
            continue
            
        if x < 0 or x >= width or y < 0 or y >= height:
            continue
        
        visited.add((x, y))
        
        r, g, b, a = pixels[x, y]
        
        # If already transparent, skip (but continue search? already visited)
        if a == 0:
            continue

        # Check if "White-ish" background
        # R, G, B should be high, and saturation low
        is_background = False
        if r > 200 and g > 200 and b > 200:
            if (abs(r-g) + abs(g-b) + abs(b-r)) < 40:
                is_background = True
        
        if is_background:
            pixels[x, y] = (r, g, b, 0) # Make transparent
            
            # Add neighbors
            stack.append((x+1, y))
            stack.append((x-1, y))
            stack.append((x, y+1))
            stack.append((x, y-1))

    img.save(output_path, "PNG")
    print("Done.")

if __name__ == "__main__":
    target = "/Users/applemima1111/Desktop/创作｜/电影邮票/电影邮票/Assets.xcassets/WaxSealButton.imageset/wax_seal.png"
    remove_background(target, target)
