from cspaceSliders import FilterWindow
import cv2


image = cv2.imread('redBox.png')
window = FilterWindow('Filter Window', image)
window.show(verbose=True)

colorspace = window.colorspace
lowerb, upperb = window.bounds
mask = window.mask
applied_mask = window.applied_mask

print('Displaying the image with applied mask filtered in', colorspace,
      '\nwith lower bound', lowerb, 'and upper bound', upperb)
cv2.imshow('Applied Mask', applied_mask)
cv2.resizeWindow('Applied Mask', 600,600)
cv2.waitKey()
