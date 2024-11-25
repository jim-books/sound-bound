# tracking/drumstick_tracking.py

import cv2
import numpy as np
from config.settings import *


class DrumstickTracker:
    def __init__(self):
        self.camera1 = cv2.VideoCapture(WEBCAM_1_INDEX)
        self.camera2 = cv2.VideoCapture(WEBCAM_2_INDEX)

        # Previous frame for motion detection
        self.prev_frame1 = None
        self.prev_frame2 = None

        # Create window for parameters
        cv2.namedWindow('Parameters')
        # Trackbars for edge detection
        cv2.createTrackbar('Canny Low', 'Parameters', 50, 255, lambda x: None)
        cv2.createTrackbar('Canny High', 'Parameters', 150, 255, lambda x: None)
        # Trackbar for motion sensitivity
        cv2.createTrackbar('Motion Threshold', 'Parameters', 30, 255, lambda x: None)

    def get_parameters(self):
        canny_low = cv2.getTrackbarPos('Canny Low', 'Parameters')
        canny_high = cv2.getTrackbarPos('Canny High', 'Parameters')
        motion_threshold = cv2.getTrackbarPos('Motion Threshold', 'Parameters')
        return canny_low, canny_high, motion_threshold

    def detect_drumstick(self, frame, prev_frame):
        # Convert to grayscale
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        blurred = cv2.GaussianBlur(gray, (5, 5), 0)

        # Get current parameters
        canny_low, canny_high, motion_threshold = self.get_parameters()

        # Edge detection
        edges = cv2.Canny(blurred, canny_low, canny_high)

        # Motion detection
        if prev_frame is not None:
            # Calculate difference between current and previous frame
            frame_diff = cv2.absdiff(prev_frame, gray)
            _, motion_mask = cv2.threshold(frame_diff, motion_threshold, 255, cv2.THRESH_BINARY)

            # Combine edge and motion detection
            combined_mask = cv2.bitwise_and(edges, motion_mask)
        else:
            combined_mask = edges

        # Clean up the mask
        kernel = np.ones((5, 5), np.uint8)
        combined_mask = cv2.dilate(combined_mask, kernel, iterations=2)
        combined_mask = cv2.erode(combined_mask, kernel, iterations=1)

        # Find contours
        contours, _ = cv2.findContours(combined_mask, cv2.RETR_EXTERNAL,
                                       cv2.CHAIN_APPROX_SIMPLE)

        # Filter contours based on shape and size
        drumstick_tip = None
        for contour in contours:
            # Filter based on area and shape
            area = cv2.contourArea(contour)
            if 100 < area < 5000:  # Adjust these thresholds as needed
                # Get bounding rectangle
                x, y, w, h = cv2.boundingRect(contour)
                aspect_ratio = h / w if w > 0 else 0

                # Look for elongated shapes (like a drumstick)
                if aspect_ratio > 2:  # Adjust this threshold as needed
                    # Get the tip (highest point)
                    tip = tuple(contour[contour[:, :, 1].argmin()][0])

                    # Draw the detection
                    cv2.circle(frame, tip, 5, (0, 255, 0), -1)  # Tip
                    cv2.drawContours(frame, [contour], -1, (0, 255, 0), 2)  # Outline

                    drumstick_tip = tip
                    break

        return frame, combined_mask, drumstick_tip, gray

    def track(self):
        ret1, frame1 = self.camera1.read()
        ret2, frame2 = self.camera2.read()

        if not ret1 or not ret2:
            return None, None, None, None, None

        # Process both frames
        frame1, mask1, pos1, gray1 = self.detect_drumstick(frame1, self.prev_frame1)
        frame2, mask2, pos2, gray2 = self.detect_drumstick(frame2, self.prev_frame2)

        # Update previous frames
        self.prev_frame1 = gray1
        self.prev_frame2 = gray2

        # Add debug info to frames
        if pos1:
            cv2.putText(frame1, f"Tip: {pos1}", (10, 30),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
        if pos2:
            cv2.putText(frame2, f"Tip: {pos2}", (10, 30),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

        return frame1, frame2, mask1, mask2, (pos1, pos2)

    def cleanup(self):
        self.camera1.release()
        self.camera2.release()
        cv2.destroyAllWindows()