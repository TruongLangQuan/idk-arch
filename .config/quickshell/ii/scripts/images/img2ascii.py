import sys
from PIL import Image, ImageEnhance

def image_to_ascii(image_path, output_path, new_width=180, contrast=1.3, brightness=1.0, threshold=6):
    try:
        image = Image.open(image_path)
    except Exception as e:
        print(f"Error opening image: {e}")
        return False

    # Adjust contrast and brightness to make details stand out
    if contrast != 1.0:
        enhancer = ImageEnhance.Contrast(image)
        image = enhancer.enhance(contrast)
    if brightness != 1.0:
        enhancer = ImageEnhance.Brightness(image)
        image = enhancer.enhance(brightness)

    # Convert to grayscale
    image = image.convert("L")

    # Calculate height based on aspect ratio and character width/height ratio (~0.5)
    width, height = image.size
    aspect_ratio = height / float(width)
    new_height = int(new_width * aspect_ratio * 0.5)
    image = image.resize((new_width, new_height), Image.Resampling.LANCZOS)

    # Progressive character ramp. Thresholding handles the background spaces
    ascii_chars = ".,-~:;iI+oxX#$@"
    num_chars = len(ascii_chars)

    pixels = image.getdata()
    ascii_str = []
    
    for i, pixel in enumerate(pixels):
        if pixel <= threshold:
            ascii_str.append(" ")
        else:
            # Map [threshold + 1, 255] to ascii_chars index
            char_idx = int(((pixel - threshold) / (255.0 - threshold)) * (num_chars - 1))
            char_idx = max(0, min(num_chars - 1, char_idx))
            ascii_str.append(ascii_chars[char_idx])
            
        if (i + 1) % new_width == 0:
            ascii_str.append("\n")

    output_str = "".join(ascii_str)
    
    with open(output_path, "w") as f:
        f.write(output_str)
        
    print(f"Successfully converted {image_path} to ASCII and saved to {output_path}")
    print(f"Dimensions: {new_width}x{new_height}")
    return True

if __name__ == "__main__":
    img_path = "/home/truonglangquan/Downloads/black-holes-space-dark-background-digital-art-accretion-disk-hd-wallpaper-preview.jpg"
    out_path = "/home/truonglangquan/.config/quickshell/ii/assets/blackhole_ascii.txt"
    
    width = 200
    if len(sys.argv) > 1:
        width = int(sys.argv[1])
        
    image_to_ascii(img_path, out_path, new_width=width)
