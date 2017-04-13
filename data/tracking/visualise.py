from os import listdir
import os
import glob
import cv2
import numpy as np

data_path = '../../../kittiTracking/'
which_set = 'training'

data_path = os.path.join(data_path, which_set)
results_path = '../../../kittiTracking/tracking/training/'
def visualise(seq_name, frame_no):
	sequences = listdir(os.path.join(data_path, 'image_02'))
	images = sorted(glob.glob(os.path.join(os.path.join(data_path, 'image_02'), seq_name) + '/*.png'))
	image_list = {}
	for image in images:
		frame_info = image.split('/')
		frame = frame_info[len(frame_info) - 1].split('.')[0]
		image_list[frame] = image
	gt_labels = open(glob.glob(os.path.join(os.path.join(data_path, 'label_02'), seq_name) + '.txt')[0], 'r').read().splitlines()
	detections = open(os.path.join(os.path.join(results_path, seq_name), 'inferResult.txt'), 'r').read().splitlines()
	dets_in_frame = []
	gt_in_frame = []
	for det in detections:
		det_details = det.split(' ')
		frame = det_details[0]
		if int(frame) == frame_no:
			dets_in_frame.append(det)
	img = cv2.imread(image_list[frame])
	img = draw_box(img, dets_in_frame)
	for gt in gt_labels:
		gt_details = gt.split(' ')
		frame = gt_details[0]
		if int(frame) == frame_no:
			gt_in_frame.append(gt)
	#img = draw_box(img, gt_in_frame, color=(255,0,0))
	out_file_name = frame
	cv2.imwrite(out_file_name + '.png', img)
	print('Image detection output saved to {}'.format(out_file_name))

	
def bbox_transform(bbox):
	"""convert a bbox of form [cx, cy, w, h] to [xmin, ymin, xmax, ymax]. Works
	for numpy array or list of tensors.
"""
	cx, cy, w, h = bbox
	out_box = [[]]*4
	out_box[0] = float(cx)-float(w)/2
	out_box[1] = float(cy)-float(h)/2
	out_box[2] = float(cx)+float(w)/2
	out_box[3] = float(cy)+float(h)/2
	return out_box


def draw_box(im, box_list, label_list=None, color=(0,255,0), cdict=None):
	# draw box
	for box in box_list:
		label = box.split(' ')[3]
		if color == (0,255,0):
			box = bbox_transform(box.split(' ')[4:8])
		cv2.rectangle(im, (int(box[0]), int(box[1])), (int(box[2]), int(box[3])), color, 2)
		# draw label
		font = cv2.FONT_HERSHEY_SIMPLEX
		cv2.putText(im, label, (int(box[0]), int(box[3])), font, 0.3, color, 1)
	return im



visualise('0000', 153)