import os
import sys
from PIL import Image

argv = sys.argv

TARGET_WIDTH = 64
TARGET_HEIGHT = 64
DATA_RADIX = 'HEX'
COLOR_DEPTH = 9
IMG_DIR = os.path.join(os.curdir, 'pics')
MIF_DIR = os.path.join(os.curdir, 'Card-Flip', 'MIF')

def convert(image):
    output_mif = image[:len(image) - 3] + 'mif'

    img = Image.open(os.path.join(IMG_DIR, image)).convert('RGB')
    img = img.resize((TARGET_WIDTH, TARGET_HEIGHT), Image.Resampling.LANCZOS)
    pixels: list[tuple[int, int, int]] = list(img.getdata()) # type: ignore
    depth = TARGET_WIDTH * TARGET_HEIGHT

    with open(os.path.join(MIF_DIR, output_mif), 'w') as f:
        f.write(f"WIDTH={COLOR_DEPTH};\n")
        f.write(f"DEPTH={depth};\n\n")
        f.write("ADDRESS_RADIX=HEX;\n")
        f.write(f"DATA_RADIX={DATA_RADIX};\n\n")
        f.write("CONTENT BEGIN\n")

        for address, (r, g, b) in enumerate(pixels):
            value = ((r >> 5) << 6) | ((g >> 5) << 3) | (b >> 5)
            if DATA_RADIX == 'HEX':
                fmt = f"{value:X}".zfill((COLOR_DEPTH + 3) // 4)
            else:
                fmt = f"{value:0{COLOR_DEPTH}b}"
            f.write(f"{address:X}: {fmt};\n")
        f.write("END;\n")
        print(f'{image} converted')

if __name__ == "__main__":

    if argv[1] == 'all':
        images = os.listdir(IMG_DIR)
        for image in images:
            convert(image)

    else:
        for arg in argv:
            if not arg.endswith('.py'):
                convert(arg)
