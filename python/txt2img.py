
import cv2
import numpy as np


l = []
with open("resultpixels.txt", 'rt') as f:
    for line in f.readlines():
        l.append(int(abs(int(line))))
f.close()

print(len(l))
img_array = np.array(l, dtype=np.uint8)

img_array = np.reshape(img_array, (875, 620))

cv2.imshow('ny', img_array)

cv2.waitKey()
cv2.destroyAllWindows()

cv2.imwrite("results.jpg", img_array)


