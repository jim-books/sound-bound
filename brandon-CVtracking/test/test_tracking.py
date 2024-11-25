# test/test_tracking.py

import sys
import os
import cv2

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from tracking.drumstick_tracking import DrumstickTracker


def main():
    try:
        tracker = DrumstickTracker()
        print("Cameras initialized successfully!")
        print("Press 'q' to quit")
        print("Adjust parameters to improve tracking")

        while True:
            frames = tracker.track()
            if frames is not None:
                frame1, frame2, mask1, mask2, positions = frames

                # Show the frames
                cv2.imshow('Camera 1 (Top View)', frame1)
                cv2.imshow('Camera 2 (Side View)', frame2)
                cv2.imshow('Detection Mask 1', mask1)
                cv2.imshow('Detection Mask 2', mask2)

                # Print positions if detected
                pos1, pos2 = positions
                if pos1 and pos2:
                    print(f"\rDrumstick tips - Camera1: {pos1}, Camera2: {pos2}", end='')

            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

    except Exception as e:
        print(f"Error: {str(e)}")
    finally:
        if 'tracker' in locals():
            tracker.cleanup()


if __name__ == "__main__":
    main()