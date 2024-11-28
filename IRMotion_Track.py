import cv2
from picamera2 import Picamera2
import time
import sys
from gpiozero import OutputDevice  # Import gpiozero library

# GPIO pin definition
SIGNAL_PIN = 17  # GPIO pin for signaling (BCM numbering)

def setup_gpio():
    """Set up GPIO pin."""
    signal = OutputDevice(SIGNAL_PIN, active_high=True, initial_value=False)
    return signal

def cleanup_gpio():
    """Clean up GPIO settings."""
    signal.off()

signal = setup_gpio()

# =================== Camera Setup ===================
picam2 = Picamera2()
picam2.configure(picam2.create_preview_configuration(
    raw={"size": (1640,1232)},
    main={"format": 'RGB888', "size": (640,480)}
))
picam2.start()
time.sleep(2)

# =================== Motion Detection Initialization ===================
prev_gray = None

frame_width = 640
frame_height = 480
half_height = frame_height // 2  # Divide frame into upper/lower halves

print("Starting IR LED tracking... Press 'q' to quit.")

# =================== Main Loop ===================
try:
    while True:
        img = picam2.capture_array()
        if img is None:
            print("Failed to grab frame")
            continue  # Skip to the next iteration

        # Convert current frame to grayscale for processing
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

        if prev_gray is None:
            prev_gray = gray
            continue  # Need at least two frames for differencing

        # Compute absolute difference between current frame and previous frame
        frame_diff = cv2.absdiff(gray, prev_gray)

        # Update previous frame
        prev_gray = gray

        # Apply threshold to the difference image to get binary mask of motion
        _, motion_thresh = cv2.threshold(frame_diff, 25, 255, cv2.THRESH_BINARY)

        # Dilate the thresholded image to fill in holes, making contours more detectable
        motion_thresh = cv2.dilate(motion_thresh, None, iterations=2)

        # Find contours in the motion thresholded image
        motion_contours, _ = cv2.findContours(motion_thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        # Apply threshold to isolate bright regions (IR detection)
        _, thresh = cv2.threshold(gray, 200, 255, cv2.THRESH_BINARY)

        # Find contours in the brightness thresholded image
        brightness_contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        # Initialize detection flags
        marker_detected = False
        position = "Unknown"

        # Iterate through motion contours to find overlapping bright contours
        for motion_cnt in motion_contours:
            motion_area = cv2.contourArea(motion_cnt)
            if motion_area < 100:  # Ignore small movements; adjust as needed
                continue

            # Compute bounding box for the motion contour
            x_motion, y_motion, w_motion, h_motion = cv2.boundingRect(motion_cnt)

            # Check overlap with brightness contours
            for bright_cnt in brightness_contours:
                bright_area = cv2.contourArea(bright_cnt)
                if bright_area < 50:  # Adjust area threshold based on marker size
                    continue

                x_bright, y_bright, w_bright, h_bright = cv2.boundingRect(bright_cnt)

                # Calculate overlap area
                overlap_x1 = max(x_motion, x_bright)
                overlap_y1 = max(y_motion, y_bright)
                overlap_x2 = min(x_motion + w_motion, x_bright + w_bright)
                overlap_y2 = min(y_motion + h_motion, y_bright + h_bright)

                if overlap_x1 < overlap_x2 and overlap_y1 < overlap_y2:
                    # Overlapping region found; likely the drumstick
                    center_x = overlap_x1 + (overlap_x2 - overlap_x1) // 2
                    center_y = overlap_y1 + (overlap_y2 - overlap_y1) // 2

                    # Determine if the marker is in the upper or lower half
                    if center_y < half_height:
                        # Upper Half Detected
                        signal.on()
                        position = "Upper Half (HIGH)"
                        print(f"Marker in Upper Half. GPIO {SIGNAL_PIN} set to HIGH.")
                    else:
                        # Lower Half Detected
                        signal.off()
                        position = "Lower Half (LOW)"
                        print(f"Marker in Lower Half. GPIO {SIGNAL_PIN} set to LOW.")

                    # Draw visualization
                    cv2.rectangle(img, (overlap_x1, overlap_y1), (overlap_x2, overlap_y2), (0, 255, 0), 2)  # Green rectangle
                    cv2.circle(img, (center_x, center_y), 5, (255, 0, 0), -1)                                     # Blue center
                    cv2.putText(img, position, (overlap_x1, overlap_y1 - 10), cv2.FONT_HERSHEY_SIMPLEX,
                                0.5, (0, 255, 0), 2)  # Add text annotation
                    marker_detected = True
                    break  # Assuming only one marker

            if marker_detected:
                break  # Exit if marker is detected

        if not marker_detected:
            # No marker detected; set SIGNAL_PIN to LOW
            signal.off()
            print(f"No marker detected. GPIO {SIGNAL_PIN} set to LOW.")
            cv2.putText(img, "No marker detected", (10, 30), cv2.FONT_HERSHEY_SIMPLEX,
                        0.7, (0, 0, 255), 2)  # Add warning text

        # Show the output image with annotations
        cv2.imshow("Output", img)

        # Optional: Display intermediate frames for debugging
        # cv2.imshow("Motion Detection", motion_thresh)
        # cv2.imshow("Brightness Detection", thresh)

        # Exit on pressing 'q'
        if cv2.waitKey(1) & 0xFF == ord('q'):
            print("Exiting...")
            break

except KeyboardInterrupt:
    print("\nKeyboardInterrupt received. Exiting gracefully...")
except Exception as e:
    print(f"An unexpected error occurred: {e}")
finally:
    # Cleanup GPIO and release resources
    cleanup_gpio(signal)
    if 'picam2' in globals():
        picam2.stop()
        picam2.close()
    cv2.destroyAllWindows()
    sys.exit()
