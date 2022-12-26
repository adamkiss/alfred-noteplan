#!/usr/bin/env fish
# Remove previous versions
cd workflow/icons
rm ./*.icns

# Rename PNGs from Photoshop to iconsets
for icon in note calendar create folder
    mkdir icon-$icon.iconset
    
    mv icon-$icon-16.png icon-$icon.iconset/icon_16x16.png
    
    cp icon-$icon-32.png icon-$icon.iconset/icon_16x16@2x.png
    mv icon-$icon-32.png icon-$icon.iconset/icon_32x32.png

    mv icon-$icon-64.png icon-$icon.iconset/icon_32x32@2x.png
    mv icon-$icon-128.png icon-$icon.iconset/icon_128x128.png
    
    cp icon-$icon-256.png icon-$icon.iconset/icon_128x128@2x.png
    mv icon-$icon-256.png icon-$icon.iconset/icon_256x256.png

    convert icon-$icon-1024.png -resize 50% icon-$icon.iconset/icon_256x256@2x.png
    convert icon-$icon-1024.png -resize 50% icon-$icon.iconset/icon_512x512.png
    mv icon-$icon-1024.png icon-$icon.iconset/icon_512x512@2x.png
end

# # Package
for f in *.iconset
    iconutil --convert icns $f    
end

# Clean up
rm -rf ./*.iconset