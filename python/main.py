
import cv2
import numpy as np


img = cv2.imread("image.jpg")
img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
# img = cv2.resize(img, (1024, 1024))

newx = cv2.filter2D(img, -1, np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]))
newy = cv2.filter2D(img, -1, np.array([[1, 2, 1], [0, 0, 0], [-1, -2, -1]]))

cv2.imshow('d', img)
cv2.imshow('nx', newx)
cv2.imshow('ny', newy)

cv2.waitKey()
cv2.destroyAllWindows()

print(img.shape)
print(newx.shape)
pxs = np.reshape(img, (-1))
print(pxs.shape)

with open("pixels.txt", 'wt') as f:
    for px in pxs:
        f.writelines(str(px)+'\n')
f.close()


