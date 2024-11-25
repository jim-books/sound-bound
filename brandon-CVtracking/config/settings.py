# config/settings.py

# Camera indices (you might need to swap these numbers depending on your system)
WEBCAM_1_INDEX = 0  # Built-in webcam
WEBCAM_2_INDEX = 1  # Logitech webcam

# Resolution (adjust based on your cameras' capabilities)
CAMERA_WIDTH = 640
CAMERA_HEIGHT = 480

# Color range for drumstick tracking (HSV color space)
# You'll need to adjust these values based on your drumstick color
DRUMSTICK_COLOR_LOWER = [90, 50, 50]    # Example for blue color
DRUMSTICK_COLOR_UPPER = [130, 255, 255]  # Adjust these based on testing

# Physical space measurements (in centimeters)
AREA_WIDTH = 100   # width of your drum kit area
AREA_HEIGHT = 100  # height of your drum kit area
AREA_DEPTH = 100   # depth of your drum kit area

# Debug mode (set to True to see color masks and tracking details)
DEBUG_MODE = True