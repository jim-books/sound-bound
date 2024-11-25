import cv2
import numpy as np
import time

def main():
    # Initialize camera
    cap = cv2.VideoCapture(0)  # Adjust if using a different camera index
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)  # Resolution: adjustable
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    cap.set(cv2.CAP_PROP_FPS, 60)  # Attempt to set high FPS

    # Allow the camera to warm up
    time.sleep(2)

    # Get frame dimensions
    frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    half_height = frame_height // 2  # Divide frame into upper/lower halves

    print("Starting IR LED tracking... Press 'q' to quit.")

    while True:
        ret, frame = cap.read()
        if not ret:
            print("Failed to grab frame")
            break

        # Convert to grayscale for IR detection
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

        # Apply threshold to isolate bright regions (tune threshold value as needed)
        _, thresh = cv2.threshold(gray, 200, 255, cv2.THRESH_BINARY)

        # Find contours in the thresholded image
        contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        marker_detected = False
        for cnt in contours:
            area = cv2.contourArea(cnt)
            if area > 50:  # Adjust area threshold based on marker size
                # Get bounding box and center of the contour
                x, y, w, h = cv2.boundingRect(cnt)
                center_x = x + w // 2
                center_y = y + h // 2

                # Determine if the marker is in the upper or lower half
                if center_y < half_height:
                    print("1 (Upper Half)")
                else:
                    print("2 (Lower Half)")

                # Draw visualization
                cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)  # Green rectangle
                cv2.circle(frame, (center_x, center_y), 5, (255, 0, 0), -1)  # Blue center
                marker_detected = True
                break  # Assuming only one marker

        if not marker_detected:
            print("No marker detected. Adjust threshold or lighting.")

        # Display the resulting frame for debugging
        cv2.imshow('Frame', frame)
        cv2.imshow('Threshold', thresh)  # Show thresholded image

        # Exit on pressing 'q'
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    # Release resources
    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()